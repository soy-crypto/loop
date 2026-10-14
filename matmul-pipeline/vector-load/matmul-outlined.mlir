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
      %c64 = arith.constant 64 : index
      %c4 = arith.constant 4 : index
      %c1 = arith.constant 1 : index
      %c0 = arith.constant 0 : index
      %c16 = arith.constant 16 : index
      %cst = arith.constant 0.000000e+00 : f32
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %thread_id_x = gpu.thread_id  x
      %thread_id_y = gpu.thread_id  y
      %0 = affine.apply #map()[%block_id_x]
      %1 = affine.apply #map()[%block_id_y]
      %2 = arith.addi %thread_id_x, %0 : index
      %3 = arith.addi %thread_id_y, %1 : index
      %alloca = memref.alloca() : memref<16x16xf32, #gpu.address_space<workgroup>>
      %alloca_0 = memref.alloca() : memref<16x16xf32, #gpu.address_space<workgroup>>
      %base_buffer, %offset, %sizes:2, %strides:2 = memref.extract_strided_metadata %arg0 : memref<128x128xf32, strided<[?, ?], offset: ?>> -> memref<f32>, index, index, index, index, index
      %reinterpret_cast = memref.reinterpret_cast %arg0 to offset: [%offset], sizes: [128, 128], strides: [%strides#0, 1] : memref<128x128xf32, strided<[?, ?], offset: ?>> to memref<128x128xf32, strided<[?, 1], offset: ?>>
      %base_buffer_1, %offset_2, %sizes_3:2, %strides_4:2 = memref.extract_strided_metadata %arg1 : memref<128x128xf32, strided<[?, ?], offset: ?>> -> memref<f32>, index, index, index, index, index
      %reinterpret_cast_5 = memref.reinterpret_cast %arg1 to offset: [%offset_2], sizes: [128, 128], strides: [%strides_4#0, 1] : memref<128x128xf32, strided<[?, ?], offset: ?>> to memref<128x128xf32, strided<[?, 1], offset: ?>>
      %4 = scf.for %arg6 = %arg3 to %arg4 step %c16 iter_args(%arg7 = %cst) -> (f32) {
        %5 = arith.muli %thread_id_y, %c16 : index
        %6 = arith.addi %thread_id_x, %5 : index
        %7 = arith.cmpi ult, %6, %c64 : index
        scf.if %7 {
          %9 = arith.divui %6, %c4 : index
          %10 = arith.remui %6, %c4 : index
          %11 = arith.muli %10, %c4 : index
          %12 = arith.addi %0, %9 : index
          %13 = arith.addi %arg6, %11 : index
          %14 = arith.addi %arg6, %9 : index
          %15 = arith.addi %1, %11 : index
          %16 = vector.load %reinterpret_cast[%12, %13] : memref<128x128xf32, strided<[?, 1], offset: ?>>, vector<4xf32>
          vector.store %16, %alloca[%9, %11] : memref<16x16xf32, #gpu.address_space<workgroup>>, vector<4xf32>
          %17 = vector.load %reinterpret_cast_5[%14, %15] : memref<128x128xf32, strided<[?, 1], offset: ?>>, vector<4xf32>
          vector.store %17, %alloca_0[%9, %11] : memref<16x16xf32, #gpu.address_space<workgroup>>, vector<4xf32>
        }
        gpu.barrier
        %8 = scf.for %arg8 = %c0 to %c16 step %c1 iter_args(%arg9 = %arg7) -> (f32) {
          %9 = memref.load %alloca[%thread_id_x, %arg8] : memref<16x16xf32, #gpu.address_space<workgroup>>
          %10 = memref.load %alloca_0[%arg8, %thread_id_y] : memref<16x16xf32, #gpu.address_space<workgroup>>
          %11 = arith.mulf %9, %10 : f32
          %12 = arith.addf %arg9, %11 : f32
          scf.yield %12 : f32
        }
        gpu.barrier
        scf.yield %8 : f32
      }
      memref.store %4, %arg2[%2, %3] : memref<128x128xf32, strided<[?, ?], offset: ?>>
      gpu.return
    }
  }
}

