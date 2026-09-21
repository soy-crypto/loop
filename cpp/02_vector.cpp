// 02 — vector: grow and read
#include <iostream>
#include <vector>

int main()
{
  std::vector<int> v;
  v.push_back(10);
  v.push_back(20);
  v.push_back(30);

  std::cout << "size=" << v.size() << " cap=" << v.capacity() << "\n";
  for (size_t i = 0; i < v.size(); ++i)
  {
    std::cout << v[i] << (i + 1 == v.size() ? "\n" : " ");
  }

  // range-for is also fine; it does not invalidate while you only read
  int sum = 0;
  for (int x : v)
  {
    sum += x;
  }
  std::cout << "sum=" << sum << "\n";
  return 0;
}
