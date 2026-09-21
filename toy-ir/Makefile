CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -O0 -g

dump: dump.cpp main.cpp ir.h
	$(CXX) $(CXXFLAGS) dump.cpp main.cpp -o dump

test_dce: dump.cpp dce.cpp test_dce.cpp ir.h dce.h
	$(CXX) $(CXXFLAGS) dump.cpp dce.cpp test_dce.cpp -o test_dce

test_cse: dump.cpp cse.cpp test_cse.cpp ir.h cse.h
	$(CXX) $(CXXFLAGS) dump.cpp cse.cpp test_cse.cpp -o test_cse

.PHONY: run test clean
run: dump
	./dump

test: test_dce test_cse
	./test_dce
	./test_cse

clean:
	rm -f dump test_dce test_cse
