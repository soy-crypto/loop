# Days 1–3: toy SSA IR + DCE + CSE

You write the code. Tests are given — they define the contract. `make test` must pass.

Do not open `~/prep/reference/toy-ir` until you are done. It is a solution key, not a tutorial.

## Files you write

| File | Contents |
|------|----------|
| `ir.h` | `Opcode`, `Inst`, `Block`, `Function`, `Module`, `opcode_name`, decls of `dump_module` / `dump_function` |
| `dump.cpp` | printer |
| `dce.h` / `dce.cpp` | `int dce(Function &fn);` |
| `cse.h` / `cse.cpp` | `int cse_const(Function &fn);` |
| `main.cpp` | build `relu((x+1)*2)` by hand, dump it |

## API the tests assume

```cpp
enum class Opcode : uint8_t { Const, Add, Mul, Relu, Load, Store, Return };

struct Inst {
  Opcode op{};
  int id = -1;                 // result value, -1 for store/return
  std::vector<int> operands;   // value ids
  double imm = 0.0;            // Const only
};

struct Block    { std::string name; std::vector<Inst> insts; };
struct Function { std::string name; std::vector<int> args;
                  std::vector<Block> blocks; int next_id = 0;
                  int fresh() { return next_id++; } };
struct Module   { std::vector<Function> functions; };
```

Tests brace-init instructions positionally, e.g. `Inst{Opcode::Add, fn.fresh(), {x, c1.id}}`, so keep the field order above.

## Day 1 — IR + dump

`make run` prints exactly:

```
func @relu_mac(v0) {
  entry:
    v1 = const 1
    v2 = add v0, v1
    v3 = const 2
    v4 = mul v2, v3
    v5 = relu v4
    return v5
}
```

Values print as `v<id>`. `store` prints `store vA, vB`. `return` prints `return vA`.

## Day 2 — `dce(Function&) -> int`

Remove instructions whose result is never used. `store` and `return` are always live and root the liveness walk. Returns the number removed.

Think before coding: why walk the block backwards, and what breaks if you sweep forward in one pass?

## Day 3 — `cse_const(Function&) -> int`

Within a block, keep the first `const` of each immediate value and delete later duplicates, rewriting their uses to the survivor. Returns the number of instructions replaced.

Think before coding: why rewrite an instruction's operands *before* deciding whether to keep it?

## Done when

- `make test` passes both tests
- you can explain, without notes: liveness direction in DCE, and why CSE needs the remap table

Then: Day 6, MLIR (`~/llvm-project/build/bin/mlir-opt` is already built).
