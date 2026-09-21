# LLVM pass (the JD skill)

`toy-ir` is fake SSA. This folder is **real LLVM**: `llvm::Module`, `BasicBlock`, `Instruction`.

You run a DCE on `input.ll`. Same idea as `toy-ir/STUDY.cpp`, different API.

## Done

```bash
make -C llvm-pass run
```

Prints `removed 1` and IR **without** `%dead`. `%y` and `ret` stay.

## Why this is on the JD

You can say: I loaded LLVM IR, walked each function **backwards**, used `isInstructionTriviallyDead`, erased. That is an LLVM pass, not a toy struct.

## Recode

Delete `dce.cpp`. Rewrite from `TASK.md` only. `make run` must still drop `%dead`.
