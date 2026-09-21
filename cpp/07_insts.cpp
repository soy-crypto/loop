// 07 — a program is a LIST of Inst (not a tree).
// Each Inst: op name, result id (v1, v2, ...), operand ids it reads.
// toy-ir/STUDY.cpp is this list plus DCE/CSE. This file only prints the list.
#include <iostream>
#include <string>
#include <vector>

struct Inst
{
  std::string op;
  int id;
  std::vector<int> operands;
};

int main()
{
  // v1 = const
  // v2 = add v0, v1
  //      ret v2
  std::vector<Inst> insts;
  insts.push_back({"const", 1, {}});
  insts.push_back({"add", 2, {0, 1}});
  insts.push_back({"ret", -1, {2}});

  for (const Inst &in : insts)
  {
    std::cout << in.op << " id=" << in.id << " nops=" << in.operands.size()
              << "\n";
  }
  return 0;
}
