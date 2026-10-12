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
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c4) step (%c1, %c1) {
      scf.for %arg5 = %c0 to %c3 step %c1 {
        %0 = memref.load %arg0[%arg3, %arg5] : memref<2x3xf32, strided<[?, ?], offset: ?>>
        %1 = memref.load %arg1[%arg5, %arg4] : memref<3x4xf32, strided<[?, ?], offset: ?>>
        %2 = memref.load %arg2[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %3 = arith.mulf %0, %1 : f32
        %4 = arith.addf %2, %3 : f32
        memref.store %4, %arg2[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
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
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c5) step (%c1, %c1) {
      scf.for %arg5 = %c0 to %c5 step %c1 {
        %0 = memref.load %arg0[%arg3, %arg5] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        %1 = memref.load %arg1[%arg5, %arg4] : memref<5x5xf32, strided<[?, ?], offset: ?>>
        %2 = memref.load %arg2[%arg3, %arg4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        %3 = arith.mulf %0, %1 : f32
        %4 = arith.addf %2, %3 : f32
        memref.store %4, %arg2[%arg3, %arg4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
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
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c2, %c4) step (%c1, %c1) {
      %0 = memref.load %arg0[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %1 = memref.load %arg1[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %2 = arith.addf %0, %1 : f32
      memref.store %2, %alloc[%arg3, %arg4] : memref<2x4xf32>
      scf.reduce 
    }
    return %alloc : memref<2x4xf32>
  }
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    scf.parallel (%arg4, %arg5) = (%c0, %c0) to (%c8, %c8) step (%c1, %c1) {
      %0 = memref.load %arg0[%arg4, %arg5] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %1 = memref.load %arg1[%arg4, %arg5] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %2 = memref.load %arg2[%arg4, %arg5] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %3 = arith.addf %0, %1 : f32
      %4 = arith.mulf %3, %2 : f32
      memref.store %4, %alloc[%arg4, %arg5] : memref<8x8xf32>
      scf.reduce 
    }
    return %alloc : memref<8x8xf32>
  }
}

