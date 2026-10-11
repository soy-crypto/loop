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
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c4 = arith.constant 4 : index
    %c3 = arith.constant 3 : index
    cf.br ^bb1(%c0 : index)
  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb8
    %1 = arith.cmpi slt, %0, %c2 : index
    cf.cond_br %1, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    cf.br ^bb3(%c0 : index)
  ^bb3(%2: index):  // 2 preds: ^bb2, ^bb7
    %3 = arith.cmpi slt, %2, %c4 : index
    cf.cond_br %3, ^bb4, ^bb8
  ^bb4:  // pred: ^bb3
    cf.br ^bb5(%c0 : index)
  ^bb5(%4: index):  // 2 preds: ^bb4, ^bb6
    %5 = arith.cmpi slt, %4, %c3 : index
    cf.cond_br %5, ^bb6, ^bb7
  ^bb6:  // pred: ^bb5
    %6 = memref.load %arg0[%0, %4] : memref<2x3xf32, strided<[?, ?], offset: ?>>
    %7 = memref.load %arg1[%4, %2] : memref<3x4xf32, strided<[?, ?], offset: ?>>
    %8 = memref.load %arg2[%0, %2] : memref<2x4xf32, strided<[?, ?], offset: ?>>
    %9 = arith.mulf %6, %7 : f32
    %10 = arith.addf %8, %9 : f32
    memref.store %10, %arg2[%0, %2] : memref<2x4xf32, strided<[?, ?], offset: ?>>
    %11 = arith.addi %4, %c1 : index
    cf.br ^bb5(%11 : index)
  ^bb7:  // pred: ^bb5
    %12 = arith.addi %2, %c1 : index
    cf.br ^bb3(%12 : index)
  ^bb8:  // pred: ^bb3
    %13 = arith.addi %0, %c1 : index
    cf.br ^bb1(%13 : index)
  ^bb9:  // pred: ^bb1
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    cf.br ^bb1(%c0 : index)
  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb8
    %1 = arith.cmpi slt, %0, %c2 : index
    cf.cond_br %1, ^bb2, ^bb9
  ^bb2:  // pred: ^bb1
    cf.br ^bb3(%c0 : index)
  ^bb3(%2: index):  // 2 preds: ^bb2, ^bb7
    %3 = arith.cmpi slt, %2, %c5 : index
    cf.cond_br %3, ^bb4, ^bb8
  ^bb4:  // pred: ^bb3
    cf.br ^bb5(%c0 : index)
  ^bb5(%4: index):  // 2 preds: ^bb4, ^bb6
    %5 = arith.cmpi slt, %4, %c5 : index
    cf.cond_br %5, ^bb6, ^bb7
  ^bb6:  // pred: ^bb5
    %6 = memref.load %arg0[%0, %4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
    %7 = memref.load %arg1[%4, %2] : memref<5x5xf32, strided<[?, ?], offset: ?>>
    %8 = memref.load %arg2[%0, %2] : memref<2x5xf32, strided<[?, ?], offset: ?>>
    %9 = arith.mulf %6, %7 : f32
    %10 = arith.addf %8, %9 : f32
    memref.store %10, %arg2[%0, %2] : memref<2x5xf32, strided<[?, ?], offset: ?>>
    %11 = arith.addi %4, %c1 : index
    cf.br ^bb5(%11 : index)
  ^bb7:  // pred: ^bb5
    %12 = arith.addi %2, %c1 : index
    cf.br ^bb3(%12 : index)
  ^bb8:  // pred: ^bb3
    %13 = arith.addi %0, %c1 : index
    cf.br ^bb1(%13 : index)
  ^bb9:  // pred: ^bb1
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    cf.br ^bb1(%c0 : index)
  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb5
    %1 = arith.cmpi slt, %0, %c2 : index
    cf.cond_br %1, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    cf.br ^bb3(%c0 : index)
  ^bb3(%2: index):  // 2 preds: ^bb2, ^bb4
    %3 = arith.cmpi slt, %2, %c4 : index
    cf.cond_br %3, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %4 = memref.load %arg0[%0, %2] : memref<2x4xf32, strided<[?, ?], offset: ?>>
    %5 = memref.load %arg1[%0, %2] : memref<2x4xf32, strided<[?, ?], offset: ?>>
    %6 = arith.addf %4, %5 : f32
    memref.store %6, %alloc[%0, %2] : memref<2x4xf32>
    %7 = arith.addi %2, %c1 : index
    cf.br ^bb3(%7 : index)
  ^bb5:  // pred: ^bb3
    %8 = arith.addi %0, %c1 : index
    cf.br ^bb1(%8 : index)
  ^bb6:  // pred: ^bb1
    return %alloc : memref<2x4xf32>
  }

  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c8 = arith.constant 8 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    cf.br ^bb1(%c0 : index)

  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb11
    %1 = arith.cmpi slt, %0, %c8 : index
    cf.cond_br %1, ^bb2, ^bb12
    
  ^bb2:  // pred: ^bb1
    cf.br ^bb3(%c0 : index)

  ^bb3(%2: index):  // 2 preds: ^bb2, ^bb10
    %3 = arith.cmpi slt, %2, %c8 : index
    cf.cond_br %3, ^bb4, ^bb11

  ^bb4:  // pred: ^bb3
    %subview = memref.subview %arg0[%0, %2] [2, 2] [1, 1] : memref<8x8xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
    %subview_0 = memref.subview %arg1[%0, %2] [2, 2] [1, 1] : memref<8x8xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
    %subview_1 = memref.subview %arg2[%0, %2] [2, 2] [1, 1] : memref<8x8xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
    %subview_2 = memref.subview %alloc[%0, %2] [2, 2] [1, 1] : memref<8x8xf32> to memref<2x2xf32, strided<[8, 1], offset: ?>>
    cf.br ^bb5(%c0 : index)

  ^bb5(%4: index):  // 2 preds: ^bb4, ^bb9
    %5 = arith.cmpi slt, %4, %c2 : index
    cf.cond_br %5, ^bb6, ^bb10

  ^bb6:  // pred: ^bb5
    cf.br ^bb7(%c0 : index)

  ^bb7(%6: index):  // 2 preds: ^bb6, ^bb8
    %7 = arith.cmpi slt, %6, %c2 : index
    cf.cond_br %7, ^bb8, ^bb9

  ^bb8:  // pred: ^bb7
    %8 = memref.load %subview[%4, %6] : memref<2x2xf32, strided<[?, ?], offset: ?>>
    %9 = memref.load %subview_0[%4, %6] : memref<2x2xf32, strided<[?, ?], offset: ?>>
    %10 = memref.load %subview_1[%4, %6] : memref<2x2xf32, strided<[?, ?], offset: ?>>
    %11 = arith.addf %8, %9 : f32
    %12 = arith.mulf %11, %10 : f32
    memref.store %12, %subview_2[%4, %6] : memref<2x2xf32, strided<[8, 1], offset: ?>>
    %13 = arith.addi %6, %c1 : index
    cf.br ^bb7(%13 : index)

  ^bb9:  // pred: ^bb7
    %14 = arith.addi %4, %c1 : index
    cf.br ^bb5(%14 : index)

  ^bb10:  // pred: ^bb5
    %15 = arith.addi %2, %c2 : index
    cf.br ^bb3(%15 : index)

  ^bb11:  // pred: ^bb3
    %16 = arith.addi %0, %c2 : index
    cf.br ^bb1(%16 : index)

  ^bb12:  // pred: ^bb1
    return %alloc : memref<8x8xf32>
  }
}

