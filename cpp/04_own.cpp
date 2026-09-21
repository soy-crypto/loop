// 04 — unique_ptr owns children. reset() frees the subtree. no delete.
#include <iostream>
#include <memory>
#include <string>
#include <utility>

struct Node
{
  std::string name;
  std::unique_ptr<Node> left;
  std::unique_ptr<Node> right;
  explicit Node(std::string n) : name(std::move(n))
  {
  }
};

static void wipe(std::unique_ptr<Node> &n)
{
  n.reset();
}

int main()
{
  auto root = std::make_unique<Node>("root");
  root->left = std::make_unique<Node>("L");
  root->right = std::make_unique<Node>("R");
  root->left->left = std::make_unique<Node>("LL");

  wipe(root->left);
  std::cout << root->name << " left=" << (root->left ? "live" : "dead")
            << " right=" << root->right->name << "\n";
  return 0;
}
