#!/usr/bin/env bash
# Run from the my-mlir-pass project root with: bash test/check-accumulator.sh
set -euo pipefail

pass_tool=./build/my-opt
if [[ ! -x "$pass_tool" ]]; then
  printf 'ERROR: run from the project root after building build/my-opt.\n' >&2
  exit 1
fi
if ! command -v rg >/dev/null 2>&1; then
  printf 'ERROR: rg is required.\n' >&2
  exit 1
fi

test_outputs=$(mktemp -d)
trap 'rm -rf -- "$test_outputs"' EXIT

check_case() {
  local case_name=$1
  local input_file=$2
  local expected=$3
  local output_file="$test_outputs/$case_name.mlir"

  if [[ ! -f "$input_file" ]]; then
    printf 'FAIL: %s: input file missing: %s\n' "$case_name" "$input_file" >&2
    return 1
  fi
  if ! "$pass_tool" "$input_file" --toy-pa -o "$output_file"; then
    printf 'FAIL: %s: the pass command failed.\n' "$case_name" >&2
    return 1
  fi
  if [[ ! -s "$output_file" ]]; then
    printf 'FAIL: %s: the pass produced no output.\n' "$case_name" >&2
    return 1
  fi
  local loop_status=0
  rg -q 'scf\.for' "$output_file" || loop_status=$?
  if [[ "$loop_status" == 1 ]]; then
    printf 'FAIL: %s: expected a loop in the output.\n' "$case_name" >&2
    return 1
  elif [[ "$loop_status" != 0 ]]; then
    printf 'FAIL: %s: searching for the loop failed.\n' "$case_name" >&2
    return 1
  fi

  local search_status=0
  local actual
  rg -q '\biter_args\b' "$output_file" || search_status=$?
  case "$search_status" in
    0) actual=promote ;;
    1) actual=skip ;;
    *)
      printf 'FAIL: %s: searching the output failed.\n' "$case_name" >&2
      return 1
      ;;
  esac

  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s: expected %s, got %s.\n' "$case_name" "$expected" "$actual" >&2
    return 1
  fi
  printf 'PASS: %s\n' "$case_name"
}

check_case valid test/gemm-launch.mlir promote
check_case missing_attribute test/gemm-no-marker.mlir skip
check_case wrong_store test/gemm-wrong-store.mlir skip
printf 'PASS: all 3 accumulator regression checks\n'
