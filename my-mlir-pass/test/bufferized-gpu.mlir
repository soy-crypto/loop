#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
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
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    linalg.generic {indexing_maps = [#map3, #map3, #map3, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg0, %arg1, %arg2 : memref<8x8xf32, strided<[?, ?], offset: ?>>, memref<8x8xf32, strided<[?, ?], offset: ?>>, memref<8x8xf32, strided<[?, ?], offset: ?>>) outs(%alloc : memref<8x8xf32>) {
    ^bb0(%in: f32, %in_0: f32, %in_1: f32, %out: f32):
      %0 = arith.addf %in, %in_0 : f32
      %1 = arith.mulf %0, %in_1 : f32
      linalg.yield %1 : f32
    }
    %cast = memref.cast %alloc : memref<8x8xf32> to memref<8x8xf32, strided<[?, ?], offset: ?>>
    return %alloc : memref<8x8xf32>
  }
}

