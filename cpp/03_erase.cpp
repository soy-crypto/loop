// 03 — erase the middle without a dangling iterator
#include <iostream>
#include <vector>

int main()
{
  std::vector<int> v = {1, 2, 3, 4, 5};

  // Wrong: save it = v.begin()+2, erase, then use it again → UB.
  // Right: erase returns the next live iterator.
  for (auto it = v.begin(); it != v.end();)
  {
    if (*it == 3)
    {
      it = v.erase(it);
    }
    else
    {
      ++it;
    }
  }

  for (int x : v)
  {
    std::cout << x << " ";
  }
  std::cout << "\n"; // 1 2 4 5
  return 0;
}
