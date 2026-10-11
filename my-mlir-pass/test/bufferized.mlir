#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
module {
  func.func @ictest(%arg0: i32) -> i32 {
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %0 = arith.addi %arg0, %c0_i32 : i32
    %1 = arith.addi %arg0, %0 : i32
    %2 = arith.muli %1, %c1_i32 : i32
    %3 = arith.divsi %2, %c1_i32 : i32
    return %3 : i32
  }
  func.func @add_zero(%arg0: i32) -> i32 {
    %c0_i32 = arith.constant 0 : i32
    %0 = arith.addi %arg0, %c0_i32 : i32
    %1 = arith.addi %c0_i32, %0 : i32
    return %1 : i32
  }
  func.func @keep_add(%arg0: i32, %arg1: i32) -> i32 {
    %0 = arith.addi %arg0, %arg1 : i32
    return %0 : i32
  }
  func.func @matmul(%arg0: memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1: memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32, strided<[?, ?], offset: ?>> {
    linalg.matmul ins(%arg0, %arg1 : memref<2x3xf32, strided<[?, ?], offset: ?>>, memref<3x4xf32, strided<[?, ?], offset: ?>>) outs(%arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>)
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    linalg.generic {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%arg0, %arg1 : memref<2x5xf32, strided<[?, ?], offset: ?>>, memref<5x5xf32, strided<[?, ?], offset: ?>>) outs(%arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %0 = arith.mulf %in, %in_0 : f32
      %1 = arith.addf %out, %0 : f32
      linalg.yield %1 : f32
    }
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    linalg.generic {indexing_maps = [#map3, #map3, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg0, %arg1 : memref<2x4xf32, strided<[?, ?], offset: ?>>, memref<2x4xf32, strided<[?, ?], offset: ?>>) outs(%alloc : memref<2x4xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %0 = arith.addf %in, %in_0 : f32
      linalg.yield %0 : f32
    }
    %cast = memref.cast %alloc : memref<2x4xf32> to memref<2x4xf32, strided<[?, ?], offset: ?>>
    return %alloc : memref<2x4xf32>
  }
  func.func @add_then_mul(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg3: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    %c0 = arith.constant 0 : index
    %c0_0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c4 = arith.constant 4 : index
    %c2_1 = arith.constant 2 : index
    %c2_2 = arith.constant 2 : index
    %0 = scf.for %arg4 = %c0 to %c2 step %c2_1 iter_args(%arg5 = %alloc) -> (memref<2x4xf32>) 
    {
      %1 = scf.for %arg6 = %c0_0 to %c4 step %c2_2 iter_args(%arg7 = %arg5) -> (memref<2x4xf32>) 
      {
        %subview   = memref.subview %arg0[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_3 = memref.subview %arg1[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_4 = memref.subview %arg2[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32, strided<[?, ?], offset: ?>> to memref<2x2xf32, strided<[?, ?], offset: ?>>
        %subview_5 = memref.subview %arg7[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        linalg.generic {indexing_maps = [#map3, #map3, #map3, #map3], iterator_types = ["parallel", "parallel"]} ins(%subview, %subview_3, %subview_4 : memref<2x2xf32, strided<[?, ?], offset: ?>>, memref<2x2xf32, strided<[?, ?], offset: ?>>, memref<2x2xf32, strided<[?, ?], offset: ?>>) outs(%subview_5 : memref<2x2xf32, strided<[4, 1], offset: ?>>) {
        ^bb0(%in: f32, %in_7: f32, %in_8: f32, %out: f32):
          %2 = arith.addf %in, %in_7 : f32
          %3 = arith.mulf %2, %in_8 : f32
          linalg.yield %3 : f32
        }
        %subview_6 = memref.subview %arg7[%arg4, %arg6] [2, 2] [1, 1] : memref<2x4xf32> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        memref.copy %subview_5, %subview_6 : memref<2x2xf32, strided<[4, 1], offset: ?>> to memref<2x2xf32, strided<[4, 1], offset: ?>>
        scf.yield %arg7 : memref<2x4xf32>
      }
      scf.yield %1 : memref<2x4xf32>
    }
    
    %cast = memref.cast %0 : memref<2x4xf32> to memref<2x4xf32, strided<[?, ?], offset: ?>>
    return %0 : memref<2x4xf32>
  }
}

