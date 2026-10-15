module attributes {gpu.container_module} {
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    gpu.launch_func  @gemm_kernel::@gemm_kernel blocks in (%c8, %c8, %c1) threads in (%c8, %c8, %c1)  args(%cst : f32, %arg2 : memref<64x64xf32>)
    gpu.launch_func  @gemm_kernel_0::@gemm_kernel blocks in (%c8, %c8, %c1) threads in (%c8, %c8, %c1)  args(%arg0 : memref<64x64xf32>, %arg1 : memref<64x64xf32>, %arg2 : memref<64x64xf32>, %c0 : index, %c64 : index, %c1 : index)
    return
  }
  gpu.module @gemm_kernel {
    llvm.func @gemm_kernel(%arg0: f32, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 8, 8, 1>, gpu.known_grid_size = array<i32: 8, 8, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 8, 8, 1>} {
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
      %14 = llvm.mul %12, %0 overflow<nsw, nuw> : i64
      %15 = llvm.add %14, %13 overflow<nsw, nuw> : i64
      %16 = llvm.getelementptr inbounds|nuw %arg2[%15] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %arg0, %16 : f32, !llvm.ptr
      llvm.return
    }
  }
  gpu.module @gemm_kernel_0 {
    llvm.func @gemm_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 8, 8, 1>, gpu.known_grid_size = array<i32: 8, 8, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 8, 8, 1>} {
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
      llvm.br ^bb1(%arg21 : i64)
    ^bb1(%14: i64):  // 2 preds: ^bb0, ^bb2
      %15 = llvm.icmp "slt" %14, %arg22 : i64
      llvm.cond_br %15, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %16 = llvm.mul %12, %0 overflow<nsw, nuw> : i64
      %17 = llvm.add %16, %14 overflow<nsw, nuw> : i64
      %18 = llvm.getelementptr inbounds|nuw %arg1[%17] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %19 = llvm.load %18 : !llvm.ptr -> f32
      %20 = llvm.mul %14, %0 overflow<nsw, nuw> : i64
      %21 = llvm.add %20, %13 overflow<nsw, nuw> : i64
      %22 = llvm.getelementptr inbounds|nuw %arg8[%21] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %23 = llvm.load %22 : !llvm.ptr -> f32
      %24 = llvm.add %16, %13 overflow<nsw, nuw> : i64
      %25 = llvm.getelementptr inbounds|nuw %arg15[%24] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %26 = llvm.load %25 : !llvm.ptr -> f32
      %27 = llvm.fmul %19, %23 : f32
      %28 = llvm.fadd %27, %26 : f32
      llvm.store %28, %25 : f32, !llvm.ptr
      %29 = llvm.add %14, %arg23 : i64
      llvm.br ^bb1(%29 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
}

