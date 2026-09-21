#include "cse.h"
#include "ir.h"

#include <cassert>
#include <iostream>

// v1 = const 2
// v2 = const 2    <- duplicate
// v3 = add v0, v1
// v4 = mul v3, v2 <- must be rewritten to use v1
// return v4
static Function make_dup_const() {
  Function fn;
  fn.name = "dup_const";
  int x = fn.fresh();
  fn.args.push_back(x);

  Block bb;
  bb.name = "entry";
  Inst c1{Opcode::Const, fn.fresh(), {}, 2.0};
  Inst c2{Opcode::Const, fn.fresh(), {}, 2.0};
  Inst add{Opcode::Add, fn.fresh(), {x, c1.id}};
  Inst mul{Opcode::Mul, fn.fresh(), {add.id, c2.id}};
  Inst ret{Opcode::Return, -1, {mul.id}};
  bb.insts = {c1, c2, add, mul, ret};
  fn.blocks.push_back(std::move(bb));
  return fn;
}

// Three copies of 3.0, and a use that chains through a folded value.
static Function make_triple_const() {
  Function fn;
  fn.name = "triple_const";
  int x = fn.fresh();
  fn.args.push_back(x);

  Block bb;
  bb.name = "entry";
  Inst a{Opcode::Const, fn.fresh(), {}, 3.0};
  Inst b{Opcode::Const, fn.fresh(), {}, 3.0};
  Inst c{Opcode::Const, fn.fresh(), {}, 3.0};
  Inst add{Opcode::Add, fn.fresh(), {b.id, c.id}};
  Inst mul{Opcode::Mul, fn.fresh(), {add.id, a.id}};
  Inst ret{Opcode::Return, -1, {mul.id}};
  bb.insts = {a, b, c, add, mul, ret};
  fn.blocks.push_back(std::move(bb));
  return fn;
}

int main() {
  Function fn = make_dup_const();
  int n = cse_const(fn);
  assert(n == 1);
  assert(fn.blocks[0].insts.size() == 4);
  const Inst &mul = fn.blocks[0].insts[2];
  assert(mul.op == Opcode::Mul);
  assert(mul.operands[1] == fn.blocks[0].insts[0].id);

  Function tri = make_triple_const();
  int keep = tri.blocks[0].insts[0].id;
  int m = cse_const(tri);
  assert(m == 2);
  assert(tri.blocks[0].insts.size() == 4);
  const Inst &add = tri.blocks[0].insts[1];
  assert(add.op == Opcode::Add);
  assert(add.operands[0] == keep && add.operands[1] == keep);

  // Idempotent: nothing left to fold.
  assert(cse_const(tri) == 0);

  Module mod;
  mod.functions.push_back(fn);
  dump_module(mod);
  std::cout << "CSE tests passed\n";
  return 0;
}
