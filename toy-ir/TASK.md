# toy-ir

Read `STUDY.cpp` from the top comments, then `dce()`, then `main`’s first test.

- **DCE:** unused lines go away. Walk from `return` upward.
- **CSE:** two `const 2` become one. Rewrite uses, then delete the copy.

```bash
make -C toy-ir study && ./toy-ir/study
```
