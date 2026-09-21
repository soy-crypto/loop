#pragma once

#include <cstdint>
#include <string>
#include <vector>

enum class Opcode : uint8_t { Const, Add, Mul, Relu, Load, Store, Return };

struct Inst {
  Opcode op{};
  int id = -1;
  std::vector<int> operands;
  double imm = 0.0;
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

struct Module {
  std::vector<Function> functions;
};

inline const char *opcode_name(Opcode op) {
  switch (op) {
  case Opcode::Const:
    return "const";
  case Opcode::Add:
    return "add";
  case Opcode::Mul:
    return "mul";
  case Opcode::Relu:
    return "relu";
  case Opcode::Load:
    return "load";
  case Opcode::Store:
    return "store";
  case Opcode::Return:
    return "return";
  }
  return "?";
}

void dump_function(const Function &fn);
void dump_module(const Module &mod);
