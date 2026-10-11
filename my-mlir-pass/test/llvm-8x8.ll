; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

define i32 @ictest(i32 %0) {
  %2 = add i32 %0, %0
  ret i32 %2
}

define i32 @add_zero(i32 %0) {
  ret i32 %0
}

define i32 @keep_add(i32 %0, i32 %1) {
  %3 = add i32 %0, %1
  ret i32 %3
}

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20) {
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %14, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, ptr %15, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %16, 2
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %17, 3, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %19, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %18, 3, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 4, 1
  br label %29

29:                                               ; preds = %64, %21
  %30 = phi i64 [ %65, %64 ], [ 0, %21 ]
  %31 = icmp slt i64 %30, 2
  br i1 %31, label %32, label %66

32:                                               ; preds = %29
  br label %33

33:                                               ; preds = %62, %32
  %34 = phi i64 [ %63, %62 ], [ 0, %32 ]
  %35 = icmp slt i64 %34, 4
  br i1 %35, label %36, label %64

36:                                               ; preds = %33
  br label %37

37:                                               ; preds = %40, %36
  %38 = phi i64 [ %61, %40 ], [ 0, %36 ]
  %39 = icmp slt i64 %38, 3
  br i1 %39, label %40, label %62

40:                                               ; preds = %37
  %41 = getelementptr float, ptr %1, i64 %2
  %42 = mul nuw nsw i64 %30, %5
  %43 = mul nuw nsw i64 %38, %6
  %44 = add nuw nsw i64 %42, %43
  %45 = getelementptr inbounds nuw float, ptr %41, i64 %44
  %46 = load float, ptr %45, align 4
  %47 = getelementptr float, ptr %8, i64 %9
  %48 = mul nuw nsw i64 %38, %12
  %49 = mul nuw nsw i64 %34, %13
  %50 = add nuw nsw i64 %48, %49
  %51 = getelementptr inbounds nuw float, ptr %47, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = getelementptr float, ptr %15, i64 %16
  %54 = mul nuw nsw i64 %30, %19
  %55 = mul nuw nsw i64 %34, %20
  %56 = add nuw nsw i64 %54, %55
  %57 = getelementptr inbounds nuw float, ptr %53, i64 %56
  %58 = load float, ptr %57, align 4
  %59 = fmul float %46, %52
  %60 = fadd float %58, %59
  store float %60, ptr %57, align 4
  %61 = add i64 %38, 1
  br label %37

62:                                               ; preds = %37
  %63 = add i64 %34, 1
  br label %33

64:                                               ; preds = %33
  %65 = add i64 %30, 1
  br label %29

66:                                               ; preds = %29
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %28
}

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul_generic(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20) {
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %14, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, ptr %15, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %16, 2
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %17, 3, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %19, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %18, 3, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %20, 4, 1
  br label %29

29:                                               ; preds = %64, %21
  %30 = phi i64 [ %65, %64 ], [ 0, %21 ]
  %31 = icmp slt i64 %30, 2
  br i1 %31, label %32, label %66

32:                                               ; preds = %29
  br label %33

33:                                               ; preds = %62, %32
  %34 = phi i64 [ %63, %62 ], [ 0, %32 ]
  %35 = icmp slt i64 %34, 5
  br i1 %35, label %36, label %64

36:                                               ; preds = %33
  br label %37

37:                                               ; preds = %40, %36
  %38 = phi i64 [ %61, %40 ], [ 0, %36 ]
  %39 = icmp slt i64 %38, 5
  br i1 %39, label %40, label %62

40:                                               ; preds = %37
  %41 = getelementptr float, ptr %1, i64 %2
  %42 = mul nuw nsw i64 %30, %5
  %43 = mul nuw nsw i64 %38, %6
  %44 = add nuw nsw i64 %42, %43
  %45 = getelementptr inbounds nuw float, ptr %41, i64 %44
  %46 = load float, ptr %45, align 4
  %47 = getelementptr float, ptr %8, i64 %9
  %48 = mul nuw nsw i64 %38, %12
  %49 = mul nuw nsw i64 %34, %13
  %50 = add nuw nsw i64 %48, %49
  %51 = getelementptr inbounds nuw float, ptr %47, i64 %50
  %52 = load float, ptr %51, align 4
  %53 = getelementptr float, ptr %15, i64 %16
  %54 = mul nuw nsw i64 %30, %19
  %55 = mul nuw nsw i64 %34, %20
  %56 = add nuw nsw i64 %54, %55
  %57 = getelementptr inbounds nuw float, ptr %53, i64 %56
  %58 = load float, ptr %57, align 4
  %59 = fmul float %46, %52
  %60 = fadd float %58, %59
  store float %60, ptr %57, align 4
  %61 = add i64 %38, 1
  br label %37

62:                                               ; preds = %37
  %63 = add i64 %34, 1
  br label %33

64:                                               ; preds = %33
  %65 = add i64 %30, 1
  br label %29

66:                                               ; preds = %29
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %28
}

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @elementwise_add(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20) {
  %22 = call ptr @malloc(i64 96)
  %23 = ptrtoint ptr %22 to i64
  %24 = add i64 %23, 63
  %25 = urem i64 %24, 64
  %26 = sub i64 %24, %25
  %27 = inttoptr i64 %26 to ptr
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %22, 0
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, ptr %27, 1
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, i64 0, 2
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 2, 3, 0
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 4, 3, 1
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, i64 4, 4, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 1, 4, 1
  br label %35

35:                                               ; preds = %60, %21
  %36 = phi i64 [ %61, %60 ], [ 0, %21 ]
  %37 = icmp slt i64 %36, 2
  br i1 %37, label %38, label %62

38:                                               ; preds = %35
  br label %39

39:                                               ; preds = %42, %38
  %40 = phi i64 [ %59, %42 ], [ 0, %38 ]
  %41 = icmp slt i64 %40, 4
  br i1 %41, label %42, label %60

42:                                               ; preds = %39
  %43 = getelementptr float, ptr %1, i64 %2
  %44 = mul nuw nsw i64 %36, %5
  %45 = mul nuw nsw i64 %40, %6
  %46 = add nuw nsw i64 %44, %45
  %47 = getelementptr inbounds nuw float, ptr %43, i64 %46
  %48 = load float, ptr %47, align 4
  %49 = getelementptr float, ptr %8, i64 %9
  %50 = mul nuw nsw i64 %36, %12
  %51 = mul nuw nsw i64 %40, %13
  %52 = add nuw nsw i64 %50, %51
  %53 = getelementptr inbounds nuw float, ptr %49, i64 %52
  %54 = load float, ptr %53, align 4
  %55 = fadd float %48, %54
  %56 = mul nuw nsw i64 %36, 4
  %57 = add nuw nsw i64 %56, %40
  %58 = getelementptr inbounds nuw float, ptr %27, i64 %57
  store float %55, ptr %58, align 4
  %59 = add i64 %40, 1
  br label %39

60:                                               ; preds = %39
  %61 = add i64 %36, 1
  br label %35

62:                                               ; preds = %35
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %34
}

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @add_then_mul(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20, ptr %21, ptr %22, i64 %23, i64 %24, i64 %25, i64 %26, i64 %27) {
  %29 = call ptr @malloc(i64 320)
  %30 = ptrtoint ptr %29 to i64
  %31 = add i64 %30, 63
  %32 = urem i64 %31, 64
  %33 = sub i64 %31, %32
  %34 = inttoptr i64 %33 to ptr
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %29, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, ptr %34, 1
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, i64 0, 2
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 8, 3, 0
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, i64 8, 3, 1
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, i64 8, 4, 0
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 1, 4, 1
  br label %42

42:                                               ; preds = %101, %28
  %43 = phi i64 [ %102, %101 ], [ 0, %28 ]
  %44 = icmp slt i64 %43, 8
  br i1 %44, label %45, label %103

45:                                               ; preds = %42
  br label %46

46:                                               ; preds = %99, %45
  %47 = phi i64 [ %100, %99 ], [ 0, %45 ]
  %48 = icmp slt i64 %47, 8
  br i1 %48, label %49, label %101

49:                                               ; preds = %46
  %50 = mul nsw i64 %43, %5
  %51 = add i64 %2, %50
  %52 = mul nsw i64 %47, %6
  %53 = add i64 %51, %52
  %54 = mul nsw i64 %43, %12
  %55 = add i64 %9, %54
  %56 = mul nsw i64 %47, %13
  %57 = add i64 %55, %56
  %58 = mul nsw i64 %43, %19
  %59 = add i64 %16, %58
  %60 = mul nsw i64 %47, %20
  %61 = add i64 %59, %60
  %62 = mul nsw i64 %43, 8
  %63 = add i64 %62, %47
  br label %64

64:                                               ; preds = %97, %49
  %65 = phi i64 [ %98, %97 ], [ 0, %49 ]
  %66 = icmp slt i64 %65, 2
  br i1 %66, label %67, label %99

67:                                               ; preds = %64
  br label %68

68:                                               ; preds = %71, %67
  %69 = phi i64 [ %96, %71 ], [ 0, %67 ]
  %70 = icmp slt i64 %69, 2
  br i1 %70, label %71, label %97

71:                                               ; preds = %68
  %72 = getelementptr float, ptr %1, i64 %53
  %73 = mul nuw nsw i64 %65, %5
  %74 = mul nuw nsw i64 %69, %6
  %75 = add nuw nsw i64 %73, %74
  %76 = getelementptr inbounds nuw float, ptr %72, i64 %75
  %77 = load float, ptr %76, align 4
  %78 = getelementptr float, ptr %8, i64 %57
  %79 = mul nuw nsw i64 %65, %12
  %80 = mul nuw nsw i64 %69, %13
  %81 = add nuw nsw i64 %79, %80
  %82 = getelementptr inbounds nuw float, ptr %78, i64 %81
  %83 = load float, ptr %82, align 4
  %84 = getelementptr float, ptr %15, i64 %61
  %85 = mul nuw nsw i64 %65, %19
  %86 = mul nuw nsw i64 %69, %20
  %87 = add nuw nsw i64 %85, %86
  %88 = getelementptr inbounds nuw float, ptr %84, i64 %87
  %89 = load float, ptr %88, align 4
  %90 = fadd float %77, %83
  %91 = fmul float %90, %89
  %92 = getelementptr float, ptr %34, i64 %63
  %93 = mul nuw nsw i64 %65, 8
  %94 = add nuw nsw i64 %93, %69
  %95 = getelementptr inbounds nuw float, ptr %92, i64 %94
  store float %91, ptr %95, align 4
  %96 = add i64 %69, 1
  br label %68

97:                                               ; preds = %68
  %98 = add i64 %65, 1
  br label %64

99:                                               ; preds = %64
  %100 = add i64 %47, 2
  br label %46

101:                                              ; preds = %46
  %102 = add i64 %43, 2
  br label %42

103:                                              ; preds = %42
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %41
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
