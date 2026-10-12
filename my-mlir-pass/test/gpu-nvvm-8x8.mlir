#map = affine_map<(d0) -> (-d0 + 5, 2)>
module attributes {gpu.container_module} {
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
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c1, %c2, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %c0 : index, %c3 : index, %c1 : index)
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  gpu.module @matmul_kernel {
    llvm.func @matmul_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 2, 2, 1>, gpu.known_grid_size = array<i32: 1, 2, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 2, 2, 1>} {
      %0 = llvm.mlir.constant(2 : index) : i64
      %1 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 2> : i32
      %2 = llvm.sext %1 : i32 to i64
      %3 = nvvm.read.ptx.sreg.tid.x range <i32, 0, 2> : i32
      %4 = llvm.sext %3 : i32 to i64
      %5 = nvvm.read.ptx.sreg.tid.y range <i32, 0, 2> : i32
      %6 = llvm.sext %5 : i32 to i64
      %7 = llvm.mul %2, %0 overflow<nsw> : i64
      %8 = llvm.add %6, %7 : i64
      llvm.br ^bb1(%arg21 : i64)
    ^bb1(%9: i64):  // 2 preds: ^bb0, ^bb2
      %10 = llvm.icmp "slt" %9, %arg22 : i64
      llvm.cond_br %10, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %11 = llvm.getelementptr %arg1[%arg2] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %12 = llvm.mul %4, %arg5 overflow<nsw, nuw> : i64
      %13 = llvm.mul %9, %arg6 overflow<nsw, nuw> : i64
      %14 = llvm.add %12, %13 overflow<nsw, nuw> : i64
      %15 = llvm.getelementptr inbounds|nuw %11[%14] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %16 = llvm.load %15 : !llvm.ptr -> f32
      %17 = llvm.getelementptr %arg8[%arg9] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %18 = llvm.mul %9, %arg12 overflow<nsw, nuw> : i64
      %19 = llvm.mul %8, %arg13 overflow<nsw, nuw> : i64
      %20 = llvm.add %18, %19 overflow<nsw, nuw> : i64
      %21 = llvm.getelementptr inbounds|nuw %17[%20] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %22 = llvm.load %21 : !llvm.ptr -> f32
      %23 = llvm.getelementptr %arg15[%arg16] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %24 = llvm.mul %4, %arg19 overflow<nsw, nuw> : i64
      %25 = llvm.mul %8, %arg20 overflow<nsw, nuw> : i64
      %26 = llvm.add %24, %25 overflow<nsw, nuw> : i64
      %27 = llvm.getelementptr inbounds|nuw %23[%26] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %28 = llvm.load %27 : !llvm.ptr -> f32
      %29 = llvm.fmul %16, %22 : f32
      %30 = llvm.fadd %28, %29 : f32
      llvm.store %30, %27 : f32, !llvm.ptr
      %31 = llvm.add %9, %arg23 : i64
      llvm.br ^bb1(%31 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    %c2 = arith.constant 2 : index
    scf.parallel (%arg3) = (%c0) to (%c5) step (%c2) {
      %0 = affine.min #map(%arg3)
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
    gpu.launch_func  @elementwise_add_kernel::@elementwise_add_kernel blocks in (%c1, %c2, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %alloc : memref<2x4xf32>)
    return %alloc : memref<2x4xf32>
  }
  gpu.module @elementwise_add_kernel {
    llvm.func @elementwise_add_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 2, 2, 1>, gpu.known_grid_size = array<i32: 1, 2, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 2, 2, 1>} {
      %0 = llvm.mlir.constant(4 : index) : i64
      %1 = llvm.mlir.constant(2 : index) : i64
      %2 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 2> : i32
      %3 = llvm.sext %2 : i32 to i64
      %4 = nvvm.read.ptx.sreg.tid.x range <i32, 0, 2> : i32
      %5 = llvm.sext %4 : i32 to i64
      %6 = nvvm.read.ptx.sreg.tid.y range <i32, 0, 2> : i32
      %7 = llvm.sext %6 : i32 to i64
      %8 = llvm.mul %3, %1 overflow<nsw> : i64
      %9 = llvm.add %7, %8 : i64
      %10 = llvm.getelementptr %arg1[%arg2] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %11 = llvm.mul %5, %arg5 overflow<nsw, nuw> : i64
      %12 = llvm.mul %9, %arg6 overflow<nsw, nuw> : i64
      %13 = llvm.add %11, %12 overflow<nsw, nuw> : i64
      %14 = llvm.getelementptr inbounds|nuw %10[%13] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %15 = llvm.load %14 : !llvm.ptr -> f32
      %16 = llvm.getelementptr %arg8[%arg9] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %17 = llvm.mul %5, %arg12 overflow<nsw, nuw> : i64
      %18 = llvm.mul %9, %arg13 overflow<nsw, nuw> : i64
      %19 = llvm.add %17, %18 overflow<nsw, nuw> : i64
      %20 = llvm.getelementptr inbounds|nuw %16[%19] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %21 = llvm.load %20 : !llvm.ptr -> f32
      %22 = llvm.fadd %15, %21 : f32
      %23 = llvm.mul %5, %0 overflow<nsw, nuw> : i64
      %24 = llvm.add %23, %9 overflow<nsw, nuw> : i64
      %25 = llvm.getelementptr inbounds|nuw %arg15[%24] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %22, %25 : f32, !llvm.ptr
      llvm.return
    }
  }
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c4 = arith.constant 4 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    gpu.launch_func  @add_then_mul_kernel::@add_then_mul_kernel blocks in (%c4, %c4, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %alloc : memref<8x8xf32>)
    return %alloc : memref<8x8xf32>
  }
  gpu.module @add_then_mul_kernel {
    llvm.func @add_then_mul_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: !llvm.ptr, %arg22: !llvm.ptr, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: i64, %arg27: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 2, 2, 1>, gpu.known_grid_size = array<i32: 4, 4, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 2, 2, 1>} {
      %0 = llvm.mlir.constant(8 : index) : i64
      %1 = llvm.mlir.constant(2 : index) : i64
      %2 = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 4> : i32
      %3 = llvm.sext %2 : i32 to i64
      %4 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 4> : i32
      %5 = llvm.sext %4 : i32 to i64
      %6 = nvvm.read.ptx.sreg.tid.x range <i32, 0, 2> : i32
      %7 = llvm.sext %6 : i32 to i64
      %8 = nvvm.read.ptx.sreg.tid.y range <i32, 0, 2> : i32
      %9 = llvm.sext %8 : i32 to i64
      %10 = llvm.mul %3, %1 overflow<nsw> : i64
      %11 = llvm.mul %5, %1 overflow<nsw> : i64
      %12 = llvm.add %7, %10 : i64
      %13 = llvm.add %9, %11 : i64
      %14 = llvm.getelementptr %arg1[%arg2] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %15 = llvm.mul %12, %arg5 overflow<nsw, nuw> : i64
      %16 = llvm.mul %13, %arg6 overflow<nsw, nuw> : i64
      %17 = llvm.add %15, %16 overflow<nsw, nuw> : i64
      %18 = llvm.getelementptr inbounds|nuw %14[%17] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %19 = llvm.load %18 : !llvm.ptr -> f32
      %20 = llvm.getelementptr %arg8[%arg9] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %21 = llvm.mul %12, %arg12 overflow<nsw, nuw> : i64
      %22 = llvm.mul %13, %arg13 overflow<nsw, nuw> : i64
      %23 = llvm.add %21, %22 overflow<nsw, nuw> : i64
      %24 = llvm.getelementptr inbounds|nuw %20[%23] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %25 = llvm.load %24 : !llvm.ptr -> f32
      %26 = llvm.getelementptr %arg15[%arg16] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %27 = llvm.mul %12, %arg19 overflow<nsw, nuw> : i64
      %28 = llvm.mul %13, %arg20 overflow<nsw, nuw> : i64
      %29 = llvm.add %27, %28 overflow<nsw, nuw> : i64
      %30 = llvm.getelementptr inbounds|nuw %26[%29] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %31 = llvm.load %30 : !llvm.ptr -> f32
      %32 = llvm.fadd %19, %25 : f32
      %33 = llvm.fmul %32, %31 : f32
      %34 = llvm.mul %12, %0 overflow<nsw, nuw> : i64
      %35 = llvm.add %34, %13 overflow<nsw, nuw> : i64
      %36 = llvm.getelementptr inbounds|nuw %arg22[%35] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %33, %36 : f32, !llvm.ptr
      llvm.return
    }
  }
}

