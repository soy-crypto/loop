#map = affine_map<()[s0] -> (s0 * 16)>
module attributes {gpu.container_module} {
  func.func @matmul(%arg0: memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg1: memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg2: memref<128x128xf32, strided<[?, ?], offset: ?>>) -> memref<128x128xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c128 = arith.constant 128 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c8, %c8, %c1) threads in (%c16, %c16, %c1)  args(%arg0 : memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg2 : memref<128x128xf32, strided<[?, ?], offset: ?>>, %c0 : index, %c128 : index, %c1 : index)
    return %arg2 : memref<128x128xf32, strided<[?, ?], offset: ?>>
  }
  gpu.module @matmul_kernel {
    gpu.func @matmul_kernel(%arg0: memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg1: memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg2: memref<128x128xf32, strided<[?, ?], offset: ?>>, %arg3: index, %arg4: index, %arg5: index) kernel attributes {known_block_size = array<i32: 16, 16, 1>, known_grid_size = array<i32: 8, 8, 1>} {
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
      %cst = arith.constant 0.000000e+00 : f32
      %alloca = memref.alloca() : memref<16x16xf32, #gpu.address_space<workgroup>>
      %alloca_0 = memref.alloca() : memref<16x16xf32, #gpu.address_space<workgroup>>
      %c16 = arith.constant 16 : index
      %c0 = arith.constant 0 : index
      %c1 = arith.constant 1 : index
      %4 = scf.for %arg6 = %arg3 to %arg4 step %c16 iter_args(%arg7 = %cst) -> (f32) {
        %5 = arith.addi %arg6, %thread_id_y : index
        %6 = arith.addi %arg6, %thread_id_x : index
        %7 = memref.load %arg0[%2, %5] : memref<128x128xf32, strided<[?, ?], offset: ?>>
        %8 = memref.load %arg1[%6, %3] : memref<128x128xf32, strided<[?, ?], offset: ?>>
        memref.store %7, %alloca[%thread_id_x, %thread_id_y] : memref<16x16xf32, #gpu.address_space<workgroup>>
        memref.store %8, %alloca_0[%thread_id_x, %thread_id_y] : memref<16x16xf32, #gpu.address_space<workgroup>>
        gpu.barrier
        %9 = scf.for %arg8 = %c0 to %c16 step %c1 iter_args(%arg9 = %arg7) -> (f32) {
          %10 = memref.load %alloca[%thread_id_x, %arg8] : memref<16x16xf32, #gpu.address_space<workgroup>>
          %11 = memref.load %alloca_0[%arg8, %thread_id_y] : memref<16x16xf32, #gpu.address_space<workgroup>>
          %12 = arith.mulf %10, %11 : f32
          %13 = arith.addf %arg9, %12 : f32
          scf.yield %13 : f32
        }
        gpu.barrier
        scf.yield %9 : f32
      }
      memref.store %4, %arg2[%2, %3] : memref<128x128xf32, strided<[?, ?], offset: ?>>
      gpu.return
    }
  }
}

