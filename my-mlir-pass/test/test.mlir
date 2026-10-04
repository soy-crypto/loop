module
{
    func.func @test1(%arg0 : i32) -> i32
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

    func.func @test4(%arg0 : i32) -> i32
    {
        %c0 = arith.constant 0 : i32
        %0 = arith.muli %arg0, %c0 : i32
        return %0 : i32
    }

    func.func @test5(%arg0 : i32) -> i32
    {
        %0 = arith.subi %arg0, %arg0 : i32
        return %0 : i32
    }
    
    func.func @test6() -> i32
    {
        %c2 = arith.constant 2 : i32
        %c3 = arith.constant 3 : i32
        %0 = arith.muli %c2, %c3 : i32
        return %0 : i32
    }

    func.func @test7()
    {
        %c0 = arith.constant 0 : index
        %c10 = arith.constant 10 : index
        %c1 = arith.constant 1 : index

        scf.for %i = %c0 to %c10 step %c1
        {

        }

        return
    }

    func.func @test8()
    {
        %c0 = arith.constant 0 : index
        %c10 = arith.constant 10 : index
        %c1 = arith.constant 1 : index
        scf.for %i = %c0 to %c10 step %c1
        {
            %x = arith.constant 1 : i32
            %y = arith.constant 2 : i32
            %z = arith.addi %x, %y : i32
        }

        return
    }

    func.func @test9()
    {
        %c0 = arith.constant 0 : index
        %c10 = arith.constant 10 : index
        %c1 = arith.constant 1 : index
        %c2 = arith.constant 2 : i32
        %c3 = arith.constant 3 : i32
        scf.for %i = %c0 to %c10 step %c1
        {
            %0 = arith.addi %c2, %c3 : i32
        }

        return
    }


}