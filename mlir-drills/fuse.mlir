// Before: two elementwise generics (add, then mul). Two tensor results.
// After:  mlir-opt --linalg-fuse-elementwise-ops -> one generic: addf then mulf.
#map = affine_map<(d0) -> (d0)>

func.func @add_mul(%a: tensor<8xf32>, %b: tensor<8xf32>, %c: tensor<8xf32>) -> tensor<8xf32> {
  %empty = tensor.empty() : tensor<8xf32>
  %add = linalg.generic {
      indexing_maps = [#map, #map, #map],
      iterator_types = ["parallel"]
    } ins(%a, %b : tensor<8xf32>, tensor<8xf32>)
      outs(%empty : tensor<8xf32>) {
    ^bb0(%x: f32, %y: f32, %out: f32):
      %s = arith.addf %x, %y : f32
      linalg.yield %s : f32
  } -> tensor<8xf32>
  %mul = linalg.generic {
      indexing_maps = [#map, #map, #map],
      iterator_types = ["parallel"]
    } ins(%add, %c : tensor<8xf32>, tensor<8xf32>)
      outs(%empty : tensor<8xf32>) {
    ^bb0(%x: f32, %y: f32, %out: f32):
      %p = arith.mulf %x, %y : f32
      linalg.yield %p : f32
  } -> tensor<8xf32>
  return %mul : tensor<8xf32>
}
