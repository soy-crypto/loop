#include "ir.h"

#include <cmath>
#include <iostream>

static void print_value(std::ostream &os, int id) { os << 'v' << id; }

static void print_operands(std::ostream &os, const std::vector<int> &ops) {
  for (size_t i = 0; i < ops.size(); ++i) {
    if (i)
      os << ", ";
    print_value(os, ops[i]);
  }
}

void dump_function(const Function &fn) {
  std::cout << "func @" << fn.name << '(';
  for (size_t i = 0; i < fn.args.size(); ++i) {
    if (i)
      std::cout << ", ";
    print_value(std::cout, fn.args[i]);
  }
  std::cout << ") {\n";
  for (const Block &bb : fn.blocks) {
    std::cout << "  " << bb.name << ":\n";
    for (const Inst &inst : bb.insts) {
      std::cout << "    ";
      if (inst.op == Opcode::Return || inst.op == Opcode::Store) {
        std::cout << opcode_name(inst.op);
        if (!inst.operands.empty()) {
          std::cout << ' ';
          print_operands(std::cout, inst.operands);
        }
      } else {
        print_value(std::cout, inst.id);
        std::cout << " = " << opcode_name(inst.op) << ' ';
        if (inst.op == Opcode::Const) {
          if (std::isfinite(inst.imm) && inst.imm == std::floor(inst.imm))
            std::cout << static_cast<long long>(inst.imm);
          else
            std::cout << inst.imm;
        } else {
          print_operands(std::cout, inst.operands);
        }
      }
      std::cout << '\n';
    }
  }
  std::cout << "}\n";
}

void dump_module(const Module &mod) {
  for (size_t i = 0; i < mod.functions.size(); ++i) {
    if (i)
      std::cout << '\n';
    dump_function(mod.functions[i]);
  }
}
