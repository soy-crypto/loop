#include "ir.h"

int main() {
  Function fn;
  fn.name = "relu_mac";
  int x = fn.fresh();
  fn.args.push_back(x);

  Block bb;
  bb.name = "entry";
  Inst c1{Opcode::Const, fn.fresh(), {}, 1.0};
  Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
  Inst c2{Opcode::Const, fn.fresh(), {}, 2.0};
  Inst mul{Opcode::Mul, fn.fresh(), {add.id, c2.id}};
  Inst relu{Opcode::Relu, fn.fresh(), {mul.id}};
  Inst ret{Opcode::Return, -1, {relu.id}};
  bb.insts = {c1, add, c2, mul, relu, ret};
  fn.blocks.push_back(std::move(bb));

  dump_function(fn);
  return 0;
}
