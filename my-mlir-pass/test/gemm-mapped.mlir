module 
{
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} 
  {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    %c0_0 = arith.constant 0 : index
    %c8 = arith.constant 8 : index
    %c8_1 = arith.constant 8 : index

    %0 = arith.muli %c1, %c8 : index
    %1 = arith.muli %c1, %c8_1 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c64, %c64) step (%0, %1) 
    {
      scf.parallel (%arg5, %arg6) = (%c0_0, %c0_0) to (%0, %1) step (%c1, %c1) 
      {
        %4 = arith.addi %arg5, %arg3 : index
        %5 = arith.addi %arg6, %arg4 : index
        memref.store %cst, %arg2[%4, %5] : memref<64x64xf32>
        scf.reduce 
      } 
      
      {mapping = [#gpu.loop_dim_map<processor = thread_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = thread_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]} 
      
      scf.reduce
    } 
    
    {mapping = [#gpu.loop_dim_map<processor = block_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = block_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]}
    
    
    %c0_2 = arith.constant 0 : index
    %c8_3 = arith.constant 8 : index
    %c8_4 = arith.constant 8 : index
    %2 = arith.muli %c1, %c8_3 : index
    %3 = arith.muli %c1, %c8_4 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c64, %c64) step (%2, %3) 
    {
      scf.parallel (%arg5, %arg6) = (%c0_2, %c0_2) to (%2, %3) step (%c1, %c1) 
      {
        %4 = arith.addi %arg5, %arg3 : index
        %5 = arith.addi %arg6, %arg4 : index
        scf.for %arg7 = %c0 to %c64 step %c1 
        {
          %6 = memref.load %arg0[%4, %arg7] : memref<64x64xf32>
          %7 = memref.load %arg1[%arg7, %5] : memref<64x64xf32>
          %8 = memref.load %arg2[%4, %5] : memref<64x64xf32>
          %9 = arith.mulf %6, %7 : f32
          %10 = arith.addf %9, %8 : f32
          memref.store %10, %arg2[%4, %5] : memref<64x64xf32>
        }
        scf.reduce 

      } 

      {mapping = [#gpu.loop_dim_map<processor = thread_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = thread_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]}
      scf.reduce 
    } 

    {mapping = [#gpu.loop_dim_map<processor = block_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = block_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]}
    
    return

  }
  
}

