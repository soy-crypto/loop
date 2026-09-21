// Naive GEMM vs 16x16 shared-memory tile.
// Story: same math, fewer global loads of A/B. Print both times.

#include <cuda_runtime.h>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>

static constexpr int TILE = 16;

#define CHECK(call)                                                            \
  do {                                                                         \
    cudaError_t err = (call);                                                  \
    if (err != cudaSuccess) {                                                  \
      fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__,                        \
              cudaGetErrorString(err));                                       \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)

__global__ void gemm_naive(const float *A, const float *B, float *C, int N) {
  int row = blockIdx.y * blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  if (row >= N || col >= N)
    return;
  float acc = 0.f;
  for (int k = 0; k < N; ++k)
    acc += A[row * N + k] * B[k * N + col];
  C[row * N + col] = acc;
}

__global__ void gemm_tiled(const float *A, const float *B, float *C, int N) {
  __shared__ float As[TILE][TILE];
  __shared__ float Bs[TILE][TILE];
  int row = blockIdx.y * TILE + threadIdx.y;
  int col = blockIdx.x * TILE + threadIdx.x;
  float acc = 0.f;
  for (int t = 0; t < N; t += TILE) {
    int a_col = t + threadIdx.x;
    int b_row = t + threadIdx.y;
    As[threadIdx.y][threadIdx.x] =
        (row < N && a_col < N) ? A[row * N + a_col] : 0.f;
    Bs[threadIdx.y][threadIdx.x] =
        (b_row < N && col < N) ? B[b_row * N + col] : 0.f;
    __syncthreads();
    for (int k = 0; k < TILE; ++k)
      acc += As[threadIdx.y][k] * Bs[k][threadIdx.x];
    __syncthreads();
  }
  if (row < N && col < N)
    C[row * N + col] = acc;
}

static float time_ms(void (*launch)(const float *, const float *, float *, int,
                                    int),
                     const float *A, const float *B, float *C, int N, int grid) {
  launch(A, B, C, N, grid);
  CHECK(cudaDeviceSynchronize());
  cudaEvent_t start, stop;
  CHECK(cudaEventCreate(&start));
  CHECK(cudaEventCreate(&stop));
  CHECK(cudaEventRecord(start));
  for (int i = 0; i < 10; ++i)
    launch(A, B, C, N, grid);
  CHECK(cudaEventRecord(stop));
  CHECK(cudaEventSynchronize(stop));
  float ms = 0.f;
  CHECK(cudaEventElapsedTime(&ms, start, stop));
  CHECK(cudaEventDestroy(start));
  CHECK(cudaEventDestroy(stop));
  return ms / 10.f;
}

static void launch_naive(const float *A, const float *B, float *C, int N,
                         int) {
  dim3 block(TILE, TILE);
  dim3 grid((N + TILE - 1) / TILE, (N + TILE - 1) / TILE);
  gemm_naive<<<grid, block>>>(A, B, C, N);
}

static void launch_tiled(const float *A, const float *B, float *C, int N,
                         int) {
  dim3 block(TILE, TILE);
  dim3 grid((N + TILE - 1) / TILE, (N + TILE - 1) / TILE);
  gemm_tiled<<<grid, block>>>(A, B, C, N);
}

int main() {
  const int N = 1024;
  std::vector<float> hA(N * N), hB(N * N), hC(N * N), hRef(N * N);
  for (int i = 0; i < N * N; ++i) {
    hA[i] = 0.001f * (i % 17);
    hB[i] = 0.001f * (i % 13);
  }
  float *A, *B, *C;
  CHECK(cudaMalloc(&A, hA.size() * sizeof(float)));
  CHECK(cudaMalloc(&B, hB.size() * sizeof(float)));
  CHECK(cudaMalloc(&C, hC.size() * sizeof(float)));
  CHECK(cudaMemcpy(A, hA.data(), hA.size() * sizeof(float),
                    cudaMemcpyHostToDevice));
  CHECK(cudaMemcpy(B, hB.data(), hB.size() * sizeof(float),
                    cudaMemcpyHostToDevice));

  launch_naive(A, B, C, N, 0);
  CHECK(cudaDeviceSynchronize());
  CHECK(cudaMemcpy(hRef.data(), C, hRef.size() * sizeof(float),
                    cudaMemcpyDeviceToHost));
  launch_tiled(A, B, C, N, 0);
  CHECK(cudaDeviceSynchronize());
  CHECK(cudaMemcpy(hC.data(), C, hC.size() * sizeof(float),
                    cudaMemcpyDeviceToHost));
  double max_abs = 0;
  for (int i = 0; i < N * N; ++i)
    max_abs = std::max(max_abs, (double)std::fabs(hC[i] - hRef[i]));

  float naive = time_ms(launch_naive, A, B, C, N, 0);
  float tiled = time_ms(launch_tiled, A, B, C, N, 0);
  printf("N=%d tile=%d\n", N, TILE);
  printf("naive  %.3f ms\n", naive);
  printf("tiled  %.3f ms\n", tiled);
  printf("max |tiled-naive| %.3g\n", max_abs);
  printf("why: each A/B element is reused from shared memory inside the tile "
         "instead of reloaded from global memory on every k\n");

  CHECK(cudaFree(A));
  CHECK(cudaFree(B));
  CHECK(cudaFree(C));
  return max_abs > 1e-3 ? 1 : 0;
}
