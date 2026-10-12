module attributes {gpu.container_module} {
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @ictest(%arg0: i32) -> i32 attributes {llvm.emit_c_interface} {
    %0 = llvm.add %arg0, %arg0 : i32
    llvm.return %0 : i32
  }
  llvm.func @_mlir_ciface_ictest(%arg0: i32) -> i32 attributes {llvm.emit_c_interface} {
    %0 = llvm.call @ictest(%arg0) : (i32) -> i32
    llvm.return %0 : i32
  }
  llvm.func @add_zero(%arg0: i32) -> i32 attributes {llvm.emit_c_interface} {
    llvm.return %arg0 : i32
  }
  llvm.func @_mlir_ciface_add_zero(%arg0: i32) -> i32 attributes {llvm.emit_c_interface} {
    %0 = llvm.call @add_zero(%arg0) : (i32) -> i32
    llvm.return %0 : i32
  }
  llvm.func @keep_add(%arg0: i32, %arg1: i32) -> i32 attributes {llvm.emit_c_interface} {
    %0 = llvm.add %arg0, %arg1 : i32
    llvm.return %0 : i32
  }
  llvm.func @_mlir_ciface_keep_add(%arg0: i32, %arg1: i32) -> i32 attributes {llvm.emit_c_interface} {
    %0 = llvm.call @keep_add(%arg0, %arg1) : (i32, i32) -> i32
    llvm.return %0 : i32
  }
  llvm.func @matmul(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.constant(2 : index) : i64
    %1 = llvm.mlir.constant(3 : index) : i64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %5 = llvm.insertvalue %arg7, %4[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg8, %5[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg9, %6[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg10, %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg12, %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg11, %9[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg13, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg0, %4[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg1, %12[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg2, %13[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg3, %14[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg5, %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.insertvalue %arg4, %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg6, %17[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg14, %4[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg15, %19[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg16, %20[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg17, %21[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg19, %22[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %arg18, %23[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.insertvalue %arg20, %24[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.extractvalue %18[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = llvm.extractvalue %18[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.extractvalue %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.extractvalue %18[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.extractvalue %18[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.extractvalue %18[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.extractvalue %18[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.extractvalue %11[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.extractvalue %11[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.extractvalue %11[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.extractvalue %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.extractvalue %11[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.extractvalue %11[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.extractvalue %11[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.extractvalue %25[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.extractvalue %25[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.extractvalue %25[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %25[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %25[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %25[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%2, %0, %2) threads in (%0, %0, %2) : i64 args(%26 : !llvm.ptr, %27 : !llvm.ptr, %28 : i64, %29 : i64, %30 : i64, %31 : i64, %32 : i64, %33 : !llvm.ptr, %34 : !llvm.ptr, %35 : i64, %36 : i64, %37 : i64, %38 : i64, %39 : i64, %40 : !llvm.ptr, %41 : !llvm.ptr, %42 : i64, %43 : i64, %44 : i64, %45 : i64, %46 : i64, %3 : i64, %1 : i64, %2 : i64)
    llvm.return %25 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_matmul(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg3 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.extractvalue %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.extractvalue %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.call @matmul(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21, %22, %23) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %24, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
  gpu.binary @matmul_kernel  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 2 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09matmul_kernel\0A\0A.visible .entry matmul_kernel(\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_0,\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_1,\0A\09.param .u64 matmul_kernel_param_2,\0A\09.param .u64 matmul_kernel_param_3,\0A\09.param .u64 matmul_kernel_param_4,\0A\09.param .u64 matmul_kernel_param_5,\0A\09.param .u64 matmul_kernel_param_6,\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_7,\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_8,\0A\09.param .u64 matmul_kernel_param_9,\0A\09.param .u64 matmul_kernel_param_10,\0A\09.param .u64 matmul_kernel_param_11,\0A\09.param .u64 matmul_kernel_param_12,\0A\09.param .u64 matmul_kernel_param_13,\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_14,\0A\09.param .u64 .ptr .align 1 matmul_kernel_param_15,\0A\09.param .u64 matmul_kernel_param_16,\0A\09.param .u64 matmul_kernel_param_17,\0A\09.param .u64 matmul_kernel_param_18,\0A\09.param .u64 matmul_kernel_param_19,\0A\09.param .u64 matmul_kernel_param_20,\0A\09.param .u64 matmul_kernel_param_21,\0A\09.param .u64 matmul_kernel_param_22,\0A\09.param .u64 matmul_kernel_param_23\0A)\0A.maxntid 2, 2, 1\0A{\0A\09.reg .pred \09%p<3>;\0A\09.reg .b32 \09%r<13>;\0A\09.reg .b64 \09%rd<58>;\0A\0A\09ld.param.b64 \09%rd25, [matmul_kernel_param_22];\0A\09ld.param.b64 \09%rd57, [matmul_kernel_param_21];\0A\09ld.param.b64 \09%rd27, [matmul_kernel_param_1];\0A\09cvta.to.global.u64 \09%rd1, %rd27;\0A\09ld.param.b64 \09%rd28, [matmul_kernel_param_8];\0A\09cvta.to.global.u64 \09%rd2, %rd28;\0A\09ld.param.b64 \09%rd29, [matmul_kernel_param_15];\0A\09cvta.to.global.u64 \09%rd3, %rd29;\0A\09setp.ge.s64 \09%p1, %rd57, %rd25;\0A\09@%p1 bra \09$L__BB0_3;\0A\09ld.param.b64 \09%rd26, [matmul_kernel_param_23];\0A\09ld.param.b64 \09%rd23, [matmul_kernel_param_20];\0A\09ld.param.b64 \09%rd22, [matmul_kernel_param_19];\0A\09ld.param.b64 \09%rd21, [matmul_kernel_param_16];\0A\09ld.param.b64 \09%rd20, [matmul_kernel_param_13];\0A\09ld.param.b64 \09%rd19, [matmul_kernel_param_12];\0A\09ld.param.b64 \09%rd18, [matmul_kernel_param_9];\0A\09ld.param.b64 \09%rd17, [matmul_kernel_param_6];\0A\09ld.param.b64 \09%rd16, [matmul_kernel_param_5];\0A\09ld.param.b64 \09%rd15, [matmul_kernel_param_2];\0A\09mov.u32 \09%r4, %ctaid.y;\0A\09shl.b32 \09%r5, %r4, 1;\0A\09mov.u32 \09%r6, %tid.y;\0A\09or.b32 \09%r7, %r5, %r6;\0A\09cvt.u64.u32 \09%rd30, %r7;\0A\09mov.u32 \09%r8, %tid.x;\0A\09cvt.u64.u32 \09%rd31, %r8;\0A\09shl.b64 \09%rd32, %rd21, 2;\0A\09add.s64 \09%rd33, %rd3, %rd32;\0A\09mul.lo.s64 \09%rd34, %rd22, %rd31;\0A\09mul.lo.s64 \09%rd35, %rd23, %rd30;\0A\09shl.b64 \09%rd36, %rd34, 2;\0A\09add.s64 \09%rd37, %rd33, %rd36;\0A\09shl.b64 \09%rd38, %rd35, 2;\0A\09add.s64 \09%rd4, %rd37, %rd38;\0A\09ld.global.b32 \09%r12, [%rd4];\0A\09mul.lo.s64 \09%rd39, %rd57, %rd19;\0A\09shl.b64 \09%rd40, %rd39, 2;\0A\09mul.lo.s64 \09%rd41, %rd20, %rd30;\0A\09shl.b64 \09%rd42, %rd41, 2;\0A\09add.s64 \09%rd43, %rd40, %rd42;\0A\09shl.b64 \09%rd44, %rd18, 2;\0A\09add.s64 \09%rd45, %rd43, %rd44;\0A\09add.s64 \09%rd56, %rd2, %rd45;\0A\09mul.lo.s64 \09%rd46, %rd26, %rd19;\0A\09shl.b64 \09%rd6, %rd46, 2;\0A\09mul.lo.s64 \09%rd47, %rd57, %rd17;\0A\09shl.b64 \09%rd48, %rd47, 2;\0A\09mul.lo.s64 \09%rd49, %rd16, %rd31;\0A\09shl.b64 \09%rd50, %rd49, 2;\0A\09add.s64 \09%rd51, %rd48, %rd50;\0A\09shl.b64 \09%rd52, %rd15, 2;\0A\09add.s64 \09%rd53, %rd51, %rd52;\0A\09add.s64 \09%rd55, %rd1, %rd53;\0A\09mul.lo.s64 \09%rd54, %rd26, %rd17;\0A\09shl.b64 \09%rd8, %rd54, 2;\0A$L__BB0_2:\0A\09ld.global.b32 \09%r9, [%rd55];\0A\09ld.global.b32 \09%r10, [%rd56];\0A\09mul.rn.f32 \09%r11, %r9, %r10;\0A\09add.rn.f32 \09%r12, %r12, %r11;\0A\09st.global.b32 \09[%rd4], %r12;\0A\09add.s64 \09%rd57, %rd57, %rd26;\0A\09add.s64 \09%rd56, %rd56, %rd6;\0A\09add.s64 \09%rd55, %rd55, %rd8;\0A\09setp.lt.s64 \09%p2, %rd57, %rd25;\0A\09@%p2 bra \09$L__BB0_2;\0A$L__BB0_3:\0A\09ret;\0A\0A}\0A">]
  llvm.func @matmul_generic(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.constant(-1 : index) : i64
    %1 = llvm.mlir.constant(2 : index) : i64
    %2 = llvm.mlir.constant(5 : index) : i64
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.mlir.constant(0 : index) : i64
    %5 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %6 = llvm.insertvalue %arg14, %5[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg15, %6[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg16, %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg17, %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg19, %9[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg18, %10[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg20, %11[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%4 : i64)
  ^bb1(%13: i64):  // 2 preds: ^bb0, ^bb11
    %14 = llvm.icmp "slt" %13, %2 : i64
    llvm.cond_br %14, ^bb2, ^bb12
  ^bb2:  // pred: ^bb1
    %15 = llvm.mul %13, %0 overflow<nsw> : i64
    %16 = llvm.add %15, %2 : i64
    %17 = llvm.intr.smin(%16, %1) : (i64, i64) -> i64
    llvm.br ^bb3(%4 : i64)
  ^bb3(%18: i64):  // 2 preds: ^bb2, ^bb10
    %19 = llvm.icmp "slt" %18, %1 : i64
    llvm.cond_br %19, ^bb4, ^bb11
  ^bb4:  // pred: ^bb3
    llvm.br ^bb5(%4 : i64)
  ^bb5(%20: i64):  // 2 preds: ^bb4, ^bb9
    %21 = llvm.icmp "slt" %20, %17 : i64
    llvm.cond_br %21, ^bb6, ^bb10
  ^bb6:  // pred: ^bb5
    %22 = llvm.add %20, %13 : i64
    llvm.br ^bb7(%4 : i64)
  ^bb7(%23: i64):  // 2 preds: ^bb6, ^bb8
    %24 = llvm.icmp "slt" %23, %2 : i64
    llvm.cond_br %24, ^bb8, ^bb9
  ^bb8:  // pred: ^bb7
    %25 = llvm.getelementptr %arg1[%arg2] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %26 = llvm.mul %18, %arg5 overflow<nsw, nuw> : i64
    %27 = llvm.mul %23, %arg6 overflow<nsw, nuw> : i64
    %28 = llvm.add %26, %27 overflow<nsw, nuw> : i64
    %29 = llvm.getelementptr inbounds|nuw %25[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %30 = llvm.load %29 : !llvm.ptr -> f32
    %31 = llvm.getelementptr %arg8[%arg9] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %32 = llvm.mul %23, %arg12 overflow<nsw, nuw> : i64
    %33 = llvm.mul %22, %arg13 overflow<nsw, nuw> : i64
    %34 = llvm.add %32, %33 overflow<nsw, nuw> : i64
    %35 = llvm.getelementptr inbounds|nuw %31[%34] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %36 = llvm.load %35 : !llvm.ptr -> f32
    %37 = llvm.getelementptr %arg15[%arg16] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %38 = llvm.mul %18, %arg19 overflow<nsw, nuw> : i64
    %39 = llvm.mul %22, %arg20 overflow<nsw, nuw> : i64
    %40 = llvm.add %38, %39 overflow<nsw, nuw> : i64
    %41 = llvm.getelementptr inbounds|nuw %37[%40] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %42 = llvm.load %41 : !llvm.ptr -> f32
    %43 = llvm.fmul %30, %36 : f32
    %44 = llvm.fadd %42, %43 : f32
    %45 = llvm.getelementptr %arg15[%arg16] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %46 = llvm.mul %18, %arg19 overflow<nsw, nuw> : i64
    %47 = llvm.mul %22, %arg20 overflow<nsw, nuw> : i64
    %48 = llvm.add %46, %47 overflow<nsw, nuw> : i64
    %49 = llvm.getelementptr inbounds|nuw %45[%48] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %44, %49 : f32, !llvm.ptr
    %50 = llvm.add %23, %3 : i64
    llvm.br ^bb7(%50 : i64)
  ^bb9:  // pred: ^bb7
    %51 = llvm.add %20, %3 : i64
    llvm.br ^bb5(%51 : i64)
  ^bb10:  // pred: ^bb5
    %52 = llvm.add %18, %3 : i64
    llvm.br ^bb3(%52 : i64)
  ^bb11:  // pred: ^bb3
    %53 = llvm.add %13, %1 : i64
    llvm.br ^bb1(%53 : i64)
  ^bb12:  // pred: ^bb1
    llvm.return %12 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_matmul_generic(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg3 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.extractvalue %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.extractvalue %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.call @matmul_generic(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21, %22, %23) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %24, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
  llvm.func @elementwise_add(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.constant(0 : index) : i64
    %1 = llvm.mlir.constant(64 : index) : i64
    %2 = llvm.mlir.zero : !llvm.ptr
    %3 = llvm.mlir.constant(4 : index) : i64
    %4 = llvm.mlir.constant(1 : index) : i64
    %5 = llvm.mlir.constant(2 : index) : i64
    %6 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %7 = llvm.insertvalue %arg7, %6[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg8, %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg9, %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg10, %9[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg12, %10[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg11, %11[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg13, %12[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg0, %6[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg1, %14[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg2, %15[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.insertvalue %arg3, %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg5, %17[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg4, %18[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg6, %19[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.getelementptr %2[8] : (!llvm.ptr) -> !llvm.ptr, f32
    %22 = llvm.ptrtoint %21 : !llvm.ptr to i64
    %23 = llvm.add %22, %1 : i64
    %24 = llvm.call @malloc(%23) : (i64) -> !llvm.ptr
    %25 = llvm.ptrtoint %24 : !llvm.ptr to i64
    %26 = llvm.sub %1, %4 : i64
    %27 = llvm.add %25, %26 : i64
    %28 = llvm.urem %27, %1 : i64
    %29 = llvm.sub %27, %28 : i64
    %30 = llvm.inttoptr %29 : i64 to !llvm.ptr
    %31 = llvm.insertvalue %24, %6[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.insertvalue %30, %31[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.insertvalue %0, %32[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.insertvalue %5, %33[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.insertvalue %3, %34[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.insertvalue %3, %35[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.insertvalue %4, %36[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.extractvalue %20[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.extractvalue %20[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.extractvalue %20[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.extractvalue %20[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.extractvalue %20[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.extractvalue %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %20[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %13[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %13[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.extractvalue %13[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.extractvalue %13[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.extractvalue %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.extractvalue %13[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.extractvalue %13[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.extractvalue %37[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.extractvalue %37[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.extractvalue %37[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %55 = llvm.extractvalue %37[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %56 = llvm.extractvalue %37[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %57 = llvm.extractvalue %37[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %58 = llvm.extractvalue %37[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @elementwise_add_kernel::@elementwise_add_kernel blocks in (%4, %5, %4) threads in (%5, %5, %4) : i64 args(%38 : !llvm.ptr, %39 : !llvm.ptr, %40 : i64, %41 : i64, %42 : i64, %43 : i64, %44 : i64, %45 : !llvm.ptr, %46 : !llvm.ptr, %47 : i64, %48 : i64, %49 : i64, %50 : i64, %51 : i64, %52 : !llvm.ptr, %53 : !llvm.ptr, %54 : i64, %55 : i64, %56 : i64, %57 : i64, %58 : i64)
    llvm.return %37 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_elementwise_add(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg3 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.extractvalue %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.extractvalue %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.call @elementwise_add(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21, %22, %23) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %24, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
  gpu.binary @elementwise_add_kernel  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 1 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09elementwise_add_kernel\0A\0A.visible .entry elementwise_add_kernel(\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_0,\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_1,\0A\09.param .u64 elementwise_add_kernel_param_2,\0A\09.param .u64 elementwise_add_kernel_param_3,\0A\09.param .u64 elementwise_add_kernel_param_4,\0A\09.param .u64 elementwise_add_kernel_param_5,\0A\09.param .u64 elementwise_add_kernel_param_6,\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_7,\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_8,\0A\09.param .u64 elementwise_add_kernel_param_9,\0A\09.param .u64 elementwise_add_kernel_param_10,\0A\09.param .u64 elementwise_add_kernel_param_11,\0A\09.param .u64 elementwise_add_kernel_param_12,\0A\09.param .u64 elementwise_add_kernel_param_13,\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_14,\0A\09.param .u64 .ptr .align 1 elementwise_add_kernel_param_15,\0A\09.param .u64 elementwise_add_kernel_param_16,\0A\09.param .u64 elementwise_add_kernel_param_17,\0A\09.param .u64 elementwise_add_kernel_param_18,\0A\09.param .u64 elementwise_add_kernel_param_19,\0A\09.param .u64 elementwise_add_kernel_param_20\0A)\0A.maxntid 2, 2, 1\0A{\0A\09.reg .b32 \09%r<9>;\0A\09.reg .b64 \09%rd<35>;\0A\0A\09ld.param.b64 \09%rd1, [elementwise_add_kernel_param_1];\0A\09cvta.to.global.u64 \09%rd2, %rd1;\0A\09ld.param.b64 \09%rd3, [elementwise_add_kernel_param_8];\0A\09cvta.to.global.u64 \09%rd4, %rd3;\0A\09ld.param.b64 \09%rd5, [elementwise_add_kernel_param_2];\0A\09ld.param.b64 \09%rd6, [elementwise_add_kernel_param_15];\0A\09cvta.to.global.u64 \09%rd7, %rd6;\0A\09mov.u32 \09%r1, %ctaid.y;\0A\09ld.param.b64 \09%rd8, [elementwise_add_kernel_param_5];\0A\09mov.u32 \09%r2, %tid.x;\0A\09cvt.u64.u32 \09%rd9, %r2;\0A\09ld.param.b64 \09%rd10, [elementwise_add_kernel_param_6];\0A\09mov.u32 \09%r3, %tid.y;\0A\09shl.b32 \09%r4, %r1, 1;\0A\09or.b32 \09%r5, %r4, %r3;\0A\09ld.param.b64 \09%rd11, [elementwise_add_kernel_param_9];\0A\09cvt.u64.u32 \09%rd12, %r5;\0A\09shl.b64 \09%rd13, %rd5, 2;\0A\09add.s64 \09%rd14, %rd2, %rd13;\0A\09mul.lo.s64 \09%rd15, %rd8, %rd9;\0A\09ld.param.b64 \09%rd16, [elementwise_add_kernel_param_12];\0A\09mul.lo.s64 \09%rd17, %rd10, %rd12;\0A\09ld.param.b64 \09%rd18, [elementwise_add_kernel_param_13];\0A\09shl.b64 \09%rd19, %rd15, 2;\0A\09add.s64 \09%rd20, %rd14, %rd19;\0A\09shl.b64 \09%rd21, %rd17, 2;\0A\09add.s64 \09%rd22, %rd20, %rd21;\0A\09ld.global.b32 \09%r6, [%rd22];\0A\09shl.b64 \09%rd23, %rd11, 2;\0A\09add.s64 \09%rd24, %rd4, %rd23;\0A\09mul.lo.s64 \09%rd25, %rd16, %rd9;\0A\09mul.lo.s64 \09%rd26, %rd18, %rd12;\0A\09shl.b64 \09%rd27, %rd25, 2;\0A\09add.s64 \09%rd28, %rd24, %rd27;\0A\09shl.b64 \09%rd29, %rd26, 2;\0A\09add.s64 \09%rd30, %rd28, %rd29;\0A\09ld.global.b32 \09%r7, [%rd30];\0A\09add.rn.f32 \09%r8, %r6, %r7;\0A\09mul.wide.u32 \09%rd31, %r2, 16;\0A\09add.s64 \09%rd32, %rd7, %rd31;\0A\09mul.wide.u32 \09%rd33, %r5, 4;\0A\09add.s64 \09%rd34, %rd32, %rd33;\0A\09st.global.b32 \09[%rd34], %r8;\0A\09ret;\0A\0A}\0A">]
  llvm.func @add_then_mul(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: !llvm.ptr, %arg22: !llvm.ptr, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: i64, %arg27: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.constant(1 : index) : i64
    %1 = llvm.mlir.constant(2 : index) : i64
    %2 = llvm.mlir.constant(4 : index) : i64
    %3 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %4 = llvm.insertvalue %arg14, %3[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg15, %4[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg16, %5[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg17, %6[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg19, %7[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg18, %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg20, %9[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg7, %3[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg8, %11[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg9, %12[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg10, %13[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg12, %14[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg11, %15[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.insertvalue %arg13, %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg0, %3[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg1, %18[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg2, %19[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg3, %20[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg5, %21[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg4, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %arg6, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.mlir.constant(8 : index) : i64
    %26 = llvm.mlir.constant(8 : index) : i64
    %27 = llvm.mlir.constant(1 : index) : i64
    %28 = llvm.mlir.constant(64 : index) : i64
    %29 = llvm.mlir.zero : !llvm.ptr
    %30 = llvm.getelementptr %29[%28] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %31 = llvm.ptrtoint %30 : !llvm.ptr to i64
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.mlir.constant(1 : i8) : i8
    %34 = llvm.call @mgpuMemAlloc(%31, %32, %33) : (i64, !llvm.ptr, i8) -> !llvm.ptr
    %35 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %36 = llvm.insertvalue %34, %35[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.insertvalue %34, %36[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.mlir.constant(0 : index) : i64
    %39 = llvm.insertvalue %38, %37[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.insertvalue %25, %39[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.insertvalue %26, %40[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.insertvalue %26, %41[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.insertvalue %27, %42[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %24[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %24[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %24[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.extractvalue %24[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.extractvalue %24[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.extractvalue %24[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.extractvalue %24[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.extractvalue %17[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.extractvalue %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.extractvalue %17[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.extractvalue %17[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %55 = llvm.extractvalue %17[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %56 = llvm.extractvalue %17[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %57 = llvm.extractvalue %17[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %58 = llvm.extractvalue %10[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %59 = llvm.extractvalue %10[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %60 = llvm.extractvalue %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %61 = llvm.extractvalue %10[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %62 = llvm.extractvalue %10[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %63 = llvm.extractvalue %10[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %64 = llvm.extractvalue %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %65 = llvm.extractvalue %43[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %66 = llvm.extractvalue %43[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %67 = llvm.extractvalue %43[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %68 = llvm.extractvalue %43[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %69 = llvm.extractvalue %43[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %70 = llvm.extractvalue %43[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %71 = llvm.extractvalue %43[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @add_then_mul_kernel::@add_then_mul_kernel blocks in (%2, %2, %0) threads in (%1, %1, %0) : i64 args(%44 : !llvm.ptr, %45 : !llvm.ptr, %46 : i64, %47 : i64, %48 : i64, %49 : i64, %50 : i64, %51 : !llvm.ptr, %52 : !llvm.ptr, %53 : i64, %54 : i64, %55 : i64, %56 : i64, %57 : i64, %58 : !llvm.ptr, %59 : !llvm.ptr, %60 : i64, %61 : i64, %62 : i64, %63 : i64, %64 : i64, %65 : !llvm.ptr, %66 : !llvm.ptr, %67 : i64, %68 : i64, %69 : i64, %70 : i64, %71 : i64)
    llvm.return %43 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @_mlir_ciface_add_then_mul(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg3 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.extractvalue %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.extractvalue %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.load %arg4 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %25 = llvm.extractvalue %24[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.extractvalue %24[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = llvm.extractvalue %24[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.extractvalue %24[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.extractvalue %24[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.extractvalue %24[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.extractvalue %24[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.call @add_then_mul(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21, %22, %23, %25, %26, %27, %28, %29, %30, %31) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    llvm.store %32, %arg0 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    llvm.return
  }
  gpu.binary @add_then_mul_kernel  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 1 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09add_then_mul_kernel\0A\0A.visible .entry add_then_mul_kernel(\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_0,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_1,\0A\09.param .u64 add_then_mul_kernel_param_2,\0A\09.param .u64 add_then_mul_kernel_param_3,\0A\09.param .u64 add_then_mul_kernel_param_4,\0A\09.param .u64 add_then_mul_kernel_param_5,\0A\09.param .u64 add_then_mul_kernel_param_6,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_7,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_8,\0A\09.param .u64 add_then_mul_kernel_param_9,\0A\09.param .u64 add_then_mul_kernel_param_10,\0A\09.param .u64 add_then_mul_kernel_param_11,\0A\09.param .u64 add_then_mul_kernel_param_12,\0A\09.param .u64 add_then_mul_kernel_param_13,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_14,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_15,\0A\09.param .u64 add_then_mul_kernel_param_16,\0A\09.param .u64 add_then_mul_kernel_param_17,\0A\09.param .u64 add_then_mul_kernel_param_18,\0A\09.param .u64 add_then_mul_kernel_param_19,\0A\09.param .u64 add_then_mul_kernel_param_20,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_21,\0A\09.param .u64 .ptr .align 1 add_then_mul_kernel_param_22,\0A\09.param .u64 add_then_mul_kernel_param_23,\0A\09.param .u64 add_then_mul_kernel_param_24,\0A\09.param .u64 add_then_mul_kernel_param_25,\0A\09.param .u64 add_then_mul_kernel_param_26,\0A\09.param .u64 add_then_mul_kernel_param_27\0A)\0A.maxntid 2, 2, 1\0A{\0A\09.reg .b32 \09%r<14>;\0A\09.reg .b64 \09%rd<48>;\0A\0A\09ld.param.b64 \09%rd1, [add_then_mul_kernel_param_1];\0A\09cvta.to.global.u64 \09%rd2, %rd1;\0A\09ld.param.b64 \09%rd3, [add_then_mul_kernel_param_8];\0A\09cvta.to.global.u64 \09%rd4, %rd3;\0A\09ld.param.b64 \09%rd5, [add_then_mul_kernel_param_2];\0A\09ld.param.b64 \09%rd6, [add_then_mul_kernel_param_15];\0A\09cvta.to.global.u64 \09%rd7, %rd6;\0A\09ld.param.b64 \09%rd8, [add_then_mul_kernel_param_22];\0A\09cvta.to.global.u64 \09%rd9, %rd8;\0A\09ld.param.b64 \09%rd10, [add_then_mul_kernel_param_5];\0A\09mov.u32 \09%r1, %ctaid.x;\0A\09ld.param.b64 \09%rd11, [add_then_mul_kernel_param_6];\0A\09mov.u32 \09%r2, %ctaid.y;\0A\09mov.u32 \09%r3, %tid.x;\0A\09mov.u32 \09%r4, %tid.y;\0A\09shl.b32 \09%r5, %r1, 1;\0A\09ld.param.b64 \09%rd12, [add_then_mul_kernel_param_9];\0A\09shl.b32 \09%r6, %r2, 1;\0A\09or.b32 \09%r7, %r5, %r3;\0A\09cvt.u64.u32 \09%rd13, %r7;\0A\09ld.param.b64 \09%rd14, [add_then_mul_kernel_param_12];\0A\09or.b32 \09%r8, %r6, %r4;\0A\09ld.param.b64 \09%rd15, [add_then_mul_kernel_param_13];\0A\09cvt.u64.u32 \09%rd16, %r8;\0A\09shl.b64 \09%rd17, %rd5, 2;\0A\09add.s64 \09%rd18, %rd2, %rd17;\0A\09mul.lo.s64 \09%rd19, %rd10, %rd13;\0A\09ld.param.b64 \09%rd20, [add_then_mul_kernel_param_16];\0A\09mul.lo.s64 \09%rd21, %rd11, %rd16;\0A\09shl.b64 \09%rd22, %rd19, 2;\0A\09add.s64 \09%rd23, %rd18, %rd22;\0A\09shl.b64 \09%rd24, %rd21, 2;\0A\09add.s64 \09%rd25, %rd23, %rd24;\0A\09ld.param.b64 \09%rd26, [add_then_mul_kernel_param_19];\0A\09ld.global.b32 \09%r9, [%rd25];\0A\09ld.param.b64 \09%rd27, [add_then_mul_kernel_param_20];\0A\09shl.b64 \09%rd28, %rd12, 2;\0A\09add.s64 \09%rd29, %rd4, %rd28;\0A\09mul.lo.s64 \09%rd30, %rd14, %rd13;\0A\09mul.lo.s64 \09%rd31, %rd15, %rd16;\0A\09shl.b64 \09%rd32, %rd30, 2;\0A\09add.s64 \09%rd33, %rd29, %rd32;\0A\09shl.b64 \09%rd34, %rd31, 2;\0A\09add.s64 \09%rd35, %rd33, %rd34;\0A\09ld.global.b32 \09%r10, [%rd35];\0A\09shl.b64 \09%rd36, %rd20, 2;\0A\09add.s64 \09%rd37, %rd7, %rd36;\0A\09mul.lo.s64 \09%rd38, %rd26, %rd13;\0A\09mul.lo.s64 \09%rd39, %rd27, %rd16;\0A\09shl.b64 \09%rd40, %rd38, 2;\0A\09add.s64 \09%rd41, %rd37, %rd40;\0A\09shl.b64 \09%rd42, %rd39, 2;\0A\09add.s64 \09%rd43, %rd41, %rd42;\0A\09ld.global.b32 \09%r11, [%rd43];\0A\09add.rn.f32 \09%r12, %r9, %r10;\0A\09mul.rn.f32 \09%r13, %r12, %r11;\0A\09mul.wide.u32 \09%rd44, %r7, 32;\0A\09add.s64 \09%rd45, %rd9, %rd44;\0A\09mul.wide.u32 \09%rd46, %r8, 4;\0A\09add.s64 \09%rd47, %rd45, %rd46;\0A\09st.global.b32 \09[%rd47], %r13;\0A\09ret;\0A\0A}\0A">]
  llvm.func @mgpuMemAlloc(i64, !llvm.ptr, i8) -> !llvm.ptr
}

