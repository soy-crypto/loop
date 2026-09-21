func.func @f() -> i32 {
  %a = arith.constant 2 : i32
  %b = arith.constant 3 : i32
  %0 = arith.addi %a, %b : i32
  return %0 : i32
}