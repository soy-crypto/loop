module
{
    func.func @test(%arg0 : i32) -> i32
    {
        %c0 = arith.constant 0 : i32
        %0 = arith.addi %arg0, %c0 : i32
        return %0 : i32
    }
}