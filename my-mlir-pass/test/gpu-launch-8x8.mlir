#map = affine_map<()[s0] -> (s0 * 2)>
#map1 = affine_map<(d0) -> (-d0 + 5, 2)>
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
    %c1 = arith.constant 1 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %c1, %arg10 = %c2, %arg11 = %c1) threads(%arg6, %arg7, %arg8) in (%arg12 = %c2, %arg13 = %c2, %arg14 = %c1) {
      %0 = affine.apply #map()[%arg4]
      %1 = arith.addi %arg7, %0 : index
      scf.for %arg15 = %c0 to %c3 step %c1 {
        %2 = memref.load %arg0[%arg6, %arg15] : memref<2x3xf32, strided<[?, ?], offset: ?>>
        %3 = memref.load %arg1[%arg15, %1] : memref<3x4xf32, strided<[?, ?], offset: ?>>
        %4 = memref.load %arg2[%arg6, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %5 = arith.mulf %2, %3 : f32
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %arg2[%arg6, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      }
      gpu.terminator
    } {SCFToGPU_visited}
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    %c2 = arith.constant 2 : index
    scf.parallel (%arg3) = (%c0) to (%c5) step (%c2) {
      %0 = affine.min #map1(%arg3)
      scf.parallel (%arg4, %arg5) = (%c0, %c0) to (%c2, %0) step (%c1, %c1) {
        %1 = arith.addi %arg5, %arg3 : index
        scf.for %arg6 = %c0 to %c5 step %c1 {
          %2 = memref.load %arg0[%arg4, %arg6] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %3 = memref.load %arg1[%arg6, %1] : memref<5x5xf32, strided<[?, ?], offset: ?>>
          %4 = memref.load %arg2[%arg4, %1] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %5 = arith.mulf %2, %3 : f32
          %6 = arith.addf %4, %5 : f32
          memref.store %6, %arg2[%arg4, %1] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        }
        scf.reduce 
      } {mapping = [#gpu.loop_dim_map<processor = thread_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = thread_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]}
      scf.reduce 
    }
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %c1, %arg10 = %c2, %arg11 = %c1) threads(%arg6, %arg7, %arg8) in (%arg12 = %c2, %arg13 = %c2, %arg14 = %c1) {
      %0 = affine.apply #map()[%arg4]
      %1 = arith.addi %arg7, %0 : index
      %2 = memref.load %arg0[%arg6, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %3 = memref.load %arg1[%arg6, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %4 = arith.addf %2, %3 : f32
      memref.store %4, %alloc[%arg6, %1] : memref<2x4xf32>
      gpu.terminator
    } {SCFToGPU_visited}
    return %alloc : memref<2x4xf32>
  }
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c4 = arith.constant 4 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    gpu.launch blocks(%arg4, %arg5, %arg6) in (%arg10 = %c4, %arg11 = %c4, %arg12 = %c1) threads(%arg7, %arg8, %arg9) in (%arg13 = %c2, %arg14 = %c2, %arg15 = %c1) {
      %0 = affine.apply #map()[%arg4]
      %1 = affine.apply #map()[%arg5]
      %2 = arith.addi %arg7, %0 : index
      %3 = arith.addi %arg8, %1 : index
      %4 = memref.load %arg0[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %5 = memref.load %arg1[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %6 = memref.load %arg2[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %7 = arith.addf %4, %5 : f32
      %8 = arith.mulf %7, %6 : f32
      memref.store %8, %alloc[%2, %3] : memref<8x8xf32>
      gpu.terminator
    } {SCFToGPU_visited}
    return %alloc : memref<8x8xf32>
  }
}

