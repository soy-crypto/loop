GPU pipeline integration for the existing my-mlir-pass project (MLIR 21).

Copy tools/main.cpp, tools/GpuPipeline.cpp, and CMakeLists.txt into the
corresponding paths in your project. Keep the existing lib/MyPass.cpp.
Back up the two existing files before replacing them.

Build:
  cmake -S . -B build -DMLIR_DIR=/usr/lib/llvm-21/lib/cmake/mlir -DLLVM_DIR=/usr/lib/llvm-21/lib/cmake/llvm
  cmake --build build --target my-opt -j2

Compile the ORIGINAL tensor input (not a previously lowered file):
  build/my-opt test/test.mlir --toy-gpu-pipeline -o test/gpu-pipeline-8x8.mlir

Inspect the outlined kernel instead:
  build/my-opt test/test.mlir --toy-gpu-outline-pipeline -o test/gpu-pipeline-outlined-8x8.mlir

The complete pipeline produces LLVM-dialect CPU launch code plus gpu.binary
containing PTX. To finish the executable:
  mlir-translate-21 test/gpu-pipeline-8x8.mlir --mlir-to-llvmir -o test/gpu-pipeline-8x8.ll
  clang-21 -O0 -c test/gpu-pipeline-8x8.ll -o test/gpu-pipeline-8x8.o
  clang++-21 -std=c++17 -O0 test/gpu-test.cpp test/gpu-pipeline-8x8.o -Lruntime -lmlir_cuda_runtime -lcuda -Wl,-rpath,'$ORIGIN/../runtime' -o build/gpu-pipeline-test
  build/gpu-pipeline-test

Expected:
  PASS: all 64 GPU results match (a + b) * scale.

The shared-output pass performs the host-memory allocation edit automatically.
The C++ caller still supplies CUDA-accessible input buffers and frees the output
using CUDA. This is a fixed teaching pipeline for add_then_mul on 8x8 f32 with
2x2 tiles and sm_86. It does not promise correctness or performance of other
functions in the input file, which may also be transformed by the built-in passes.

Validation:
The individual lowering stages and GPU execution passed on the user's MLIR 21
machine. These integrated C++ files require a rebuild and another GPU run on that
machine; this scratch environment has no MLIR 21 SDK or CUDA GPU.
