#!/usr/bin/env bash
# Run from /root/loop/my-mlir-pass. Pass --profile to collect four paired runs.
# Untiled and tiled both use row=bx*8+ty, col=by*8+tx and an f32 accumulator.
set -euo pipefail

if [[ $# -gt 1 || ( $# -eq 1 && $1 != --profile ) ]]; then
  printf 'Usage: bash gemm-shared-tiling.sh [--profile]\n' >&2
  exit 2
fi
if [[ ! -f test/gemm-map-threads.mlir || ! -f test/gemm-test.cpp ]]; then
  printf 'Run from the project root containing test/gemm-map-threads.mlir and test/gemm-test.cpp.\n' >&2
  exit 1
fi
mkdir -p build

cat > test/gemm-shared-8x8.mlir <<'MLIR'
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
MLIR

build_gemm() {
  local gemm_input=$1
  local gemm_prefix=$2
  # Outline immediately; no standalone gpu.launch pretty-print is needed.
  mlir-opt-21 "$gemm_input" --gpu-kernel-outlining \
    -o "${gemm_prefix}-outlined.mlir"
  mlir-opt-21 "${gemm_prefix}-outlined.mlir" \
    --pass-pipeline='builtin.module(gpu.module(lower-affine,convert-scf-to-cf,convert-gpu-to-nvvm,reconcile-unrealized-casts,canonicalize,cse))' \
    -o "${gemm_prefix}-nvvm.mlir"
  mlir-opt-21 "${gemm_prefix}-nvvm.mlir" \
    --nvvm-attach-target='chip=sm_86 features=+ptx80' \
    --gpu-module-to-binary='format=isa' -o "${gemm_prefix}-ptx.mlir"
  mlir-opt-21 "${gemm_prefix}-ptx.mlir" \
    --expand-strided-metadata --lower-affine --convert-scf-to-cf \
    --convert-to-llvm --gpu-to-llvm --reconcile-unrealized-casts \
    -o "${gemm_prefix}-host.mlir"
  mlir-translate-21 "${gemm_prefix}-host.mlir" --mlir-to-llvmir \
    -o "${gemm_prefix}-host.ll"
  clang-21 -O2 -c "${gemm_prefix}-host.ll" -o "${gemm_prefix}-host.o"
  clang++-21 -std=c++17 -O2 test/gemm-test.cpp "${gemm_prefix}-host.o" \
    -Lruntime -lmlir_cuda_runtime -lcuda \
    -Wl,-rpath,'$ORIGIN/../runtime' -o "$gemm_prefix"
}

build_gemm test/gemm-map-threads.mlir build/gemm-shared-untiled
build_gemm test/gemm-shared-8x8.mlir build/gemm-shared-tiled

for gemm_variant in untiled tiled; do
  printf '\n%s correctness and host timing:\n' "$gemm_variant"
  "build/gemm-shared-${gemm_variant}"
done

if [[ ${1:-} != --profile ]]; then
  printf '\nTo collect paired GPU timings, rerun with --profile.\n'
  exit 0
fi

# Rotate order. Retain each round rather than treating one run as a winner.
for gemm_round in 1 2 3 4; do
  if (( gemm_round % 2 == 0 )); then
    gemm_order=(tiled untiled)
  else
    gemm_order=(untiled tiled)
  fi
  for gemm_variant in "${gemm_order[@]}"; do
    gemm_report="build/gemm-shared-${gemm_variant}-r${gemm_round}"
    nsys profile --trace=cuda --sample=none --cpuctxsw=none \
      --force-overwrite=true -o "$gemm_report" \
      "build/gemm-shared-${gemm_variant}"
    nsys stats --force-export=true --report=cuda_gpu_kern_sum \
      "${gemm_report}.nsys-rep"
  done
done

python3 - <<'PY'
from pathlib import Path
import sqlite3
import statistics

print('\nGPU kernel timings: 100 timed calls; first 11 launches excluded.')
print(f'{"Round":<7}{"Variant":<10}{"Mean_us":>12}{"Median_us":>12}')
for round_no in (1, 2, 3, 4):
    for variant in ('untiled', 'tiled'):
        path = Path(f'build/gemm-shared-{variant}-r{round_no}.sqlite')
        with sqlite3.connect(path.resolve().as_uri() + '?mode=ro', uri=True) as db:
            durations = [row[0] / 1000.0 for row in db.execute(
                'SELECT "end" - "start" FROM CUPTI_ACTIVITY_KIND_KERNEL ORDER BY "start"'
            )]
        if len(durations) != 111:
            raise RuntimeError(f'{path}: expected 111 kernels, got {len(durations)}; '
                               'check the driver before interpreting this summary')
        timed = durations[11:]
        print(f'{round_no:<7}{variant:<10}'
              f'{statistics.mean(timed):>12.3f}{statistics.median(timed):>12.3f}')
PY
