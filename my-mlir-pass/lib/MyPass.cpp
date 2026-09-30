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
    //Patterns
    // x + 0 -> x
    struct AddZeroPattern : public OpRewritePattern<arith::AddIOp>
    {
        using OpRewritePattern:: OpRewritePattern;

        LogicalResult matchAndRewrite(arith::AddIOp op, PatternRewriter &rewriter) const override
        {
            llvm::outs() << "Found addi\n";
            
            auto lhs = op.getLhs().getDefiningOp<arith::ConstantIntOp>();
            auto rhs = op.getRhs().getDefiningOp<arith::ConstantIntOp>();
            if(lhs != nullptr && lhs.value() == 0)
            {
                rewriter.replaceOp(op, op.getRhs());
                return success();
            }

            if(rhs != nullptr && rhs.value() == 0)
            {
                rewriter.replaceOp(op, op.getLhs());
                return success();
            }

            return failure();
        }

    };

    
    // x * 1 -> x
    struct MulOnePattern : OpRewritePattern<arith::MulIOp>
    {
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::MulIOp op, PatternRewriter &rewriter) const override
        {
            auto lhs = op.getLhs().getDefiningOp<arith::ConstantIntOp>();
            auto rhs = op.getRhs().getDefiningOp<arith::ConstantIntOp>();

            if(lhs != nullptr && lhs.value() == 1)
            {
                rewriter.replaceOp(op, op.getRhs());
                return success();
            }

            if(rhs != nullptr && rhs.value() == 1)
            {
                rewriter.replaceOp(op, op.getLhs());
                return success();
            }

            //return
            return failure();
        }//logcial

    };


    // const + const -> const
    struct ConstantFoldPattern : OpRewritePattern<arith::AddIOp>
    {
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::AddIOp op, PatternRewriter &rewriter) const override
        {
            auto lhs = op.getLhs().getDefiningOp<arith::ConstantIntOp>();
            auto rhs = op.getRhs().getDefiningOp<arith::ConstantIntOp>();

            if(lhs != nullptr && rhs != nullptr)
            {
                int64_t result = lhs.value() + rhs.value();
                auto newConst = rewriter.create<arith::ConstantIntOp>(op.getLoc(), result, 32);
                rewriter.replaceOp(op, newConst);
                return success();
            }
            else
            {
                return failure();
            }

        }//

    };//

    //Pass
    struct MyPass : PassWrapper<MyPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MyPass);

        StringRef getArgument() const override
        {
            return "my-add-zero";
        }

        StringRef getDescription() const override
        {
            return "Simple MLIR optimizaiton pass";
        }
        
        void runOnOperation() override
        {
            RewritePatternSet patterns(&getContext());
            patterns.add<AddZeroPattern, MulOnePattern, ConstantFoldPattern>(&getContext());
            if(failed(applyPatternsGreedily(getOperation(), std::move(patterns))))
            {
                signalPassFailure();
            }
            
        }

    };

   
}//namespace

//Register
void registerMyPass()
{
    PassRegistration<MyPass>();
}