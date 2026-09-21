// 01 — pointer vs reference
#include <iostream>

static void add_ptr(int *p)
{
  if (!p)
  {
    return;
  }
  *p += 1;
}

static void add_ref(int &r)
{
  r += 1;
}

int main()
{
  int x = 10;
  add_ptr(&x);
  add_ref(x);
  std::cout << x << "\n"; // 12

  int *p = nullptr;
  add_ptr(p); // ok: we checked
  // add_ref(*p); // UB: cannot bind a ref to null
  return 0;
}
