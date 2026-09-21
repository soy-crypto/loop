# toy-ir

One file: `STUDY.cpp` (IR + DCE + CSE).

```bash
make -C toy-ir study && ./toy-ir/study
```

Cold recode: wipe `dce` / `cse_const` in `STUDY.cpp`, rewrite, `make study` again.
