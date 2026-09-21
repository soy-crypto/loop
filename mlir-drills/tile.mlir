// Before: one affine nest over the whole N.
// After:  mlir-opt --affine-loop-tile="tile-size=32" splits each loop.
func.func @scale(%A: memref<128xf32>, %B: memref<128xf32>) {
  affine.for %i = 0 to 128 {
    %a = affine.load %A[%i] : memref<128xf32>
    %c = arith.constant 2.0 : f32
    %b = arith.mulf %a, %c : f32
    affine.store %b, %B[%i] : memref<128xf32>
  }
  return
}
