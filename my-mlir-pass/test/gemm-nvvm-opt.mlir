module attributes {gpu.container_module} {
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %c64 = arith.constant 64 : index
    gpu.launch_func  @gemm_kernel::@gemm_kernel blocks in (%c8, %c8, %c1) threads in (%c8, %c8, %c1)  args(%arg0 : memref<64x64xf32>, %arg1 : memref<64x64xf32>, %c0 : index, %c64 : index, %c1 : index, %cst : f32, %arg2 : memref<64x64xf32>)
    return
  }
  gpu.module @gemm_kernel {
    llvm.func @gemm_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: i64, %arg17: f32, %arg18: !llvm.ptr, %arg19: !llvm.ptr, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 8, 8, 1>, gpu.known_grid_size = array<i32: 8, 8, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 8, 8, 1>} {
      %0 = llvm.mlir.constant(64 : index) : i64
      %1 = llvm.mlir.constant(8 : index) : i64
      %2 = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 8> : i32
      %3 = llvm.sext %2 : i32 to i64
      %4 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 8> : i32
      %5 = llvm.sext %4 : i32 to i64
      %6 = nvvm.read.ptx.sreg.tid.x range <i32, 0, 8> : i32
      %7 = llvm.sext %6 : i32 to i64
      %8 = nvvm.read.ptx.sreg.tid.y range <i32, 0, 8> : i32
      %9 = llvm.sext %8 : i32 to i64
      %10 = llvm.mul %3, %1 overflow<nsw> : i64
      %11 = llvm.mul %5, %1 overflow<nsw> : i64
      %12 = llvm.add %7, %10 : i64
      %13 = llvm.add %9, %11 : i64
      llvm.br ^bb1(%arg14, %arg17 : i64, f32)
    ^bb1(%14: i64, %15: f32):  // 2 preds: ^bb0, ^bb2
      %16 = llvm.icmp "slt" %14, %arg15 : i64
      llvm.cond_br %16, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %17 = llvm.mul %12, %0 overflow<nsw, nuw> : i64
      %18 = llvm.add %17, %14 overflow<nsw, nuw> : i64
      %19 = llvm.getelementptr inbounds|nuw %arg1[%18] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %20 = llvm.load %19 : !llvm.ptr -> f32
      %21 = llvm.mul %14, %0 overflow<nsw, nuw> : i64
      %22 = llvm.add %21, %13 overflow<nsw, nuw> : i64
      %23 = llvm.getelementptr inbounds|nuw %arg8[%22] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %24 = llvm.load %23 : !llvm.ptr -> f32
      %25 = llvm.fmul %20, %24 : f32
      %26 = llvm.fadd %25, %15 : f32
      %27 = llvm.add %14, %arg16 : i64
      llvm.br ^bb1(%27, %26 : i64, f32)
    ^bb3:  // pred: ^bb1
      %28 = llvm.mul %12, %0 overflow<nsw, nuw> : i64
      %29 = llvm.add %28, %13 overflow<nsw, nuw> : i64
      %30 = llvm.getelementptr inbounds|nuw %arg19[%29] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %15, %30 : f32, !llvm.ptr
      llvm.return
    }
  }
}

