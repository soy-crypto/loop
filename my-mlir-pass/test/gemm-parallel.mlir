module {
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c64, %c64) step (%c1, %c1) {
      memref.store %cst, %arg2[%arg3, %arg4] : memref<64x64xf32>
      scf.reduce 
    }
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c64, %c64) step (%c1, %c1) {
      scf.for %arg5 = %c0 to %c64 step %c1 {
        %0 = memref.load %arg0[%arg3, %arg5] : memref<64x64xf32>
        %1 = memref.load %arg1[%arg5, %arg4] : memref<64x64xf32>
        %2 = memref.load %arg2[%arg3, %arg4] : memref<64x64xf32>
        %3 = arith.mulf %0, %1 : f32
        %4 = arith.addf %2, %3 : f32
        memref.store %4, %arg2[%arg3, %arg4] : memref<64x64xf32>
      }
      scf.reduce 
    }
    return
  }
}

