#include "dce.h"
#include "ir.h"

#include <algorithm>
#include <unordered_set>
#include <vector>

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
