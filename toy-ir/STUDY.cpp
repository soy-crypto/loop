// One file: a list of instructions, then DCE, then CSE.
// Run:  make -C toy-ir study && ./toy-ir/study
//
// Picture (not a tree): a LIST, top to bottom.
//   v1 = const 99
//   v2 = const 1
//   v3 = add v0, v2
//        return v3
// Names (v0, v1, ...) can be used more than once = a DAG of values.

#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

enum class Opcode : uint8_t
{
  Const,
  Add,
  Mul,
  Relu,
  Load,
  Store,
  Return
};

// One line of IR.
struct Inst
{
  Opcode op{};
  int id = -1;               // name of the result: v1, v2, ...  (-1 = no result)
  std::vector<int> operands; // names this line reads (e.g. add uses v0 and v2)
  double imm = 0.0;          // only for Const: the number 99 or 1
};

// One basic block: just a vector of Inst, in order.
struct Block
{
  std::string name;
  std::vector<Inst> insts;
};

struct Function
{
  std::string name;
  std::vector<int> args; // v0 is usually the argument, not an Inst
  std::vector<Block> blocks;
  int next_id = 0;
  int fresh()
  {
    return next_id++;
  } // 0, then 1, then 2, ...
};

// ---------------------------------------------------------------------------
// DCE = delete lines whose result nobody needs.
//
// Paper (first test in main). Start at the BOTTOM. live = names still needed.
//
//   return v3          keep (return always stays).  live = {v3}
//   v3 = add v0, v2    v3 is live -> keep.          live = {v3, v0, v2}
//   v2 = const 1       v2 is live -> keep.
//   v1 = const 99      v1 is NOT live -> DELETE.
//
// Flip kept lines back to top-to-bottom:  const 1, add, return.
//
// Walk BACKWARD so you see "who needs this" before you decide to delete.
// Walk forward and you meet const 99 first, with live still empty — wrong.
// store/return are roots: they stay even if they have no id.
// ---------------------------------------------------------------------------
int dce(Function &fn)
{
  int removed = 0;
  for (Block &bb : fn.blocks)
  {
    std::unordered_set<int> live; // names the return still needs
    std::vector<Inst> kept;       // we push bottom-up, reverse at the end
    for (int i = static_cast<int>(bb.insts.size()) - 1; i >= 0; --i)
    {
      const Inst &inst = bb.insts[i];
      const bool root = inst.op == Opcode::Store || inst.op == Opcode::Return;
      const bool result_live = inst.id >= 0 && live.count(inst.id);
      if (!root && !result_live)
      {
        ++removed; // nobody needs this result
        continue;
      }
      for (int op : inst.operands)
      {
        live.insert(op); // those names are now needed
      }
      kept.push_back(inst);
    }
    std::reverse(kept.begin(), kept.end());
    bb.insts = std::move(kept);
  }
  return removed;
}

// ---------------------------------------------------------------------------
// CSE (const only) = one "const 2", not two.
//
// Paper (third test in main):
//   v1 = const 2
//   v2 = const 2          same number -> drop v2, remember v2 means v1
//   v3 = add v0, v1
//   v4 = mul v3, v2       rewrite v2 -> v1 BEFORE you would look at mul
//        return v4
//
// remap: old name -> name we kept.  FIRST rewrite operands, THEN drop duplicate.
// Delete v2 first and mul still says v2 -> broken.
// ---------------------------------------------------------------------------
int cse_const(Function &fn)
{
  int replaced = 0;
  for (Block &bb : fn.blocks)
  {
    std::unordered_map<int, int> remap;          // v2 -> v1
    std::unordered_map<double, int> first_const; // 2.0 -> v1
    std::vector<Inst> kept;
    for (Inst inst : bb.insts)
    {
      for (int &op : inst.operands)
      {
        auto it = remap.find(op);
        if (it != remap.end())
        {
          op = it->second; // use the first copy's id
        }
      }
      if (inst.op == Opcode::Const)
      {
        auto it = first_const.find(inst.imm);
        if (it != first_const.end())
        {
          remap[inst.id] = it->second;
          ++replaced;
          continue; // do not keep this duplicate const
        }
        first_const.emplace(inst.imm, inst.id);
      }
      kept.push_back(std::move(inst));
    }
    bb.insts = std::move(kept);
  }
  return replaced;
}

int main()
{
  // --- DCE example 1: drop unused const 99 ---
  // v0=x, v1=99, v2=1, v3=add(v0,v2), return v3
  {
    Function fn;
    int x = fn.fresh();
    fn.args.push_back(x);
    Inst dead{Opcode::Const, fn.fresh(), {}, 99.0};
    Inst c1{Opcode::Const, fn.fresh(), {}, 1.0};
    Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
    Inst ret{Opcode::Return, -1, {add.id}};
    fn.blocks.push_back({"entry", {dead, c1, add, ret}});
    assert(dce(fn) == 1);                   // only const 99 removed
    assert(fn.blocks[0].insts.size() == 3); // const 1, add, return
    assert(fn.blocks[0].insts[0].imm == 1.0);
  }

  // --- DCE example 2: unused mul, so its const dies too ---
  // v1=const 5, v2=mul(x,v1) unused, v3=relu(x), return v3
  {
    Function fn;
    int x = fn.fresh();
    Inst c{Opcode::Const, fn.fresh(), {}, 5.0};
    Inst mul{Opcode::Mul, fn.fresh(), {x, c.id}};
    Inst relu{Opcode::Relu, fn.fresh(), {x}};
    Inst ret{Opcode::Return, -1, {relu.id}};
    fn.blocks.push_back({"entry", {c, mul, relu, ret}});
    assert(dce(fn) == 2); // mul and const 5
    assert(fn.blocks[0].insts[0].op == Opcode::Relu);
  }

  // --- CSE: two const 2 -> one; mul must use the first id ---
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
  return 0;
}
