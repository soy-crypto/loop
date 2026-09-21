NVCC := nvcc
NVCCFLAGS := -O2 -std=c++17

.PHONY: run
run: gemm
	./gemm

gemm: gemm.cu
	$(NVCC) $(NVCCFLAGS) gemm.cu -o gemm
