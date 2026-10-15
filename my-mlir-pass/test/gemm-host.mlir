module attributes {gpu.container_module} {
  llvm.func @gemm(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) attributes {llvm.emit_c_interface} {
    %0 = llvm.mlir.constant(8 : index) : i64
    %1 = llvm.mlir.constant(1 : index) : i64
    %2 = llvm.mlir.constant(64 : index) : i64
    %3 = llvm.mlir.constant(0 : index) : i64
    %4 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %5 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %6 = llvm.insertvalue %arg14, %5[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg15, %6[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.insertvalue %arg16, %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %9 = llvm.insertvalue %arg17, %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg19, %9[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg18, %10[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg20, %11[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg7, %5[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg8, %13[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg9, %14[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.insertvalue %arg10, %15[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %17 = llvm.insertvalue %arg12, %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg11, %17[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg13, %18[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg0, %5[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg1, %20[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg2, %21[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg3, %22[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %arg5, %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.insertvalue %arg4, %24[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.insertvalue %arg6, %25[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.extractvalue %12[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.extractvalue %12[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.extractvalue %12[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.extractvalue %12[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.extractvalue %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.extractvalue %12[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @gemm_kernel::@gemm_kernel blocks in (%0, %0, %1) threads in (%0, %0, %1) : i64 args(%4 : f32, %27 : !llvm.ptr, %28 : !llvm.ptr, %29 : i64, %30 : i64, %31 : i64, %32 : i64, %33 : i64)
    %34 = llvm.extractvalue %26[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.extractvalue %26[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %36 = llvm.extractvalue %26[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.extractvalue %26[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.extractvalue %26[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.extractvalue %26[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.extractvalue %26[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.extractvalue %19[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.extractvalue %19[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.extractvalue %19[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %19[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %19[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.extractvalue %19[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.extractvalue %12[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.extractvalue %12[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.extractvalue %12[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.extractvalue %12[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.extractvalue %12[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.extractvalue %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.extractvalue %12[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @gemm_kernel_0::@gemm_kernel blocks in (%0, %0, %1) threads in (%0, %0, %1) : i64 args(%34 : !llvm.ptr, %35 : !llvm.ptr, %36 : i64, %37 : i64, %38 : i64, %39 : i64, %40 : i64, %41 : !llvm.ptr, %42 : !llvm.ptr, %43 : i64, %44 : i64, %45 : i64, %46 : i64, %47 : i64, %48 : !llvm.ptr, %49 : !llvm.ptr, %50 : i64, %51 : i64, %52 : i64, %53 : i64, %54 : i64, %3 : i64, %2 : i64, %1 : i64)
    llvm.return
  }
  llvm.func @_mlir_ciface_gemm(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr) attributes {llvm.emit_c_interface} {
    %0 = llvm.load %arg0 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.extractvalue %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.extractvalue %0[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.extractvalue %0[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.extractvalue %0[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.extractvalue %0[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.extractvalue %0[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.extractvalue %0[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.load %arg1 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.extractvalue %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.extractvalue %8[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.extractvalue %8[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.extractvalue %8[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.extractvalue %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.extractvalue %8[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.extractvalue %8[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.load %arg2 : !llvm.ptr -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.extractvalue %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.extractvalue %16[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.extractvalue %16[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.extractvalue %16[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.extractvalue %16[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.extractvalue %16[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.extractvalue %16[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @gemm(%1, %2, %3, %4, %5, %6, %7, %9, %10, %11, %12, %13, %14, %15, %17, %18, %19, %20, %21, %22, %23) : (!llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64, !llvm.ptr, !llvm.ptr, i64, i64, i64, i64, i64) -> ()
    llvm.return
  }
  gpu.binary @gemm_kernel  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 1 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09gemm_kernel\0A\0A.visible .entry gemm_kernel(\0A\09.param .f32 gemm_kernel_param_0,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_1,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_2,\0A\09.param .u64 gemm_kernel_param_3,\0A\09.param .u64 gemm_kernel_param_4,\0A\09.param .u64 gemm_kernel_param_5,\0A\09.param .u64 gemm_kernel_param_6,\0A\09.param .u64 gemm_kernel_param_7\0A)\0A.maxntid 8, 8, 1\0A{\0A\09.reg .b32 \09%r<12>;\0A\09.reg .b64 \09%rd<5>;\0A\0A\09ld.param.b32 \09%r1, [gemm_kernel_param_0];\0A\09ld.param.b64 \09%rd1, [gemm_kernel_param_2];\0A\09cvta.to.global.u64 \09%rd2, %rd1;\0A\09mov.u32 \09%r2, %ctaid.x;\0A\09mov.u32 \09%r3, %ctaid.y;\0A\09mov.u32 \09%r4, %tid.x;\0A\09mov.u32 \09%r5, %tid.y;\0A\09shl.b32 \09%r6, %r3, 3;\0A\09or.b32 \09%r7, %r6, %r5;\0A\09shl.b32 \09%r8, %r2, 9;\0A\09shl.b32 \09%r9, %r4, 6;\0A\09or.b32 \09%r10, %r8, %r9;\0A\09or.b32 \09%r11, %r10, %r7;\0A\09mul.wide.u32 \09%rd3, %r11, 4;\0A\09add.s64 \09%rd4, %rd2, %rd3;\0A\09st.global.b32 \09[%rd4], %r1;\0A\09ret;\0A\0A}\0A">]
  gpu.binary @gemm_kernel_0  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 2 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09gemm_kernel\0A\0A.visible .entry gemm_kernel(\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_0,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_1,\0A\09.param .u64 gemm_kernel_param_2,\0A\09.param .u64 gemm_kernel_param_3,\0A\09.param .u64 gemm_kernel_param_4,\0A\09.param .u64 gemm_kernel_param_5,\0A\09.param .u64 gemm_kernel_param_6,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_7,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_8,\0A\09.param .u64 gemm_kernel_param_9,\0A\09.param .u64 gemm_kernel_param_10,\0A\09.param .u64 gemm_kernel_param_11,\0A\09.param .u64 gemm_kernel_param_12,\0A\09.param .u64 gemm_kernel_param_13,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_14,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_15,\0A\09.param .u64 gemm_kernel_param_16,\0A\09.param .u64 gemm_kernel_param_17,\0A\09.param .u64 gemm_kernel_param_18,\0A\09.param .u64 gemm_kernel_param_19,\0A\09.param .u64 gemm_kernel_param_20,\0A\09.param .u64 gemm_kernel_param_21,\0A\09.param .u64 gemm_kernel_param_22,\0A\09.param .u64 gemm_kernel_param_23\0A)\0A.maxntid 8, 8, 1\0A{\0A\09.reg .pred \09%p<3>;\0A\09.reg .b32 \09%r<18>;\0A\09.reg .b64 \09%rd<33>;\0A\0A\09ld.param.b64 \09%rd17, [gemm_kernel_param_22];\0A\09ld.param.b64 \09%rd32, [gemm_kernel_param_21];\0A\09ld.param.b64 \09%rd19, [gemm_kernel_param_8];\0A\09cvta.to.global.u64 \09%rd1, %rd19;\0A\09ld.param.b64 \09%rd20, [gemm_kernel_param_1];\0A\09ld.param.b64 \09%rd21, [gemm_kernel_param_15];\0A\09cvta.to.global.u64 \09%rd2, %rd21;\0A\09cvta.to.global.u64 \09%rd3, %rd20;\0A\09setp.ge.s64 \09%p1, %rd32, %rd17;\0A\09@%p1 bra \09$L__BB0_3;\0A\09ld.param.b64 \09%rd18, [gemm_kernel_param_23];\0A\09mov.u32 \09%r6, %ctaid.y;\0A\09mov.u32 \09%r1, %tid.y;\0A\09shl.b32 \09%r2, %r6, 3;\0A\09or.b32 \09%r7, %r2, %r1;\0A\09cvt.u64.u32 \09%rd4, %r7;\0A\09shl.b64 \09%rd22, %rd4, 2;\0A\09add.s64 \09%rd23, %rd2, %rd22;\0A\09mov.u32 \09%r8, %tid.x;\0A\09mov.u32 \09%r9, %ctaid.x;\0A\09shl.b32 \09%r10, %r9, 9;\0A\09shl.b32 \09%r11, %r8, 6;\0A\09or.b32 \09%r12, %r10, %r11;\0A\09mul.wide.u32 \09%rd24, %r12, 4;\0A\09add.s64 \09%rd5, %rd23, %rd24;\0A\09ld.global.b32 \09%r17, [%rd5];\0A\09shl.b64 \09%rd25, %rd32, 2;\0A\09add.s64 \09%rd26, %rd25, %rd24;\0A\09add.s64 \09%rd31, %rd3, %rd26;\0A\09shl.b64 \09%rd7, %rd18, 2;\0A\09shl.b64 \09%rd27, %rd32, 8;\0A\09add.s32 \09%r13, %r1, %r2;\0A\09mul.wide.u32 \09%rd28, %r13, 4;\0A\09add.s64 \09%rd29, %rd27, %rd28;\0A\09add.s64 \09%rd30, %rd1, %rd29;\0A\09shl.b64 \09%rd9, %rd18, 8;\0A$L__BB0_2:\0A\09ld.global.b32 \09%r14, [%rd31];\0A\09ld.global.b32 \09%r15, [%rd30];\0A\09mul.rn.f32 \09%r16, %r14, %r15;\0A\09add.rn.f32 \09%r17, %r16, %r17;\0A\09st.global.b32 \09[%rd5], %r17;\0A\09add.s64 \09%rd32, %rd32, %rd18;\0A\09add.s64 \09%rd31, %rd31, %rd7;\0A\09add.s64 \09%rd30, %rd30, %rd9;\0A\09setp.lt.s64 \09%p2, %rd32, %rd17;\0A\09@%p2 bra \09$L__BB0_2;\0A$L__BB0_3:\0A\09ret;\0A\0A}\0A">]
}

