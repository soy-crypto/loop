OPT ?= $(HOME)/llvm-project/build/bin/mlir-opt

.PHONY: fuse tile run
fuse:
	$(OPT) fuse.mlir --linalg-fuse-elementwise-ops

tile:
	$(OPT) tile.mlir --affine-loop-tile="tile-size=32"

run: fuse tile
