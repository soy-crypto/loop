// 08 — what is UB (do not uncomment the bad lines)
#include <iostream>
#include <vector>

int main() {
  // 1. Dangling pointer into a vector after it grows
  std::vector<int> v = {1};
  int *p = &v[0];
  (void)p;
  v.push_back(2); // may move the buffer
  // std::cout << *p;  // UB if the buffer moved

  // 2. Use after free
  int *q = new int(3);
  delete q;
  // std::cout << *q;  // UB
  q = nullptr;

  // 3. Iterator after erase
  std::vector<int> w = {1, 2, 3};
  auto it = w.begin() + 1;
  w.erase(it);
  // ++it;  // UB
  // *it;   // UB

  std::cout << "compiled; the commented lines would be UB\n";
  return 0;
}
