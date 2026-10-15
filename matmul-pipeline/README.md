# Matmul pipelines

One `linalg.matmul`, f32, lowered to a GPU kernel. Each folder is the previous kernel plus one change. Read `original/matmul-outlined.mlir`, then `shared-tiles/`, then `vector-load/`.

| Step | Folder | What changed | Time |
|---|---|---|---|
| 0 | `original/` | Each K step loads A, B, and C from global memory | 4.586 ms at 128×128 |
| 1 | `shared-tiles/` | Sum stays in a register. A and B are 16×16 shared-memory tiles | 0.700 ms at 128×128, about **6.6×** faster. 173 ms at 1024×1024 |
| 2 | `vector-load/` | The copy into those tiles loads four floats at a time | about 92 ms at 1024×1024, about **1.9×** faster than shared tiles |

128×128 is too small: the launch costs more than the kernel, so step 2 does not show up there. Compare kernels at 1024×1024. cuBLAS at that size is about 31 ms.

Tensor cores were tried on the same 16×16 tile. The result matched, and the time stayed near 95 ms, so there is no folder. Only one warp of the 256-thread block issued the instruction. A 128×128 output tile, with a K tile of 16, is the size that gives every warp work.

From `my-mlir-pass/`:

```bash
cmake --build build --target my-opt
build/my-opt ../matmul-pipeline/original/matmul.mlir --toy-matmul-outline-pipeline
build/my-opt ../matmul-pipeline/shared-tiles/matmul.mlir --toy-matmul-tiled-outline-pipeline
build/my-opt ../matmul-pipeline/vector-load/matmul.mlir --toy-matmul-vector-outline-pipeline
```
