#include "dce.h"
#include "ir.h"

#include <cassert>
#include <iostream>

// v1 = const 99   <- dead
// v2 = const 1
// v3 = add v0, v2
// return v3
static Function make_with_dead() {
  Function fn;
  fn.name = "with_dead";
  int x = fn.fresh();
  fn.args.push_back(x);

  Block bb;
  bb.name = "entry";
  Inst dead{Opcode::Const, fn.fresh(), {}, 99.0};
  Inst c1{Opcode::Const, fn.fresh(), {}, 1.0};
  Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
  Inst ret{Opcode::Return, -1, {add.id}};
  bb.insts = {dead, c1, add, ret};
  fn.blocks.push_back(std::move(bb));
  return fn;
}

// A chain that is dead only transitively:
// v1 = const 5
// v2 = mul v0, v1   <- unused, so v1 dies too
// v3 = relu v0
// return v3
static Function make_dead_chain() {
  Function fn;
  fn.name = "dead_chain";
  int x = fn.fresh();
  fn.args.push_back(x);

  Block bb;
  bb.name = "entry";
  Inst c{Opcode::Const, fn.fresh(), {}, 5.0};
  Inst mul{Opcode::Mul, fn.fresh(), {x, c.id}};
  Inst relu{Opcode::Relu, fn.fresh(), {x}};
  Inst ret{Opcode::Return, -1, {relu.id}};
  bb.insts = {c, mul, relu, ret};
  fn.blocks.push_back(std::move(bb));
  return fn;
}

int main() {
  Function fn = make_with_dead();
  assert(fn.blocks[0].insts.size() == 4);
  int n = dce(fn);
  assert(n == 1);
  assert(fn.blocks[0].insts.size() == 3);
  assert(fn.blocks[0].insts[0].op == Opcode::Const);
  assert(fn.blocks[0].insts[0].imm == 1.0);

  Function chain = make_dead_chain();
  int m = dce(chain);
  assert(m == 2);
  assert(chain.blocks[0].insts.size() == 2);
  assert(chain.blocks[0].insts[0].op == Opcode::Relu);

  // Idempotent: a second run removes nothing.
  assert(dce(chain) == 0);

  Module mod;
  mod.functions.push_back(fn);
  dump_module(mod);
  std::cout << "DCE tests passed\n";
  return 0;
}
