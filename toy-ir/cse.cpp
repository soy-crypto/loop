#include "cse.h"
#include "ir.h"

#include <unordered_map>
#include <vector>

int cse_const(Function &fn) {
  int replaced = 0;
  for (Block &bb : fn.blocks) {
    std::unordered_map<int, int> remap;
    std::unordered_map<double, int> first_const;
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
