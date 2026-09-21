// Real LLVM: load a module, drop trivially dead insts, print IR.
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Local.h"

#include <string>

using namespace llvm;

static int dce_function(Function &fn) {
  int removed = 0;
  bool changed = true;
  while (changed) {
    changed = false;
    for (BasicBlock &bb : fn) {
      // Backward: a def is only dropped after later uses are gone.
      for (Instruction *inst = &bb.back(); inst != nullptr;) {
        Instruction *prev = inst->getPrevNode();
        if (isInstructionTriviallyDead(inst)) {
          inst->eraseFromParent();
          ++removed;
          changed = true;
        }
        inst = prev;
      }
    }
  }
  return removed;
}

int main(int argc, char **argv) {
  if (argc != 2) {
    errs() << "usage: dce <file.ll>\n";
    return 1;
  }

  LLVMContext ctx;
  SMDiagnostic err;
  auto mod = parseIRFile(argv[1], err, ctx);
  if (!mod) {
    err.print("dce", errs());
    return 1;
  }

  int removed = 0;
  for (Function &fn : *mod) {
    if (!fn.isDeclaration())
      removed += dce_function(fn);
  }
  errs() << "removed " << removed << "\n";
  mod->print(outs(), nullptr);
  return 0;
}
