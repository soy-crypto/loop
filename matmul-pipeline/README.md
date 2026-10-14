# Matmul pipelines

Same input: `linalg.matmul`, f32. The difference is the K loop inside `gpu.func @matmul_kernel`.

| Folder | K loop | 128×128 | 1024×1024 |
|---|---|---|---|
| `original/` | Loads A, B, and C from global memory on every step | 4.586 ms | — |
| `shared-tiles/` | Sum in a register. A and B are 16×16 shared tiles | 0.700 ms | 173 ms |
| `vector-load/` | Shared tiles filled with `vector<4xf32>` loads | 0.70 ms | 107 ms |

cuBLAS at 1024×1024 was 37 ms. 128×128 is launch-bound; compare kernels at 1024×1024.

From `my-mlir-pass/`:

```bash
cmake --build build --target my-opt
build/my-opt ../matmul-pipeline/original/matmul.mlir --toy-matmul-outline-pipeline
build/my-opt ../matmul-pipeline/shared-tiles/matmul.mlir --toy-matmul-tiled-outline-pipeline
build/my-opt ../matmul-pipeline/vector-load/matmul.mlir --toy-matmul-vector-outline-pipeline
```
