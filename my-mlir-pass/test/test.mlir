module
{
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
}