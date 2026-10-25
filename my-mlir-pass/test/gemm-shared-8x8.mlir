#map = affine_map<()[s0] -> (s0 * 8)>
module {
  func.func @gemm(%A: memref<64x64xf32>, %B: memref<64x64xf32>,
                  %C: memref<64x64xf32>)
      attributes {llvm.emit_c_interface, toy.accumulator_safe} {
    %zero = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c8 = arith.constant 8 : index
    %c64 = arith.constant 64 : index
    gpu.launch blocks(%bx, %by, %bz)
        in (%gx = %c8, %gy = %c8, %gz = %c1)
        threads(%tx, %ty, %tz)
        in (%sx = %c8, %sy = %c8, %sz = %c1)
        workgroup(%As: memref<8x8xf32, #gpu.address_space<workgroup>>,
                  %Bs: memref<8x8xf32, #gpu.address_space<workgroup>>) {
      %rowBase = affine.apply #map()[%bx]
      %colBase = affine.apply #map()[%by]
      %row = arith.addi %ty, %rowBase : index
      %col = arith.addi %tx, %colBase : index

      // Eight stages, each covering eight consecutive k values.
      %result = scf.for %kb = %c0 to %c64 step %c8
          iter_args(%acc = %zero) -> (f32) {
        // The 64 threads collectively load each 8x8 input tile once.
        %aK = arith.addi %kb, %tx : index
        %bK = arith.addi %kb, %ty : index
        %a = memref.load %A[%row, %aK] : memref<64x64xf32>
        %b = memref.load %B[%bK, %col] : memref<64x64xf32>
        memref.store %a, %As[%ty, %tx]
            : memref<8x8xf32, #gpu.address_space<workgroup>>
        memref.store %b, %Bs[%ty, %tx]
            : memref<8x8xf32, #gpu.address_space<workgroup>>
        gpu.barrier

        %next = scf.for %kk = %c0 to %c8 step %c1
            iter_args(%partial = %acc) -> (f32) {
          %av = memref.load %As[%ty, %kk]
              : memref<8x8xf32, #gpu.address_space<workgroup>>
          %bv = memref.load %Bs[%kk, %tx]
              : memref<8x8xf32, #gpu.address_space<workgroup>>
          %product = arith.mulf %av, %bv : f32
          %sum = arith.addf %product, %partial : f32
          scf.yield %sum : f32
        }

        // All readers finish before any thread overwrites the next tile.
        gpu.barrier
        scf.yield %next : f32
      }
      memref.store %result, %C[%row, %col] : memref<64x64xf32>
      gpu.terminator
    } {SCFToGPU_visited}
    return
  }
}
