// 05 — new/delete vs unique_ptr
#include <iostream>
#include <memory>

int main() {
  int *raw = new int(7);
  std::cout << *raw << "\n";
  delete raw;
  raw = nullptr; // after delete, do not read *raw (UB)

  auto p = std::make_unique<int>(7);
  std::cout << *p << "\n";
  p.reset(); // frees; no delete
  // *p  would be UB now
  return 0;
}
