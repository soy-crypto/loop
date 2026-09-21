// One file to study DCE + CSE. Read top to bottom. Compile:
//   make -C toy-ir study && ./toy-ir/study
// Recode for the interview still happens in dce.cpp / cse.cpp (make test).

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

enum class Opcode : uint8_t { Const, Add, Mul, Relu, Load, Store, Return };

struct Inst {
  Opcode op{};
  int id = -1;                 // result, or -1 for store/return
  std::vector<int> operands;   // value ids
  double imm = 0.0;            // Const only
};

struct Block {
  std::string name;
  std::vector<Inst> insts;
};

struct Function {
  std::string name;
  std::vector<int> args;
  std::vector<Block> blocks;
  int next_id = 0;
  int fresh() { return next_id++; }
};

// ---------------------------------------------------------------------------
// DCE — drop insts whose result is never used.
//
// Walk BACKWARDS. store/return always stay and mark their operands live.
// A forward sweep sees the def before the use and deletes a value still needed.
// ---------------------------------------------------------------------------
int dce(Function &fn) {
  int removed = 0;
  for (Block &bb : fn.blocks) {
    std::unordered_set<int> live;
    std::vector<Inst> kept;
    for (int i = static_cast<int>(bb.insts.size()) - 1; i >= 0; --i) {
      const Inst &inst = bb.insts[i];
      const bool root = inst.op == Opcode::Store || inst.op == Opcode::Return;
      const bool result_live = inst.id >= 0 && live.count(inst.id);
      if (!root && !result_live) {
        ++removed;
        continue;
      }
      for (int op : inst.operands)
        live.insert(op);
      kept.push_back(inst);
    }
    std::reverse(kept.begin(), kept.end());
    bb.insts = std::move(kept);
  }
  return removed;
}

// Example: v1=const 99 is dead. v2=const 1 is live (used by add). return is a root.
// After: const 1, add, return.  (removed 1)
//
// Transitive: v1=const 5, v2=mul v0,v1 unused, v3=relu v0, return v3.
// After: relu, return.  (removed 2 — mul and then the const)

// ---------------------------------------------------------------------------
// CSE (const only) — keep the first const of each immediate; rewrite uses.
//
// Remap operands FIRST. If you delete the duplicate const before rewriting,
// later insts still name the dead id.
// ---------------------------------------------------------------------------
int cse_const(Function &fn) {
  int replaced = 0;
  for (Block &bb : fn.blocks) {
    std::unordered_map<int, int> remap;       // old id -> survivor id
    std::unordered_map<double, int> first_const; // imm -> first id
    std::vector<Inst> kept;
    for (Inst inst : bb.insts) {
      for (int &op : inst.operands) {
        auto it = remap.find(op);
        if (it != remap.end())
          op = it->second;
      }
      if (inst.op == Opcode::Const) {
        auto it = first_const.find(inst.imm);
        if (it != first_const.end()) {
          remap[inst.id] = it->second;
          ++replaced;
          continue;
        }
        first_const.emplace(inst.imm, inst.id);
      }
      kept.push_back(std::move(inst));
    }
    bb.insts = std::move(kept);
  }
  return replaced;
}

// Example: v1=const 2, v2=const 2, add v0,v1, mul …,v2, return
// After: one const 2; mul uses v1 not v2.  (replaced 1)

int main() {
  // --- DCE ---
  {
    Function fn;
    int x = fn.fresh();
    fn.args.push_back(x);
    Inst dead{Opcode::Const, fn.fresh(), {}, 99.0};
    Inst c1{Opcode::Const, fn.fresh(), {}, 1.0};
    Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
    Inst ret{Opcode::Return, -1, {add.id}};
    fn.blocks.push_back({"entry", {dead, c1, add, ret}});
    assert(dce(fn) == 1);
    assert(fn.blocks[0].insts.size() == 3);
    assert(fn.blocks[0].insts[0].imm == 1.0);
  }
  {
    Function fn;
    int x = fn.fresh();
    Inst c{Opcode::Const, fn.fresh(), {}, 5.0};
    Inst mul{Opcode::Mul, fn.fresh(), {x, c.id}};
    Inst relu{Opcode::Relu, fn.fresh(), {x}};
    Inst ret{Opcode::Return, -1, {relu.id}};
    fn.blocks.push_back({"entry", {c, mul, relu, ret}});
    assert(dce(fn) == 2);
    assert(fn.blocks[0].insts[0].op == Opcode::Relu);
  }

  // --- CSE ---
  {
    Function fn;
    int x = fn.fresh();
    Inst c1{Opcode::Const, fn.fresh(), {}, 2.0};
    Inst c2{Opcode::Const, fn.fresh(), {}, 2.0};
    Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
    Inst mul{Opcode::Mul, fn.fresh(), {add.id, c2.id}};
    Inst ret{Opcode::Return, -1, {mul.id}};
    fn.blocks.push_back({"entry", {c1, c2, add, mul, ret}});
    assert(cse_const(fn) == 1);
    assert(fn.blocks[0].insts[2].operands[1] == fn.blocks[0].insts[0].id);
  }

  std::cout << "STUDY: DCE + CSE ok\n";
  std::cout << "DCE: walk backward; store/return are live roots.\n";
  std::cout << "CSE: rewrite operands through remap, then drop duplicate const.\n";
  return 0;
}
