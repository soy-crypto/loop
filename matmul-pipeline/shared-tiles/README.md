# Shared-tiles pipeline

Same GPU function as `../original`, then two passes:

- `hoist-matmul-acc` keeps the sum in a register and stores C once.
- `stage-matmul-tiles` loads 16×16 tiles of A and B into shared memory.

Read `matmul-outlined.mlir` and compare its K loop with `../original/matmul-outlined.mlir`.

From `my-mlir-pass/`:

```bash
build/my-opt ../matmul-pipeline/shared-tiles/matmul.mlir --toy-matmul-tiled-outline-pipeline
build/my-opt ../matmul-pipeline/shared-tiles/matmul.mlir --toy-matmul-tiled-gpu-pipeline -o /tmp/matmul-tiled-gpu.mlir
```

Measured time: 0.700 ms. The original kernel was 4.586 ms.
