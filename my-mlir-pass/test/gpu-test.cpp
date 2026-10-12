// Test the MLIR-generated host wrapper linked from gpu-host-8x8.o.
// Inputs use CUDA managed memory. The generated host function must allocate
// its output with `gpu.alloc host_shared`, not `memref.alloc`.
#include <cuda.h>

#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <string>
#include <type_traits>

struct MemRef2D {
  float *allocated;
  float *data;
  std::int64_t offset;
  std::int64_t sizes[2];
  std::int64_t strides[2];
};
static_assert(std::is_standard_layout_v<MemRef2D>);
static_assert(sizeof(void *) == 8 && sizeof(MemRef2D) == 56);
static_assert(offsetof(MemRef2D, offset) == 16);
static_assert(offsetof(MemRef2D, sizes) == 24);
static_assert(offsetof(MemRef2D, strides) == 40);

extern "C" void _mlir_ciface_add_then_mul(
    MemRef2D *output, const MemRef2D *a, const MemRef2D *b,
    const MemRef2D *scale, const MemRef2D *init);

static void checkCuda(CUresult status, const char *operation) {
  if (status == CUDA_SUCCESS)
    return;
  const char *message = nullptr;
  cuGetErrorString(status, &message);
  throw std::runtime_error(std::string(operation) + ": " +
                           (message ? message : "unknown CUDA error"));
}

// MLIR's CUDA runtime uses the default device's primary context too.
// Keeping it current also lets this test synchronize and free allocations.
class PrimaryContext {
public:
  PrimaryContext() {
    checkCuda(cuInit(0), "cuInit");
    checkCuda(cuDeviceGet(&device_, 0), "cuDeviceGet");
    checkCuda(cuDevicePrimaryCtxRetain(&context_, device_),
              "cuDevicePrimaryCtxRetain");
    CUresult status = cuCtxPushCurrent(context_);
    if (status != CUDA_SUCCESS) {
      cuDevicePrimaryCtxRelease(device_);
      checkCuda(status, "cuCtxPushCurrent");
    }
  }
  ~PrimaryContext() {
    CUcontext popped = nullptr;
    cuCtxPopCurrent(&popped);
    cuDevicePrimaryCtxRelease(device_);
  }
  PrimaryContext(const PrimaryContext &) = delete;
  PrimaryContext &operator=(const PrimaryContext &) = delete;

private:
  CUdevice device_{};
  CUcontext context_{};
};

struct CudaFree {
  void operator()(float *pointer) const {
    if (!pointer)
      return;
    CUresult status = cuMemFree(reinterpret_cast<CUdeviceptr>(pointer));
    if (status != CUDA_SUCCESS)
      std::fprintf(stderr, "cuMemFree failed with CUDA error %d\n", int(status));
  }
};
using ManagedBuffer = std::unique_ptr<float, CudaFree>;

static ManagedBuffer allocateMatrix() {
  CUdeviceptr pointer = 0;
  checkCuda(cuMemAllocManaged(&pointer, 64 * sizeof(float), CU_MEM_ATTACH_GLOBAL),
            "cuMemAllocManaged");
  return ManagedBuffer(reinterpret_cast<float *>(pointer));
}

static MemRef2D descriptor(float *pointer) {
  return {pointer, pointer, 0, {8, 8}, {8, 1}};
}

int main() {
  try {
    PrimaryContext context;
    auto a = allocateMatrix();
    auto b = allocateMatrix();
    auto scale = allocateMatrix();
    auto init = allocateMatrix();

    for (int i = 0; i < 64; ++i) {
      a.get()[i] = (i - 32) * 0.25f;
      b.get()[i] = (i % 7 + 1) * 0.125f;
      scale.get()[i] = (i % 5 + 1) * 0.5f;
      init.get()[i] = 0.0f;
    }

    auto aDesc = descriptor(a.get());
    auto bDesc = descriptor(b.get());
    auto scaleDesc = descriptor(scale.get());
    auto initDesc = descriptor(init.get());
    MemRef2D output{};

    // This calls CPU launch code in your .o, which launches the GPU kernel.
    _mlir_ciface_add_then_mul(&output, &aDesc, &bDesc, &scaleDesc, &initDesc);
    ManagedBuffer returnedAllocation(output.allocated);
    checkCuda(cuCtxSynchronize(), "cuCtxSynchronize after kernel launch");

    if (!output.allocated || !output.data || output.offset != 0 ||
        output.sizes[0] != 8 || output.sizes[1] != 8 ||
        output.strides[0] != 8 || output.strides[1] != 1)
      throw std::runtime_error("unexpected output memref descriptor");

    int mismatches = 0;
    for (int i = 0; i < 64; ++i) {
      const float expected = (a.get()[i] + b.get()[i]) * scale.get()[i];
      const float actual = output.data[i];
      const float tolerance = 1e-6f * (1.0f + std::fabs(expected));
      if (!std::isfinite(actual) || std::fabs(actual - expected) > tolerance) {
        if (mismatches < 5)
          std::fprintf(stderr, "Mismatch [%d,%d]: expected %.9g, got %.9g\n",
                       i / 8, i % 8, expected, actual);
        ++mismatches;
      }
    }
    if (mismatches) {
      std::fprintf(stderr, "FAIL: %d of 64 GPU results differ.\n", mismatches);
      return 1;
    }
    std::puts("PASS: all 64 GPU results match (a + b) * scale.");
    return 0;
  } catch (const std::exception &error) {
    std::fprintf(stderr, "FAIL: %s\n", error.what());
    return 1;
  }
}
