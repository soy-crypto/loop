#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/IR/PatternMatch.h"

using namespace mlir;

namespace
{
    struct AddZeroPass : PassWrapper<AddZeroPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICT_INTERNAL_INLINE_TYPE_ID(AddZeroPass)

        StringRef getArgument() const override
        {
            return "my-add-zero";
        }

        StringRef getDescription() const override
        {
            return "My first MLIR pass";
        }
        
        void runOnOperation() override
        {
            return;
        }

    };

    void registerMyPass()
    {
        PassRegistration<AddZeroPass>();
    }

}

extern "C" void mlirRegisterMyPasses()
{
    registerMyPass();
}