// CPU check for the generated _mlir_ciface_add_then_mul wrapper.
// Link this driver with test/llvm-8x8-cpu.o on your machine.
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

struct MemRef2D {
  float *allocated;
  float *aligned;
  std::int64_t offset;
  std::int64_t sizes[2];
  std::int64_t strides[2];
};

static_assert(sizeof(void *) == 8, "This driver uses the x86-64 descriptor layout.");
static_assert(sizeof(MemRef2D) == 56, "Unexpected memref descriptor layout.");

extern "C" void _mlir_ciface_add_then_mul(
    MemRef2D *output, const MemRef2D *a, const MemRef2D *b,
    const MemRef2D *scale, const MemRef2D *init);

static MemRef2D describe(float *data) {
  return {data, data, 0, {8, 8}, {8, 1}};
}

int main() {
  alignas(64) float a[64];
  alignas(64) float b[64];
  alignas(64) float scale[64];
  alignas(64) float init[64] = {};

  for (int k = 0; k < 64; ++k) 
  {
    a[k] = static_cast<float>(k);
    b[k] = static_cast<float>(2 * k + 1);
    scale[k] = 0.5f + 0.25f * static_cast<float>(k % 5);
  }

  MemRef2D aDesc = describe(a);
  MemRef2D bDesc = describe(b);
  MemRef2D scaleDesc = describe(scale);
  MemRef2D initDesc = describe(init);
  MemRef2D output{};

  _mlir_ciface_add_then_mul(&output, &aDesc, &bDesc, &scaleDesc, &initDesc);

  if (!output.allocated || !output.aligned || output.sizes[0] != 8 || output.sizes[1] != 8) 
  {
    std::fprintf(stderr, "FAIL: invalid output descriptor.\n");
    std::free(output.allocated);
    return 1;
  }

  for (int row = 0; row < 8; ++row) 
  {
    for (int col = 0; col < 8; ++col) 
    {
      const int k = row * 8 + col;
      const std::int64_t position = output.offset + row * output.strides[0] + col * output.strides[1];
      const float actual = output.aligned[position];
      const float expected = (a[k] + b[k]) * scale[k];

      if (!std::isfinite(actual) || std::fabs(actual - expected) > 1.0e-5f) 
      {
        std::fprintf(stderr, "FAIL at [%d][%d]: got %.9g, expected %.9g\n", row, col, actual, expected);
        std::free(output.allocated);
        return 1;
      }

    }

  }

  // Free the original malloc pointer, which may differ from the aligned pointer.
  std::free(output.allocated);
  std::puts("PASS: all 64 results match (a + b) * scale.");
  return 0;
}
