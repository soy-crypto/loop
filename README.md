# loop

Five small, runnable pieces of a compiler-engineer toolkit: an SSA IR with two
passes, the same DCE written against the real LLVM C++ API, MLIR fusion and
tiling, a C++ memory-ownership set, and a CUDA GEMM with a measured speedup.

Everything here builds and runs. Each directory is one idea, kept small enough
to read in a sitting and rewrite from scratch.

## Layout

| Directory | What it is |
|---|---|
| `toy-ir/` | A tiny SSA IR (`const`, `add`, `mul`, `relu`, `store`, `return`) plus dead-code elimination and constant CSE, in one file |
| `llvm-pass/` | The same DCE on `llvm::Module` / `Instruction`, using `isInstructionTriviallyDead` |
| `mlir-pass/` | `linalg` elementwise fusion and `affine` loop tiling through `mlir-opt` |
| `cpp/` | Eight programs on pointers vs references, `vector` invalidation, `unique_ptr`, and undefined behavior |
| `kernels/` | Naive vs 16×16 shared-memory-tiled GEMM, timed with CUDA events |

## Build and run

```bash
make -C toy-ir study && ./toy-ir/study
make -C llvm-pass run      # needs llvm-config; override with LLVM_CONFIG=...
make -C mlir-pass run      # needs mlir-opt; override with OPT=...
make -C cpp run
make -C kernels run        # needs nvcc + an NVIDIA GPU
```

## Results

**`toy-ir`** — DCE removes a dead `const 99`, and removes two instructions when
a `mul` is unused and its `const` dies with it. CSE collapses duplicate
immediates and rewrites their users.

**`llvm-pass`** — on `input.ll`, `%dead` disappears and the live `add` stays:

```llvm
define i32 @f(i32 %x) {
  %y = add i32 %x, 2
  ret i32 %y
}
```

**`mlir-pass`** — `--linalg-fuse-elementwise-ops` turns two `linalg.generic` ops
into one whose body does `arith.addf` then `arith.mulf`: one loop nest, one
write to the output tensor. `--affine-loop-tile="tile-size=32"` splits the
`affine.for` over 128 into an outer step-32 loop and an inner 32-trip loop.

**`kernels`** — N=1024, RTX A3000 Laptop, mean of 10 launches:

| Kernel | Time |
|---|---|
| naive | 3.59 ms |
| 16×16 tiled | 2.71 ms |

Max elementwise difference against the naive result is 0.

## Notes

**DCE walks backward.** `store` and `return` are live roots and mark their
operands live. Going forward in a single pass reaches a definition before its
uses, so it would delete values that are still needed. Backward, the live set is
already complete by the time each definition is visited, which also handles
transitively dead chains.

**CSE rewrites operands before deleting.** Operands go through the remap table
first; only then is a duplicate `const` dropped. Delete first and later
instructions still name an id that no longer exists.

**The GEMM win is reuse, not arithmetic.** Both kernels do the same N³
multiply-adds. The naive kernel reloads a row of A and a column of B from global
memory on every `k`. The tiled kernel stages a 16×16 block of each into shared
memory and reuses it across the block, so the bottleneck moves off global
memory bandwidth.

**Ownership.** `unique_ptr` owns each child node; `reset()` frees that subtree,
and no destructor calls `delete` by hand.

## Practice order

This repo is also interview prep, and reading it is not the same as knowing it.
The drill is to rewrite each piece from an empty file:

1. Read `toy-ir/STUDY.cpp`, then wipe the bodies of `dce` and `cse_const` and
   recode both in one sitting.
2. Recode `llvm-pass/dce.cpp` from `llvm-pass/TASK.md` alone.
3. Draw the `mlir-pass` fusion or tiling before/after with no editor open.
4. `cpp/04_own.cpp` from blank in under 20 minutes; daily rotation in
   `cpp/README.md`.
5. Re-run the GEMM and say which bottleneck moved, in one sentence.

`LOOP.md` is the longer plan behind that order.
