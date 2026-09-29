#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Tools/Plugins/PassPlugin.h"

using namespace mlir;

namespace
{
    struct AddZeroPass : PassWrapper<AddZeroPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(AddZeroPass);

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

extern "C" ::mlir::PassPluginLibraryInfo
mlirGetPassPluginInfo()
{
    return {
        MLIR_PLUGIN_API_VERSION,
        "MyMLIRPass",
        "0.1",
        []()
        {
            registerMyPass();
        }
    };
}