LLVM_CONFIG ?= $(HOME)/llvm-project/build/bin/llvm-config
CXX := g++
CXXFLAGS := -std=c++17 $(shell $(LLVM_CONFIG) --cxxflags)
LIBS := $(shell $(LLVM_CONFIG) --ldflags --system-libs --libs core irreader transformutils)

.PHONY: run clean
dce: dce.cpp
	$(CXX) $(CXXFLAGS) $< $(LIBS) -o $@

run: dce
	./dce input.ll

clean:
	rm -f dce
