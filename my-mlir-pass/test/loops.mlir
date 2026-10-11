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
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c4 step %c1 {
        scf.for %arg5 = %c0 to %c3 step %c1 {
          %0 = memref.load %arg0[%arg3, %arg5] : memref<2x3xf32, strided<[?, ?], offset: ?>>
          %1 = memref.load %arg1[%arg5, %arg4] : memref<3x4xf32, strided<[?, ?], offset: ?>>
          %2 = memref.load %arg2[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
          %3 = arith.mulf %0, %1 : f32
          %4 = arith.addf %2, %3 : f32
          memref.store %4, %arg2[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        }
      }
    }
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c5 step %c1 {
        scf.for %arg5 = %c0 to %c5 step %c1 {
          %0 = memref.load %arg0[%arg3, %arg5] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %1 = memref.load %arg1[%arg5, %arg4] : memref<5x5xf32, strided<[?, ?], offset: ?>>
          %2 = memref.load %arg2[%arg3, %arg4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %3 = arith.mulf %0, %1 : f32
          %4 = arith.addf %2, %3 : f32
          memref.store %4, %arg2[%arg3, %arg4] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        }
      }
    }
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    scf.for %arg3 = %c0 to %c2 step %c1 {
      scf.for %arg4 = %c0 to %c4 step %c1 {
        %0 = memref.load %arg0[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %1 = memref.load %arg1[%arg3, %arg4] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %2 = arith.addf %0, %1 : f32
        memref.store %2, %alloc[%arg3, %arg4] : memref<2x4xf32>
      }
    }
    return %alloc : memref<2x4xf32>
  }
  func.func @add_then_mul(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg3: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c1 = arith.constant 1 : index
    %c4 = arith.constant 4 : index
    %c2 = arith.constant 2 : index
    %c0 = arith.constant 0 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    %0 = scf.for %arg4 = %c0 to %c2 step %c2 iter_args(%arg5 = %alloc) -> (memref<2x4xf32>) {
      %1 = scf.for %arg6 = %c0 to %c4 step %c2 iter_args(%arg7 = %arg5) -> (memref<2x4xf32>) {
        %subview = memref.subview %arg0[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_0 = memref.subview %arg1[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_1 = memref.subview %arg2[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_2 = memref.subview %arg7[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        scf.for %arg8 = %c0 to %c2 step %c1 {
          scf.for %arg9 = %c0 to %c2 step %c1 {
            %2 = memref.load %subview[%arg8, %arg9] : memref<2x2xf32, strided<[?, ?], offset: ?>>
            %3 = memref.load %subview_0[%arg8, %arg9] : memref<2x2xf32, strided<[?, ?], offset: ?>>
            %4 = memref.load %subview_1[%arg8, %arg9] : memref<2x2xf32, strided<[?, ?], offset: ?>>
            %5 = arith.addf %2, %3 : f32
            %6 = arith.mulf %5, %4 : f32
            memref.store %6, %subview_2[%arg8, %arg9] : memref<2x2xf32, strided<[4, 1], offset: ?>>
          }
        }
        %subview_3 = memref.subview %arg7[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        memref.copy %subview_2, %subview_3 : memref<2x2xf32, strided<[4, 1], offset: ?>> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        scf.yield %arg7 : memref<2x4xf32>
      }
      scf.yield %1 : memref<2x4xf32>
    }
    return %0 : memref<2x4xf32>
  }
}

