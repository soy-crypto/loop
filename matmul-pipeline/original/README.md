# Original pipeline

One thread computes one output. For every step of K it loads A, B, and C from global memory and stores C.

Read `matmul-outlined.mlir`. The K loop is inside `gpu.func @matmul_kernel`.

From `my-mlir-pass/`:

```bash
build/my-opt ../matmul-pipeline/original/matmul.mlir --toy-matmul-outline-pipeline
build/my-opt ../matmul-pipeline/original/matmul.mlir --toy-matmul-gpu-pipeline -o /tmp/matmul-gpu.mlir
```

Measured time: 4.586 ms.
