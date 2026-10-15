#map = affine_map<()[s0] -> (s0 * 8)>

module 
{

    gpu.launch blocks(%bi, %bj, %bk) in (%arg9 = %c8, %arg10 = %c8, %arg11 = %c1) threads(%ti, %tj, %tk) in (%arg12 = %c8, %arg13 = %c8, %arg14 = %c1) 
    {
        %rowBase = affine.apply #map()[%bi]
        %colBase = affine.apply #map()[%bj]
        %row = arith.addi %ti, %rowBase : index
        %col = arith.addi %tj, %colBase : index
        scf.for %k = %c0 to %c64 step %c1 
        {
            %aElement = memref.load %A[%row, %k] : memref<64x64xf32>
            %bElement = memref.load %B[%k, %col] : memref<64x64xf32>
            %cElement = memref.load %C[%row, %col] : memref<64x64xf32>
            %mulResult = arith.mulf %aElement, %bElement : f32
            %mulAddResult = arith.addf %mulResult, %cElement: f32
            memref.store %mulAddResult, %C[%row, %col] : memref<64x64xf32>
        }
        gpu.terminator

    }

    {SCFToGPU_visited}

    return
  }


