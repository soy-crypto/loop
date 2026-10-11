#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d0, d1)>
module 
{
  func.func @ictest(%arg0: i32) -> i32 
  {
    %c0_i32 = arith.constant 0 : i32
    %c1_i32 = arith.constant 1 : i32
    %0 = arith.addi %arg0, %c0_i32 : i32
    %1 = arith.addi %arg0, %0 : i32
    %2 = arith.muli %1, %c1_i32 : i32
    %3 = arith.divsi %2, %c1_i32 : i32
    return %3 : i32
  }

  func.func @add_zero(%arg0: i32) -> i32 
  {
    %c0_i32 = arith.constant 0 : i32
    %0 = arith.addi %arg0, %c0_i32 : i32
    %1 = arith.addi %c0_i32, %0 : i32
    return %1 : i32
  }

  func.func @keep_add(%arg0: i32, %arg1: i32) -> i32 
  {
    %0 = arith.addi %arg0, %arg1 : i32
    return %0 : i32
  }

  func.func @matmul(%arg0: tensor<2x3xf32>, %arg1: tensor<3x4xf32>, %arg2: tensor<2x4xf32>) -> tensor<2x4xf32> 
  {
    %0 = linalg.matmul ins(%arg0, %arg1 : tensor<2x3xf32>, tensor<3x4xf32>) outs(%arg2 : tensor<2x4xf32>) -> tensor<2x4xf32>
    return %0 : tensor<2x4xf32>
  }

  func.func @matmul_generic(%arg0: tensor<2x5xf32>, %arg1: tensor<5x5xf32>, %arg2: tensor<2x5xf32>) -> tensor<2x5xf32> 
  {
    %0 = linalg.generic {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"]} ins(%arg0, %arg1 : tensor<2x5xf32>, tensor<5x5xf32>) outs(%arg2 : tensor<2x5xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %1 = arith.mulf %in, %in_0 : f32
      %2 = arith.addf %out, %1 : f32
      linalg.yield %2 : f32
    } -> tensor<2x5xf32>
    return %0 : tensor<2x5xf32>
  }

  func.func @elementwise_add(%arg0: tensor<2x4xf32>, %arg1: tensor<2x4xf32>, %arg2: tensor<2x4xf32>) -> tensor<2x4xf32> 
  {
    %0 = tensor.empty() : tensor<2x4xf32>
    %1 = linalg.generic {indexing_maps = [#map3, #map3, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg0, %arg1 : tensor<2x4xf32>, tensor<2x4xf32>) outs(%0 : tensor<2x4xf32>) {
    ^bb0(%in: f32, %in_0: f32, %out: f32):
      %2 = arith.addf %in, %in_0 : f32
      linalg.yield %2 : f32
    } -> tensor<2x4xf32>
    
    return %1 : tensor<2x4xf32>
  }

  func.func @add_then_mul(%arg0: tensor<2x4xf32>, %arg1: tensor<2x4xf32>, %arg2: tensor<2x4xf32>, %arg3: tensor<2x4xf32>) -> tensor<2x4xf32> 
  {
    %0 = tensor.empty() : tensor<2x4xf32>
    %c0 = arith.constant 0 : index
    %c0_0 = arith.constant 0 : index
    %c2 = arith.constant 2 : index
    %c4 = arith.constant 4 : index
    %c2_1 = arith.constant 2 : index
    %c2_2 = arith.constant 2 : index
    %1 = scf.for %arg4 = %c0 to %c2 step %c2_1 iter_args(%arg5 = %0) -> (tensor<2x4xf32>) 
    {
      %2 = scf.for %arg6 = %c0_0 to %c4 step %c2_2 iter_args(%arg7 = %arg5) -> (tensor<2x4xf32>) 
      {
        %extracted_slice   = tensor.extract_slice %arg0[%arg4, %arg6] [2, 2] [1, 1] : tensor<2x4xf32> to tensor<2x2xf32>
        %extracted_slice_3 = tensor.extract_slice %arg1[%arg4, %arg6] [2, 2] [1, 1] : tensor<2x4xf32> to tensor<2x2xf32>
        %extracted_slice_4 = tensor.extract_slice %arg2[%arg4, %arg6] [2, 2] [1, 1] : tensor<2x4xf32> to tensor<2x2xf32>
        %extracted_slice_5 = tensor.extract_slice %arg7[%arg4, %arg6] [2, 2] [1, 1] : tensor<2x4xf32> to tensor<2x2xf32>
        %3 = linalg.generic {indexing_maps = [#map3, #map3, #map3, #map3], iterator_types = ["parallel", "parallel"]} ins(%extracted_slice, %extracted_slice_3, %extracted_slice_4 : tensor<2x2xf32>, tensor<2x2xf32>, tensor<2x2xf32>) outs(%extracted_slice_5 : tensor<2x2xf32>) 
        {
          ^bb0(%in: f32, %in_6: f32, %in_7: f32, %out: f32):
            %4 = arith.addf %in, %in_6 : f32
            %5 = arith.mulf %4, %in_7 : f32
            linalg.yield %5 : f32
        } -> tensor<2x2xf32>

        %inserted_slice = tensor.insert_slice %3 into %arg7[%arg4, %arg6] [2, 2] [1, 1] : tensor<2x2xf32> into tensor<2x4xf32>
        scf.yield %inserted_slice : tensor<2x4xf32>

      }

      scf.yield %2 : tensor<2x4xf32>

    }
    
    return %1 : tensor<2x4xf32>
  }

}

