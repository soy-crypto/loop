#map = affine_map<()[s0] -> (s0 * 2)>
#map1 = affine_map<(d0) -> (-d0 + 5, 2)>
module attributes {gpu.container_module} {
  func.func @ictest(%arg0: i32) -> i32 {
    %0 = arith.addi %arg0, %arg0 : i32
    return %0 : i32
  }
  func.func @add_zero(%arg0: i32) -> i32 {
    return %arg0 : i32
  }
  func.func @keep_add(%arg0: i32, %arg1: i32) -> i32 {
    %0 = arith.addi %arg0, %arg1 : i32
    return %0 : i32
  }
  func.func @matmul(%arg0: memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1: memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c3 = arith.constant 3 : index
    %c2 = arith.constant 2 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c1, %c2, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %c0 : index, %c3 : index, %c1 : index)
    return %arg2 : memref<2x4xf32, strided<[?, ?], offset: ?>>
  }
  gpu.module @matmul_kernel {
    gpu.func @matmul_kernel(%arg0: memref<2x3xf32, strided<[?, ?], offset: ?>>, %arg1: memref<3x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg3: index, %arg4: index, %arg5: index) kernel attributes {known_block_size = array<i32: 2, 2, 1>, known_grid_size = array<i32: 1, 2, 1>} {
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
      %0 = affine.apply #map()[%block_id_y]
      %1 = arith.addi %thread_id_y, %0 : index
      scf.for %arg6 = %arg3 to %arg4 step %arg5 {
        %2 = memref.load %arg0[%thread_id_x, %arg6] : memref<2x3xf32, strided<[?, ?], offset: ?>>
        %3 = memref.load %arg1[%arg6, %1] : memref<3x4xf32, strided<[?, ?], offset: ?>>
        %4 = memref.load %arg2[%thread_id_x, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
        %5 = arith.mulf %2, %3 : f32
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %arg2[%thread_id_x, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      }
      gpu.return
    }
  }
  func.func @matmul_generic(%arg0: memref<2x5xf32, strided<[?, ?], offset: ?>>, %arg1: memref<5x5xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x5xf32, strided<[?, ?], offset: ?>>) -> memref<2x5xf32, strided<[?, ?], offset: ?>> {
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c5 = arith.constant 5 : index
    %c2 = arith.constant 2 : index
    scf.parallel (%arg3) = (%c0) to (%c5) step (%c2) {
      %0 = affine.min #map1(%arg3)
      scf.parallel (%arg4, %arg5) = (%c0, %c0) to (%c2, %0) step (%c1, %c1) {
        %1 = arith.addi %arg5, %arg3 : index
        scf.for %arg6 = %c0 to %c5 step %c1 {
          %2 = memref.load %arg0[%arg4, %arg6] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %3 = memref.load %arg1[%arg6, %1] : memref<5x5xf32, strided<[?, ?], offset: ?>>
          %4 = memref.load %arg2[%arg4, %1] : memref<2x5xf32, strided<[?, ?], offset: ?>>
          %5 = arith.mulf %2, %3 : f32
          %6 = arith.addf %4, %5 : f32
          memref.store %6, %arg2[%arg4, %1] : memref<2x5xf32, strided<[?, ?], offset: ?>>
        }
        scf.reduce 
      } {mapping = [#gpu.loop_dim_map<processor = thread_x, map = (d0) -> (d0), bound = (d0) -> (d0)>, #gpu.loop_dim_map<processor = thread_y, map = (d0) -> (d0), bound = (d0) -> (d0)>]}
      scf.reduce 
    }
    return %arg2 : memref<2x5xf32, strided<[?, ?], offset: ?>>
  }
  func.func @elementwise_add(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32, strided<[?, ?], offset: ?>>) -> memref<2x4xf32> {
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<2x4xf32>
    gpu.launch_func  @elementwise_add_kernel::@elementwise_add_kernel blocks in (%c1, %c2, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<2x4xf32, strided<[?, ?], offset: ?>>, %alloc : memref<2x4xf32>)
    return %alloc : memref<2x4xf32>
  }
  gpu.module @elementwise_add_kernel {
    gpu.func @elementwise_add_kernel(%arg0: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg1: memref<2x4xf32, strided<[?, ?], offset: ?>>, %arg2: memref<2x4xf32>) kernel attributes {known_block_size = array<i32: 2, 2, 1>, known_grid_size = array<i32: 1, 2, 1>} {
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
      %0 = affine.apply #map()[%block_id_y]
      %1 = arith.addi %thread_id_y, %0 : index
      %2 = memref.load %arg0[%thread_id_x, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %3 = memref.load %arg1[%thread_id_x, %1] : memref<2x4xf32, strided<[?, ?], offset: ?>>
      %4 = arith.addf %2, %3 : f32
      memref.store %4, %arg2[%thread_id_x, %1] : memref<2x4xf32>
      gpu.return
    }
  }
  func.func @add_then_mul(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32, strided<[?, ?], offset: ?>>) -> memref<8x8xf32> {
    %c4 = arith.constant 4 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<8x8xf32>
    gpu.launch_func  @add_then_mul_kernel::@add_then_mul_kernel blocks in (%c4, %c4, %c1) threads in (%c2, %c2, %c1)  args(%arg0 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2 : memref<8x8xf32, strided<[?, ?], offset: ?>>, %alloc : memref<8x8xf32>)
    return %alloc : memref<8x8xf32>
  }
  gpu.module @add_then_mul_kernel {
    gpu.func @add_then_mul_kernel(%arg0: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg1: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg2: memref<8x8xf32, strided<[?, ?], offset: ?>>, %arg3: memref<8x8xf32>) kernel attributes {known_block_size = array<i32: 2, 2, 1>, known_grid_size = array<i32: 4, 4, 1>} {
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
      %4 = memref.load %arg0[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %5 = memref.load %arg1[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %6 = memref.load %arg2[%2, %3] : memref<8x8xf32, strided<[?, ?], offset: ?>>
      %7 = arith.addf %4, %5 : f32
      %8 = arith.mulf %7, %6 : f32
      memref.store %8, %arg3[%2, %3] : memref<8x8xf32>
      gpu.return
    }
  }
}

