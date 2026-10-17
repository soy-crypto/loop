#map = affine_map<()[s0] -> (s0 * 8)>
module attributes {gpu.container_module} {
  func.func @gemm(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: memref<64x64xf32>) attributes {llvm.emit_c_interface} {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %c64 = arith.constant 64 : index
    gpu.launch_func  @gemm_kernel::@gemm_kernel blocks in (%c8, %c8, %c1) threads in (%c8, %c8, %c1)  args(%arg0 : memref<64x64xf32>, %arg1 : memref<64x64xf32>, %c0 : index, %c64 : index, %c1 : index, %cst : f32, %arg2 : memref<64x64xf32>)
    return
  }
  gpu.module @gemm_kernel {
    gpu.func @gemm_kernel(%arg0: memref<64x64xf32>, %arg1: memref<64x64xf32>, %arg2: index, %arg3: index, %arg4: index, %arg5: f32, %arg6: memref<64x64xf32>) kernel attributes {known_block_size = array<i32: 8, 8, 1>, known_grid_size = array<i32: 8, 8, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %block_id_z = gpu.block_id  z
      %thread_id_x = gpu.thread_id  x
      %thread_id_y = gpu.thread_id  y
      %thread_id_z = gpu.thread_id  z
      %grid_dim_x = gpu.grid_dim  x
      %grid_dim_y = gpu.grid_dim  y
      %grid_dim_z = gpu.grid_dim  z
      %block_dim_x = gpu.block_dim  x
      %block_dim_y = gpu.block_dim  y
      %block_dim_z = gpu.block_dim  z
      %0 = affine.apply #map()[%block_id_x]
      %1 = affine.apply #map()[%block_id_y]
      %2 = arith.addi %thread_id_x, %0 : index
      %3 = arith.addi %thread_id_y, %1 : index
      %4 = scf.for %arg7 = %arg2 to %arg3 step %arg4 iter_args(%arg8 = %arg5) -> (f32) {
        %5 = memref.load %arg0[%2, %arg7] : memref<64x64xf32>
        %6 = memref.load %arg1[%arg7, %3] : memref<64x64xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = arith.addf %7, %arg8 : f32
        scf.yield %8 : f32
      }
      memref.store %4, %arg6[%2, %3] : memref<64x64xf32>
      gpu.return
    }
  }
}

