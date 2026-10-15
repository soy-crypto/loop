// Test the generated @gemm C interface from gemm-host.o.
// All matrices use CUDA managed memory on device 0.
// Timings include both kernels and host launch/synchronization overhead.
#include <cuda.h>

#include <array>
#include <chrono>
#include <limits>
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

extern "C" void _mlir_ciface_gemm(
    const MemRef2D *a, const MemRef2D *b, MemRef2D *c);

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
  checkCuda(cuMemAllocManaged(&pointer, 64 * 64 * sizeof(float), CU_MEM_ATTACH_GLOBAL),
            "cuMemAllocManaged");
  return ManagedBuffer(reinterpret_cast<float *>(pointer));
}

static MemRef2D descriptor(float *pointer) {
  return {pointer, pointer, 0, {64, 64}, {64, 1}};
}

static void verify(const float *actual, const std::array<double, 4096> &reference) {
  int mismatches = 0;
  for (int p = 0; p < 4096; ++p) {
    double expected = reference[p];
    if (!std::isfinite(actual[p]) ||
        std::fabs(double(actual[p]) - expected) > 1e-4 * (1.0 + std::fabs(expected))) {
      if (mismatches < 5)
        std::fprintf(stderr, "Mismatch [%d,%d]: expected %.9g, got %.9g\n",
                     p / 64, p % 64, expected, double(actual[p]));
      ++mismatches;
    }
  }
  if (mismatches)
    throw std::runtime_error(std::to_string(mismatches) + " GEMM mismatches");
}

int main() {
  try {
    PrimaryContext context;
    auto a = allocateMatrix();
    auto b = allocateMatrix();
    auto c = allocateMatrix();
    for (int i = 0; i < 64; ++i) {
      for (int j = 0; j < 64; ++j) {
        a.get()[i * 64 + j] = float((i * 7 + j * 3) % 17 - 8) / 8.0f;
        b.get()[i * 64 + j] = float((i * 5 + j * 11) % 19 - 9) / 16.0f;
        c.get()[i * 64 + j] = std::numeric_limits<float>::quiet_NaN();
      }
    }
    std::array<double, 4096> reference{};
    for (int i = 0; i < 64; ++i)
      for (int j = 0; j < 64; ++j)
        for (int k = 0; k < 64; ++k)
          reference[i * 64 + j] +=
              double(a.get()[i * 64 + k]) * double(b.get()[k * 64 + j]);

    auto aDesc = descriptor(a.get());
    auto bDesc = descriptor(b.get());
    auto cDesc = descriptor(c.get());
    auto run = [&] { _mlir_ciface_gemm(&aDesc, &bDesc, &cDesc); };
    run();
    checkCuda(cuCtxSynchronize(), "synchronize first GEMM");
    verify(c.get(), reference);

    // Warm up after the CPU checks, which can migrate managed memory.
    for (int i = 0; i < 10; ++i)
      run();
    checkCuda(cuCtxSynchronize(), "synchronize warmup");
    constexpr int iterations = 100;
    const auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < iterations; ++i)
      run();
    checkCuda(cuCtxSynchronize(), "synchronize timed GEMMs");
    const auto finish = std::chrono::steady_clock::now();
    const double us = std::chrono::duration<double, std::micro>(finish - start).count()
                      / iterations;
    verify(c.get(), reference);
    std::puts("PASS: all 4096 GPU results match A * B (including repeated calls).");
    std::printf("Mean host end-to-end GEMM latency: %.3f us (%d calls).\n",
                us, iterations);
    return 0;
  } catch (const std::exception &error) {
    std::fprintf(stderr, "FAIL: %s\n", error.what());
    return 1;
  }
}
