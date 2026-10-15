module
{
    func.func @gemm(%a : memref<64x64xf32>, %b : memref<64x64xf32>, %c : memref<64x64xf32>) attributes {llvm.emit_c_interface}
    {
        //body
        %zero = arith.constant 0.0 : f32
        linalg.fill ins(%zero : f32) outs(%c : memref<64x64xf32>)
        linalg.matmul ins(%a, %b : memref<64x64xf32>, memref<64x64xf32>) outs(%c : memref<64x64xf32>)

        //return
        return
    }
    
}