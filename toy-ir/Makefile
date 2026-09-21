CXX := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -O0 -g

.PHONY: study run test clean
study: STUDY.cpp
	$(CXX) $(CXXFLAGS) STUDY.cpp -o study

run: study
	./study

test: run

clean:
	rm -f study
