# C++ for this loop

This is the whole C++ set. Not a language course. Compiler interviews
here grade **ownership, references, `vector`, no UB**.

Each `0N_*.cpp` is a finished program. **Today:** `make 01 && ./01` and
read it. **Tomorrow:** rewrite that file from a blank buffer, then compile.

```bash
cd cpp
make 01 && ./01
```

## Order (one file per day, 45 min)

| File | Topic | You must say |
|---|---|---|
| `01_ptr_ref.cpp` | `int*` vs `int&` | pointer can be null; ref is an alias |
| `02_vector.cpp` | `push_back`, index loop | size vs capacity |
| `03_erase.cpp` | `erase` without dangling iterator | after erase, old iterator is dead |
| `04_own.cpp` | `unique_ptr` tree | who frees the node |
| `05_new_vs_unique.cpp` | `new`/`delete` vs `unique_ptr` | double-free and leak |
| `06_pass.cpp` | by value / `const &` / `&` | copy vs mutate caller |
| `07_insts.cpp` | toy-IR shaped `vector<Inst>` | same as `toy-ir` |
| `08_ub.cpp` | dangling pointer, use-after-free | what is illegal |

Then recode `04_own.cpp` in **20 min**. Then ask for a timed 45-min problem.

## Rules

- `-Wall -Wextra`; fix warnings.
- After it runs, speak: who owns each pointer, what would be UB.
- One line in `misses.txt` if you stall.
- No LeetCode until 01–06 are easy from memory.

Skip templates, inheritance, threads, exceptions, C++20 ranges.
