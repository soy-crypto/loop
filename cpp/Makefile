CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -O0 -g

SRCS := 01_ptr_ref.cpp 02_vector.cpp 03_erase.cpp 04_own.cpp \
        05_new_vs_unique.cpp 06_pass.cpp 07_insts.cpp 08_ub.cpp
BINS := 01 02 03 04 05 06 07 08

.PHONY: all run clean
all: $(BINS)

01: 01_ptr_ref.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
02: 02_vector.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
03: 03_erase.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
04: 04_own.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
05: 05_new_vs_unique.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
06: 06_pass.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
07: 07_insts.cpp
	$(CXX) $(CXXFLAGS) $< -o $@
08: 08_ub.cpp
	$(CXX) $(CXXFLAGS) $< -o $@

run: all
	./01 && ./02 && ./03 && ./04 && ./05 && ./06 && ./07 && ./08

clean:
	rm -f $(BINS) own
