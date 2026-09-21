// 06 — how you pass a vector
#include <iostream>
#include <vector>

static void by_value(std::vector<int> v)
{
  v.push_back(99);
}

static void by_const_ref(const std::vector<int> &v)
{
  std::cout << "seen " << v.size() << "\n";
  // v.push_back(1); // does not compile
}

static void by_ref(std::vector<int> &v)
{
  v.push_back(99);
}

int main()
{
  std::vector<int> v = {1, 2};
  by_value(v);
  std::cout << "after value " << v.size() << "\n"; // still 2
  by_const_ref(v);
  by_ref(v);
  std::cout << "after ref " << v.size() << "\n"; // 3
  return 0;
}
