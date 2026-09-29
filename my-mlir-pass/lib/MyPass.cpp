#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"

using namespace mlir;

namespace
{
    //Pattern
    struct AddZeroPattern : public OpRewritePattern<arith::AddIOp>
    {
        using OpRewritePattern:: OpRewritePattern;

        LogicalResult matchAndRewrite(arith::AddIOp op, PatternRewriter &rewriter) const override
        {
            llvm::outs() << "Found addi\n";
            
            auto lhs = op.getLhs().getDefiningOp<arith::ConstantIntOP>();
            auto rhs = op.getRhs().getDefiningOp<arith::ConstantIntOp>();
            if(lhs != null && lhs.value() == 0)
            {
                rewriter.replaceOp(op, op.getLhs());
                return success();
            }

            if(rhs != null && rhs.value() == 0)
            {
                rewriter.replaceOp(op, op.getRhs());
                return success();
            }

            return failure();
        }

    };

    //Pass
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
            RewritePatternSet patterns(&getContext());
            patterns.add<AddZeroPattern>(&getContext());
            if(failed(applyPatternsGreedily(getOperation(), std::move(patterns))))
            {
                signalPassFailure();
            }
            
        }

    };

    //Register
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