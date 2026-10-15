module 
{
  //%arg0 : A, %arg1 : B, %arg2: C 
  //input(A, B) output(C)
  func.func @gemm(%A: memref<64x64xf32>, %B: memref<64x64xf32>, %C: memref<64x64xf32>) attributes {llvm.emit_c_interface} 
  {
    %cst = arith.constant 0.000000e+00 : f32
    %c0  = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1  = arith.constant 1 : index

    scf.parallel (%i, %j) = (%c0, %c0) to (%c64, %c64) step (%c1, %c1) 
    {
      memref.store %cst, %C[%i, %j] : memref<64x64xf32>
      scf.reduce 
    }

    //(%i, %j) refer to the element in tensor C
    scf.parallel (%i, %j) = (%c0, %c0) to (%c64, %c64) step (%c1, %c1) 
    {
      //current C[%i, %j]
      scf.for %k = %c0 to %c64 step %c1 
      {
        %aElement     = memref.load %A[%i, %k] : memref<64x64xf32>
        %bElement     = memref.load %B[%k, %j] : memref<64x64xf32>
        %cElement     = memref.load %C[%i, %j] : memref<64x64xf32>
        %mulResult    = arith.mulf %aElement,  %bElement: f32
        %mulAddResult = arith.addf %mulResult, %cElement : f32
        memref.store %mulAddResult, %C[%i, %j] : memref<64x64xf32>
      }

      scf.reduce
    }

    //return
    return
  }

}