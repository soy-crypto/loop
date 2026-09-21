// 07 — same shape as toy-ir: a list of instructions
#include <iostream>
#include <string>
#include <vector>

struct Inst {
  std::string op;
  int id;
  std::vector<int> operands;
};

int main() {
  std::vector<Inst> insts;
  insts.push_back({"const", 1, {}});
  insts.push_back({"add", 2, {0, 1}});
  insts.push_back({"ret", -1, {2}});

  for (const Inst &in : insts) {
    std::cout << in.op << " id=" << in.id << " nops=" << in.operands.size()
              << "\n";
  }
  return 0;
}
