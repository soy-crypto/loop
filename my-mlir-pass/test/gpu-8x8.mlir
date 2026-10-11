// Launch with grid = (4, 4, 1), block = (2, 2, 1).
// x indexes columns; y indexes rows.
// All four buffers must be accessible from the GPU.
module 
{
  gpu.module @kernels 
  {
    gpu.func @add_then_mul_gpu(
        %a: memref<8x8xf32>,
        %b: memref<8x8xf32>,
        %scale: memref<8x8xf32>,
        %out: memref<8x8xf32>) kernel {
      %c2 = arith.constant 2 : index

      %block_row = gpu.block_id y
      %block_col = gpu.block_id x
      %thread_row = gpu.thread_id y
      %thread_col = gpu.thread_id x

      %row_base = arith.muli %block_row, %c2 : index
      %col_base = arith.muli %block_col, %c2 : index
      %row = arith.addi %row_base, %thread_row : index
      %col = arith.addi %col_base, %thread_col : index

      %av = memref.load %a[%row, %col] : memref<8x8xf32>
      %bv = memref.load %b[%row, %col] : memref<8x8xf32>
      %sv = memref.load %scale[%row, %col] : memref<8x8xf32>
      %sum = arith.addf %av, %bv : f32
      %product = arith.mulf %sum, %sv : f32
      memref.store %product, %out[%row, %col] : memref<8x8xf32>
      gpu.return
    }
  }
}

