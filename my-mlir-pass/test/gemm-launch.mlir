#map = affine_map<()[s0] -> (s0 * 8)>
module {
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %c8, %arg10 = %c8, %arg11 = %c1) threads(%arg6, %arg7, %arg8) in (%arg12 = %c8, %arg13 = %c8, %arg14 = %c1) {
      %0 = affine.apply #map()[%arg3]
      %1 = affine.apply #map()[%arg4]
      %2 = arith.addi %arg6, %0 : index
      %3 = arith.addi %arg7, %1 : index
      memref.store %cst, %arg2[%2, %3] : memref<64x64xf32>
      gpu.terminator
    } {SCFToGPU_visited}
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %c8, %arg10 = %c8, %arg11 = %c1) threads(%arg6, %arg7, %arg8) in (%arg12 = %c8, %arg13 = %c8, %arg14 = %c1) {
      %0 = affine.apply #map()[%arg3]
      %1 = affine.apply #map()[%arg4]
      %2 = arith.addi %arg6, %0 : index
      %3 = arith.addi %arg7, %1 : index
      scf.for %arg15 = %c0 to %c64 step %c1 {
        %4 = memref.load %arg0[%2, %arg15] : memref<64x64xf32>
        %5 = memref.load %arg1[%arg15, %3] : memref<64x64xf32>
        %6 = memref.load %arg2[%2, %3] : memref<64x64xf32>
        %7 = arith.mulf %4, %5 : f32
        %8 = arith.addf %7, %6 : f32
        memref.store %8, %arg2[%2, %3] : memref<64x64xf32>
      }
      gpu.terminator
    } {SCFToGPU_visited}
    return
  }
}

