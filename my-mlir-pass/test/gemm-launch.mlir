#map = affine_map<()[s0] -> (s0 * 8)>

module 
{

  func.func @gemm(%A: memref<64x64xf32>, %B: memref<64x64xf32>, %C: memref<64x64xf32>) attributes {llvm.emit_c_interface} 
  {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    gpu.launch blocks(%bi, %bj, %bk) in (%arg9 = %c8, %arg10 = %c8, %arg11 = %c1) threads(%ti, %tj, %tk) in (%arg12 = %c8, %arg13 = %c8, %arg14 = %c1) 
    {
        %rowBase = affine.apply #map()[%bi]
        %colBase = affine.apply #map()[%bj]
        %row = arith.addi %ti, %rowBase : index
        %col = arith.addi %tj, %colBase : index
        memref.store %cst, %C[%row, %col] : memref<64x64xf32>
        gpu.terminator
    } 
    {SCFToGPU_visited}

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

}

