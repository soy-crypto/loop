module attributes {gpu.container_module} {
  llvm.func @gemm(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: i64, %arg20: i64) attributes {llvm.emit_c_interface, toy.accumulator_safe} {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg7, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg8, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg9, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg10, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg12, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg11, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg13, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg0, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg1, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg2, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg3, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg5, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg4, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg6, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %17 = llvm.insertvalue %arg14, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %18 = llvm.insertvalue %arg15, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %19 = llvm.insertvalue %arg16, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %20 = llvm.insertvalue %arg17, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %21 = llvm.insertvalue %arg19, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %22 = llvm.insertvalue %arg18, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %23 = llvm.insertvalue %arg20, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %25 = llvm.mlir.constant(0 : index) : i64
    %26 = llvm.mlir.constant(64 : index) : i64
    %27 = llvm.mlir.constant(1 : index) : i64
    %28 = llvm.mlir.constant(8 : index) : i64
    %29 = llvm.extractvalue %23[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.extractvalue %23[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.extractvalue %23[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.extractvalue %23[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.extractvalue %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.extractvalue %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @gemm_kernel::@gemm_kernel blocks in (%28, %28, %27) threads in (%28, %28, %27) : i64 args(%24 : f32, %29 : !llvm.ptr, %30 : !llvm.ptr, %31 : i64, %32 : i64, %33 : i64, %34 : i64, %35 : i64)
    %36 = llvm.extractvalue %23[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %37 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %38 = llvm.extractvalue %23[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %39 = llvm.extractvalue %23[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %40 = llvm.extractvalue %23[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %41 = llvm.extractvalue %23[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %42 = llvm.extractvalue %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %43 = llvm.extractvalue %15[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %44 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.extractvalue %15[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.extractvalue %15[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.extractvalue %15[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.extractvalue %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.extractvalue %15[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.extractvalue %7[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.extractvalue %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.extractvalue %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.extractvalue %7[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %55 = llvm.extractvalue %7[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %56 = llvm.extractvalue %7[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @gemm_kernel_0::@gemm_kernel blocks in (%28, %28, %27) threads in (%28, %28, %27) : i64 args(%36 : !llvm.ptr, %37 : !llvm.ptr, %38 : i64, %39 : i64, %40 : i64, %41 : i64, %42 : i64, %43 : !llvm.ptr, %44 : !llvm.ptr, %45 : i64, %46 : i64, %47 : i64, %48 : i64, %49 : i64, %50 : !llvm.ptr, %51 : !llvm.ptr, %52 : i64, %53 : i64, %54 : i64, %55 : i64, %56 : i64, %25 : i64, %26 : i64, %27 : i64)
    llvm.return
  }
  llvm.func @_mlir_ciface_gemm(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr) attributes {llvm.emit_c_interface, toy.accumulator_safe} {
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
  gpu.binary @gemm_kernel_0  [#gpu.object<#nvvm.target<chip = "sm_86", features = "+ptx80">, properties = {LLVMIRToISATimeInMs = 1 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 8.0\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09gemm_kernel\0A\0A.visible .entry gemm_kernel(\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_0,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_1,\0A\09.param .u64 gemm_kernel_param_2,\0A\09.param .u64 gemm_kernel_param_3,\0A\09.param .u64 gemm_kernel_param_4,\0A\09.param .u64 gemm_kernel_param_5,\0A\09.param .u64 gemm_kernel_param_6,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_7,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_8,\0A\09.param .u64 gemm_kernel_param_9,\0A\09.param .u64 gemm_kernel_param_10,\0A\09.param .u64 gemm_kernel_param_11,\0A\09.param .u64 gemm_kernel_param_12,\0A\09.param .u64 gemm_kernel_param_13,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_14,\0A\09.param .u64 .ptr .align 1 gemm_kernel_param_15,\0A\09.param .u64 gemm_kernel_param_16,\0A\09.param .u64 gemm_kernel_param_17,\0A\09.param .u64 gemm_kernel_param_18,\0A\09.param .u64 gemm_kernel_param_19,\0A\09.param .u64 gemm_kernel_param_20,\0A\09.param .u64 gemm_kernel_param_21,\0A\09.param .u64 gemm_kernel_param_22,\0A\09.param .u64 gemm_kernel_param_23\0A)\0A.maxntid 8, 8, 1\0A{\0A\09.reg .pred \09%p<3>;\0A\09.reg .b32 \09%r<19>;\0A\09.reg .b64 \09%rd<35>;\0A\0A\09ld.param.b64 \09%rd17, [gemm_kernel_param_22];\0A\09ld.param.b64 \09%rd34, [gemm_kernel_param_21];\0A\09ld.param.b64 \09%rd19, [gemm_kernel_param_1];\0A\09cvta.to.global.u64 \09%rd20, %rd19;\0A\09ld.param.b64 \09%rd21, [gemm_kernel_param_8];\0A\09cvta.to.global.u64 \09%rd1, %rd21;\0A\09ld.param.b64 \09%rd22, [gemm_kernel_param_15];\0A\09cvta.to.global.u64 \09%rd2, %rd22;\0A\09mov.u32 \09%r5, %ctaid.x;\0A\09mov.u32 \09%r6, %ctaid.y;\0A\09mov.u32 \09%r7, %tid.x;\0A\09mov.u32 \09%r8, %tid.y;\0A\09shl.b32 \09%r9, %r6, 3;\0A\09or.b32 \09%r10, %r9, %r8;\0A\09shl.b32 \09%r11, %r5, 9;\0A\09shl.b32 \09%r12, %r7, 6;\0A\09or.b32 \09%r13, %r11, %r12;\0A\09mul.wide.u32 \09%rd23, %r13, 4;\0A\09add.s64 \09%rd24, %rd20, %rd23;\0A\09mul.wide.u32 \09%rd25, %r10, 4;\0A\09add.s64 \09%rd5, %rd24, %rd25;\0A\09ld.global.b32 \09%r18, [%rd5];\0A\09setp.ge.s64 \09%p1, %rd34, %rd17;\0A\09@%p1 bra \09$L__BB0_3;\0A\09ld.param.b64 \09%rd18, [gemm_kernel_param_23];\0A\09cvt.u64.u32 \09%rd3, %r10;\0A\09cvt.u64.u32 \09%rd4, %r13;\0A\09shl.b64 \09%rd26, %rd34, 2;\0A\09shl.b64 \09%rd27, %rd4, 2;\0A\09add.s64 \09%rd28, %rd26, %rd27;\0A\09add.s64 \09%rd33, %rd1, %rd28;\0A\09shl.b64 \09%rd7, %rd18, 2;\0A\09shl.b64 \09%rd29, %rd34, 8;\0A\09shl.b64 \09%rd30, %rd3, 2;\0A\09or.b64 \09%rd31, %rd29, %rd30;\0A\09add.s64 \09%rd32, %rd2, %rd31;\0A\09shl.b64 \09%rd9, %rd18, 8;\0A$L__BB0_2:\0A\09ld.global.b32 \09%r14, [%rd33];\0A\09ld.global.b32 \09%r15, [%rd32];\0A\09mul.rn.f32 \09%r16, %r14, %r15;\0A\09add.rn.f32 \09%r18, %r18, %r16;\0A\09add.s64 \09%rd34, %rd34, %rd18;\0A\09add.s64 \09%rd33, %rd33, %rd7;\0A\09add.s64 \09%rd32, %rd32, %rd9;\0A\09setp.lt.s64 \09%p2, %rd34, %rd17;\0A\09@%p2 bra \09$L__BB0_2;\0A$L__BB0_3:\0A\09st.global.b32 \09[%rd5], %r18;\0A\09ret;\0A\0A}\0A">]
}

