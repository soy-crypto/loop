# Loop kit

Study repo for an NCG compiler / AI-compiler loop. Reading it is not the same
as passing. You pass when you can redo `toy-ir` DCE/CSE and explain the GEMM
number with the files closed.

| Interview slot | Files | Run |
|---|---|---|
| SSA + dump | `toy-ir/ir.h` `dump.cpp` `main.cpp` | `make -C toy-ir run` |
| DCE (backward) | `toy-ir/dce.cpp` | `make -C toy-ir test` |
| CSE (remap first) | `toy-ir/cse.cpp` | same |
| C++ ownership | `cpp/own.cpp` | `make -C cpp run` |
| MLIR fusion | `mlir-drills/fuse.mlir` | see below |
| MLIR tile | `mlir-drills/tile.mlir` | see below |
| Kernel number | `kernels/gemm.cu` | `make -C kernels run` |
| LLVM IR reading | `llvm-drills/*.ll` | read aloud |
| TVM schedule | `tvm-start/matmul_schedule.py` | that README |

## MLIR

```bash
OPT=~/llvm-project/build/bin/mlir-opt
$OPT mlir-drills/fuse.mlir --linalg-fuse-elementwise-ops
$OPT mlir-drills/tile.mlir --affine-loop-tile="tile-size=32"
```

Fusion: two `linalg.generic` ops (add, then mul) become one generic that does `addf` then `mulf`. One loop, one write.

Tiling: the `affine.for` to 128 becomes an outer step-32 loop and an inner 32-trip loop.

## What to say

**DCE.** Walk backward. `store` and `return` are live roots. A forward sweep sees the def before the use and deletes a value that is still needed.

**CSE.** Rewrite operands through the remap table before you drop a duplicate `const`. Later users must already name the first copy.

**GEMM.** Naive reloads A and B from global memory on every `k`. The tiled kernel stages a 16×16 tile into shared memory and reuses it. Same result; the time drop is that reuse.

**Ownership.** `unique_ptr` owns each child. `reset()` frees the subtree. The parent does not `delete`.

## Order if a loop is soon

1. `make -C toy-ir test` then delete `dce.cpp` and `cse.cpp` and rewrite them.
2. Draw fuse before/after from memory.
3. Run `kernels/gemm` and remember the two times plus the one sentence.
4. `cpp/own.cpp` in under 20 minutes from a blank file.
