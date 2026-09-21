; Dead add should vanish. Live add + ret stay.
define i32 @f(i32 %x) {
  %dead = add i32 %x, 1
  %y = add i32 %x, 2
  ret i32 %y
}
