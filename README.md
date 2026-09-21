# Loop kit

Study repo for an NCG compiler / AI-compiler loop. Reading it is not the same
as passing. You pass when you can redo `toy-ir` DCE/CSE and explain the GEMM
number with the files closed.

| Interview slot | Files | Run |
|---|---|---|
| SSA DCE + CSE | `toy-ir/STUDY.cpp` | `make -C toy-ir study && ./toy-ir/study` |
| C++ ownership | `cpp/04_own.cpp` | `make -C cpp 04 && ./cpp/04` |
| LLVM (JD) | `llvm-pass/dce.cpp` | `make -C llvm-pass run` |
| MLIR (JD) | `mlir-pass/fuse.mlir` `tile.mlir` | `make -C mlir-pass run` |
| Kernel number | `kernels/gemm.cu` | `make -C kernels run` |

`toy-ir` is fake SSA so you can write a pass in 50 lines. `llvm-pass` is the same DCE on `llvm::Instruction`. `mlir-pass` is real `linalg` / `affine` via `mlir-opt`.

## What to say

**DCE.** Walk backward. `store` and `return` are live roots. A forward sweep sees the def before the use and deletes a value that is still needed.

**CSE.** Rewrite operands through the remap table before you drop a duplicate `const`. Later users must already name the first copy.

**GEMM.** Naive reloads A and B from global memory on every `k`. The tiled kernel stages a 16×16 tile into shared memory and reuses it. Same result; the time drop is that reuse.

**Ownership.** `unique_ptr` owns each child. `reset()` frees the subtree. The parent does not `delete`.

## Order if a loop is soon

1. Read `toy-ir/STUDY.cpp`, then wipe `dce` / `cse_const` and recode.
2. `make -C llvm-pass run` then recode `dce.cpp`. Draw `mlir-pass` fuse or tile from memory.
3. Run `kernels/gemm` and remember the two times plus the one sentence.
4. `cpp/04_own.cpp` in under 20 minutes from a blank file. Daily C++: `cpp/README.md`.
