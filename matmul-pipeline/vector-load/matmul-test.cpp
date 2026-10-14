// Host check for the matmul GPU pipeline. A, B, and C are CUDA managed memory.
// linalg.matmul accumulates into C, so C starts at zero.
#include <cublas_v2.h>
#include <cuda.h>

#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <memory>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <vector>

static constexpr int N = 128;

struct MemRef2D {
  float *allocated;
  float *data;
  std::int64_t offset;
  std::int64_t sizes[2];
  std::int64_t strides[2];
};
static_assert(std::is_standard_layout_v<MemRef2D>);
static_assert(sizeof(void *) == 8 && sizeof(MemRef2D) == 56);

extern "C" void _mlir_ciface_matmul(MemRef2D *output, const MemRef2D *a,
                                    const MemRef2D *b, const MemRef2D *c);

static void checkCuda(CUresult status, const char *operation) {
  if (status == CUDA_SUCCESS)
    return;
  const char *message = nullptr;
  cuGetErrorString(status, &message);
  throw std::runtime_error(std::string(operation) + ": " +
                           (message ? message : "unknown CUDA error"));
}

static void checkCublas(cublasStatus_t status, const char *operation) {
  if (status == CUBLAS_STATUS_SUCCESS)
    return;
  throw std::runtime_error(std::string(operation) + " failed: " +
                           std::to_string(static_cast<int>(status)));
}

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
  checkCuda(cuMemAllocManaged(&pointer, static_cast<size_t>(N) * N * sizeof(float),
                              CU_MEM_ATTACH_GLOBAL),
            "cuMemAllocManaged");
  return ManagedBuffer(reinterpret_cast<float *>(pointer));
}

static MemRef2D descriptor(float *pointer) {
  return {pointer, pointer, 0, {N, N}, {N, 1}};
}

static void zeroMatrix(float *pointer) {
  checkCuda(cuMemsetD8(reinterpret_cast<CUdeviceptr>(pointer), 0,
                       static_cast<size_t>(N) * N * sizeof(float)),
            "cuMemsetD8");
}

int main() {
  try {
    PrimaryContext context;
    auto a = allocateMatrix();
    auto b = allocateMatrix();
    auto c = allocateMatrix();
    auto cublasOut = allocateMatrix();

    for (int i = 0; i < N * N; ++i) {
      a.get()[i] = 0.01f * static_cast<float>((i * 3) % 17 - 8);
      b.get()[i] = 0.01f * static_cast<float>((i * 5) % 13 - 6);
    }
    zeroMatrix(c.get());
    zeroMatrix(cublasOut.get());
    checkCuda(cuCtxSynchronize(), "cuCtxSynchronize after init");

    auto aDesc = descriptor(a.get());
    auto bDesc = descriptor(b.get());
    auto cDesc = descriptor(c.get());
    MemRef2D output{};
    _mlir_ciface_matmul(&output, &aDesc, &bDesc, &cDesc);
    const bool pipelineAllocated = output.allocated && output.allocated != c.get();
    ManagedBuffer returnedAllocation(pipelineAllocated ? output.allocated : nullptr);
    checkCuda(cuCtxSynchronize(), "cuCtxSynchronize after matmul");

    float *gpu = output.data ? output.data : c.get();
    std::vector<float> expected(static_cast<size_t>(N) * N, 0.f);
    for (int i = 0; i < N; ++i) {
      for (int k = 0; k < N; ++k) {
        const float aik = a.get()[i * N + k];
        for (int j = 0; j < N; ++j)
          expected[i * N + j] += aik * b.get()[k * N + j];
      }
    }

    int mismatches = 0;
    for (int i = 0; i < N * N; ++i) {
      const float actual = gpu[i];
      const float tolerance = 1e-3f * (1.0f + std::fabs(expected[i]));
      if (!std::isfinite(actual) || std::fabs(actual - expected[i]) > tolerance) {
        if (mismatches < 5)
          std::fprintf(stderr, "Mismatch [%d,%d]: expected %.9g, got %.9g\n",
                       i / N, i % N, expected[i], actual);
        ++mismatches;
      }
    }
    if (mismatches) {
      std::fprintf(stderr, "FAIL: %d of %d GPU results differ.\n", mismatches, N * N);
      return 1;
    }

    cublasHandle_t handle = nullptr;
    checkCublas(cublasCreate(&handle), "cublasCreate");
    const float alpha = 1.f;
    const float beta = 0.f;
    // Row-major A*B is column-major B*A. Later launches overwrite C, so the
    // timed calls are not a second correctness check.
    auto timeMs = [](auto &&launch) {
      launch();
      checkCuda(cuCtxSynchronize(), "warmup synchronize");
      CUevent start, stop;
      checkCuda(cuEventCreate(&start, CU_EVENT_DEFAULT), "cuEventCreate");
      checkCuda(cuEventCreate(&stop, CU_EVENT_DEFAULT), "cuEventCreate");
      constexpr int kIters = 10;
      checkCuda(cuEventRecord(start, nullptr), "cuEventRecord");
      for (int i = 0; i < kIters; ++i)
        launch();
      checkCuda(cuEventRecord(stop, nullptr), "cuEventRecord");
      checkCuda(cuEventSynchronize(stop), "cuEventSynchronize");
      float ms = 0.f;
      checkCuda(cuEventElapsedTime(&ms, start, stop), "cuEventElapsedTime");
      cuEventDestroy(start);
      cuEventDestroy(stop);
      return ms / kIters;
    };
    // Row-major A*B is column-major B*A.
    const float mlirMs = timeMs([&]() {
      MemRef2D timedOut{};
      _mlir_ciface_matmul(&timedOut, &aDesc, &bDesc, &cDesc);
      if (timedOut.allocated && timedOut.allocated != c.get() &&
          timedOut.allocated != output.allocated)
        checkCuda(cuMemFree(reinterpret_cast<CUdeviceptr>(timedOut.allocated)),
                  "cuMemFree timed output");
    });
    const float cublasMs = timeMs([&]() {
      checkCublas(cublasSgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, N, N, N, &alpha,
                              b.get(), N, a.get(), N, &beta, cublasOut.get(), N),
                  "cublasSgemm");
    });
    cublasDestroy(handle);

    int cublasMismatches = 0;
    for (int i = 0; i < N * N; ++i) {
      const float tolerance = 1e-3f * (1.0f + std::fabs(expected[i]));
      if (std::fabs(cublasOut.get()[i] - expected[i]) > tolerance)
        ++cublasMismatches;
    }
    if (cublasMismatches) {
      std::fprintf(stderr, "FAIL: cuBLAS reference differs in %d elements.\n",
                   cublasMismatches);
      return 1;
    }

    std::printf("PASS: all %d GPU matmul results match.\n", N * N);
    std::printf("mlir matmul: %.3f ms\n", mlirMs);
    std::printf("cublas:      %.3f ms\n", cublasMs);
    return 0;
  } catch (const std::exception &error) {
    std::fprintf(stderr, "FAIL: %s\n", error.what());
    return 1;
  }
}
