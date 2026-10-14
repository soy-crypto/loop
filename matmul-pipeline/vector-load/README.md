# Vector-load pipeline

Same GPU function as `../shared-tiles`, then one more pass:

- `vectorize-matmul-copies` fills each 16×16 shared tile with `vector<4xf32>` loads. The first 64 threads of the block each copy four consecutive floats of a row. The barrier stays outside the `scf.if`.

Read `matmul-outlined.mlir` and compare the K-loop copy with `../shared-tiles/matmul-outlined.mlir`.

From `my-mlir-pass/`:

```bash
build/my-opt ../matmul-pipeline/vector-load/matmul.mlir --toy-matmul-vector-outline-pipeline
build/my-opt ../matmul-pipeline/vector-load/matmul.mlir --toy-matmul-vector-gpu-pipeline -o /tmp/matmul-vector-gpu.mlir
```

| Size | Shared tiles | Vector loads | cuBLAS |
|---|---|---|---|
| 128×128 | 0.63 ms | 0.70 ms | 0.12 ms |
| 1024×1024 | 173 ms | 107 ms | 37 ms |

128×128 is launch-bound, so the copy does not show up. At 1024×1024 the kernel is the time that matters.
