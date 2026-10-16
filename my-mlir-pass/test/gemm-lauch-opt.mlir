#map = affine_map<()[s0] -> (s0 * 8)>


module 
{
    func.func @gemm(%A : memref<64x64xf32>, %B : memref<64x64xf32>, %C : memref<64x64xf32>) attributes {llvm.emit_c_interface}
    {
        %cst = arith.constant 0.0 : f32
        %c0 = arith.constant 0 : index
        %c1 = arith.constant 1 : index
        %c8 = arith.constant 8 : index
        %c64 = arith.constant 64 : index

        gpu.launch blocks(%bi, %bj, %bk) in (%gx = %c8, %gy = %c8, %gz = %c1) threads(%ti, %tj, %tk) in (%bx = %c8, %by = %c8, %bz = %c1) 
        {
            %rowBase = affine.apply #map()[%bi]
            %colBase = affine.apply #map()[%bj]
            %row = arith.addi %ti, %rowBase : index
            %col = arith.addi %tj, %colBase : index
            %result = scf.for %k = %c0 to %c64 step %c1 iter_args(%sum = %cst) -> (f32)
            {
                %a = memref.load %A[%row, %k] : memref<64x64xf32>
                %b = memref.load %B[%k, %col] : memref<64x64xf32>
                %product = arith.mulf %a, %b : f32
                %updateSum = arith.addf %product, %sum: f32
                scf.yield %updateSum : f32
            }

            memref.store %result, %C[%row, %col] : memref<64x64xf32>
            gpu.terminator

        }//

    }//
    
    return
  }