#map = affine_map<(d0, d1, d2) -> (d0, d1 - d2)>
module {
  func.func @ictest(%arg0: i32) -> i32 {
    %0 = arith.addi %arg0, %arg0 : i32
    return %0 : i32
  }
  func.func @add_zero(%arg0: i32) -> i32 {
    return %arg0 : i32
  }
  func.func @keep_add(%arg0: i32, %arg1: i32) -> i32 {
    %0 = arith.addi %arg0, %arg1 : i32
    return %0 : i32
  }
  func.func @matmul(%arg0: memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1: memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    %c0_0 = arith.constant 0 : index
    %c2_1 = arith.constant 2 : index
    %c2_2 = arith.constant 2 : index
    %0 = arith.muli %c1, %c2_1 : index
    %1 = arith.muli %c1, %c2_2 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c4) step (%0, %1) {
      scf.parallel (%arg5, %arg6) = (%c0_0, %c0_0) to (%0, %1) step (%c1, %c1) {
        %2 = arith.addi %arg5, %arg3 : index
        %3 = arith.addi %arg6, %arg4 : index
        scf.for %arg7 = %c0 to %c3 step %c1 {
          %4 = memref.load %arg0[%2, %arg7] : memref<2x3xf32, strided<[?, ?], offset: ?>>
          %5 = memref.load %arg1[%arg7, %3] : memref<3x4xf32, strided<[?, ?], offset: ?>>
          %6 = memref.load %arg2[%2, %3] : memref<2x4xf32, strided<[?, ?], offset: ?>>
          %7 = arith.mulf %4, %5 : f32
          %8 = arith.addf %6, %7 : f32
          memref.store %8, %arg2[%2, %3] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        }
        scf.reduce 
      }
      scf.reduce 
    }
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    %c0_0 = arith.constant 0 : index
    %c2_1 = arith.constant 2 : index
    %c2_2 = arith.constant 2 : index
    %0 = arith.muli %c1, %c2_1 : index
    %1 = arith.muli %c1, %c2_2 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c5) step (%0, %1) {
      %2 = affine.min #map(%1, %c5, %arg4)
      scf.parallel (%arg5, %arg6) = (%c0_0, %c0_0) to (%0, %2) step (%c1, %c1) {
        %3 = arith.addi %arg5, %arg3 : index
        %4 = arith.addi %arg6, %arg4 : index
        scf.for %arg7 = %c0 to %c5 step %c1 {
          %5 = memref.load %arg0[%3, %arg7] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %6 = memref.load %arg1[%arg7, %4] : memref<5x5xf32, strided<[?, ?], offset: ?>>
          %7 = memref.load %arg2[%3, %4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %8 = arith.mulf %5, %6 : f32
          %9 = arith.addf %7, %8 : f32
          memref.store %9, %arg2[%3, %4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        }
        scf.reduce 
      }
      scf.reduce 
    }
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    %c0_0 = arith.constant 0 : index
    %c2_1 = arith.constant 2 : index
    %c2_2 = arith.constant 2 : index
    %0 = arith.muli %c1, %c2_1 : index
    %1 = arith.muli %c1, %c2_2 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c4) step (%0, %1) {
      scf.parallel (%arg5, %arg6) = (%c0_0, %c0_0) to (%0, %1) step (%c1, %c1) {
        %2 = arith.addi %arg5, %arg3 : index
        %3 = arith.addi %arg6, %arg4 : index
        %4 = memref.load %arg0[%2, %3] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %5 = memref.load %arg1[%2, %3] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %alloc[%2, %3] : memref<2x4xf32>
        scf.reduce 
      }
      scf.reduce 
    }
    return %alloc : memref<2x4xf32>
  }
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    %c0_0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c2_1 = arith.constant 2 : index
    %0 = arith.muli %c1, %c2 : index
    %1 = arith.muli %c1, %c2_1 : index
    scf.parallel (%arg4, %arg5) = (%c0, %c0) to (%c8, %c8) step (%0, %1) {
      scf.parallel (%arg6, %arg7) = (%c0_0, %c0_0) to (%0, %1) step (%c1, %c1) {
        %2 = arith.addi %arg6, %arg4 : index
        %3 = arith.addi %arg7, %arg5 : index
        %4 = memref.load %arg0[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
        %5 = memref.load %arg1[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
        %6 = memref.load %arg2[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
        %7 = arith.addf %4, %5 : f32
        %8 = arith.mulf %7, %6 : f32
        memref.store %8, %alloc[%2, %3] : memref<8x8xf32>
        scf.reduce 
      }
      scf.reduce 
    }
    return %alloc : memref<8x8xf32>
  }
}

