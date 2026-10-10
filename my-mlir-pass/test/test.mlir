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
    
}