module
{
    //arith dialect
    func.func @ictest(%x : i32) -> i32
    {
        %zero = arith.constant 0 : i32
        %one = arith.constant 1 : i32
        
        %a = arith.addi %x, %zero : i32
        %b = arith.addi %x, %a : i32
        %c = arith.muli %b, %one : i32
        %d = arith.divsi %c, %one : i32
        
        return %d : i32
    }

    func.func @add_zero(%x: i32) -> i32 
    {
        %zero = arith.constant 0 : i32
        %a = arith.addi %x, %zero : i32
        %b = arith.addi %zero, %a : i32
        return %b : i32
    }

    func.func @keep_add(%x: i32, %y: i32) -> i32 
    {
        %a = arith.addi %x, %y : i32
        return %a : i32
    }

    //linalg dialect
    func.func @matmul(%a : tensor<2x3xf32>, %b : tensor<3x4xf32>, %init: tensor<2x4xf32>) -> tensor<2x4xf32>
    {
        %result = linalg.matmul ins(%a, %b : tensor<2x3xf32>, tensor<3x4xf32>) outs(%init : tensor<2x4xf32>) 
                                -> tensor<2x4xf32>

        return %result : tensor<2x4xf32>
    }

    func.func @matmul_generic(%a : tensor<2x5xf32>, %b : tensor<5x5xf32>, %init : tensor<2x5xf32>) -> tensor<2x5xf32>
    {
        %result = linalg.generic
        {
            indexing_maps = [
                affine_map<(i, j, k) -> (i, k)>, 
                affine_map<(i, j, k) -> (k, j)>,
                affine_map<(i, j, k) -> (i, j)>],
            iterator_types = ["parallel", "parallel", "reduction"]
        }
        ins(%a, %b : tensor<2x5xf32>, tensor<5x5xf32>)
        outs(%init : tensor<2x5xf32>)
        {
            ^bb0(%aElement: f32, %bElement: f32, %acc: f32):
                %product = arith.mulf %aElement, %bElement : f32
                %sum = arith.addf %acc, %product : f32
                linalg.yield %sum : f32
        } -> tensor<2x5xf32>

        return %result : tensor<2x5xf32>
    }

    func.func @elementwise_add(%a : tensor<2x4xf32>, %b : tensor<2x4xf32>, %init : tensor<2x4xf32>) -> tensor<2x4xf32>
    {
        %result = linalg.generic
        {
            indexing_maps = [
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>
            ],

            iterator_types = ["parallel", "parallel"]
        }

        ins(%a, %b : tensor<2x4xf32>, tensor<2x4xf32>)
        outs(%init : tensor<2x4xf32>)

        {
            ^bb0(%aElement : f32, %bElement : f32, %old : f32):
                %sum = arith.addf %aElement, %bElement : f32
                linalg.yield %sum : f32
        }
        -> tensor<2x4xf32>

        return %result : tensor<2x4xf32>
    }

    func.func @add_then_mul(%a : tensor<2x4xf32>, %b : tensor<2x4xf32>, %scale : tensor<2x4xf32>, %init : tensor<2x4xf32>) -> tensor<2x4xf32>
    {
        //addtion
        %sumTensor = linalg.generic
        {
            indexing_maps = [
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>
            ],

            iterator_types = ["parallel", "parallel"]
        }

        ins(%a, %b : tensor<2x4xf32>, tensor<2x4xf32>)
        outs(%init : tensor<2x4xf32>)

        {
            ^bb0(%aElement : f32, %bElement : f32, %old : f32):
                %sum = arith.addf %aElement, %bElement : f32
                linalg.yield %sum : f32
        }
        -> tensor<2x4xf32>

        //multiplication
        %resultTensor = linalg.generic
        {
            indexing_maps =[
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>,
                affine_map<(i, j) -> (i, j)>
            ],

            iterator_types = ["parallel", "parallel"]
        }

        ins(%sumTensor, %scale : tensor<2x4xf32>, tensor<2x4xf32>)
        outs(%init : tensor<2x4xf32>)
        
        {
            ^bb0(%sumElement : f32, %scaleElement : f32, %oldElement : f32):
                %product = arith.mulf %sumElement, %scaleElement : f32
                linalg.yield %product : f32
        }

        -> tensor<2x4xf32>

        return %resultTensor : tensor<2x4xf32>
    }
    
}//module