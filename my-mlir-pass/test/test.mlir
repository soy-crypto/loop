module
{
    func.func @test(%arg0 : i32) -> i32
    {
        %c0 = arith.constant 0 : i32
        %0 = arith.addi %arg0, %c0 : i32
        return %0 : i32
    }

    func.func @test2(%arg0 : i32) -> i32 
    {
        %c1 = arith.constant 1 : i32
        %0 = arith.muli %arg0, %c1 : i32
        return %0 : i32
    }

    func.func @test3() -> i32 
    {
        %c2 = arith.constant 2 : i32
        %c3 = arith.constant 3 : i32
        %0 = arith.addi %c2, %c3 : i32
        return %0 : i32
    }


}