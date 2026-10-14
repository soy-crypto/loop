// 128x128 f32 matmul. The GPU pipeline tiles the parallel loops by 16x16, so
// both dimensions must be multiples of 16. linalg.matmul accumulates into %C.
module {
  func.func @matmul(%A : tensor<128x128xf32>, %B : tensor<128x128xf32>, %C : tensor<128x128xf32>) -> tensor<128x128xf32> {
    %result = linalg.matmul
        ins(%A, %B : tensor<128x128xf32>, tensor<128x128xf32>)
        outs(%C : tensor<128x128xf32>) -> tensor<128x128xf32>
    return %result : tensor<128x128xf32>
  }
}
