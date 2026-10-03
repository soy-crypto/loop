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
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::AddIOp op, PatternRewriter &rewriter) const override
        {
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();

            if(lcst != nullptr && lcst.value() == 0)
            {
                rewriter.replaceOp(op, lhs);
                return success();
            }

            if(rcst != nullptr && rcst.value() == 0)
            {
                rewriter.replaceOp(op, rhs);
                return success();
            }

            return failure();
        }

    };

    
    // x * 1 -> x
    struct MulOnePattern : OpRewritePattern<arith::MulIOp>
    {
        using OpRewritePattern:: OpRewritePattern;

        LogicalResult matchAndRewrite(arith::MulIOp op, PatternRewriter &rewriter) const override
        {
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();

            if(lcst != nullptr && lcst.value() == 1)
            {
                rewriter.replaceOp(op, lhs);
                return success();
            }

            if(rcst != nullptr && rcst.value() == 1)
            {
                rewriter.replaceOp(op, rhs);
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
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();

            if(lcst != nullptr && rcst != nullptr)
            {
                int64_t result = lcst.value() + rcst.value();
                auto newConst = rewriter.create<arith::ConstantIntOp>(op.getLoc(), result, 32);
                rewriter.replaceOp(op, newConst);
                return success();
            }
            else
            {
                return failure();
            }

        }

    };//

    // x * 0 -> 0
    struct MulZeroPattern : OpRewritePattern<arith::MulIOp>
    {
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::MulIOp op, PatternRewriter &rewriter) const override
        {
            //get left oprand and right oprand
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();
            
            //check
            if(lcst != nullptr && lcst.value() == 0)
            {
                rewriter.replaceOp(op, lhs);
                return success();
            }
            else if(rcst != nullptr && rcst.value() == 0)
            {
                rewriter.replaceOp(op, rhs);
                return success();
            }
            else
            {
                return failure();
            }
            
        }

    }; 

    // *0 pattern
    struct SubSelfPattern : OpRewritePattern<arith::SubIOp>
    {
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::SubIOp op, PatternRewriter &rewriter) const override
        {
            //get left and right operands
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();

            if(lhs == rhs)
            {
                auto zero = rewriter.create<arith::ConstantIntOp>(op.getLoc(), 0, 32);
                rewriter.replaceOp(op, zero);
                return success();
            }
            else
            {
                return failure();
            }

        }//

    };

    struct ConstantMulFoldPattern : OpRewritePattern<arith::MulIOp>
    {
        using OpRewritePattern::OpRewritePattern;

        LogicalResult matchAndRewrite(arith::MulIOp op, PatternRewriter &rewriter) const override
        {
            auto lhs = op.getLhs(), rhs = op.getRhs();
            auto lcst = lhs.getDefiningOp<arith::ConstantIntOp>();
            auto rcst = rhs.getDefiningOp<arith::ConstantIntOp>();

            if(lcst != nullptr && rcst != nullptr)
            {
                llvm::outs() << "Found constant muli\n";
                auto newValue = rewriter.create<arith::ConstantIntOp>(op.getLoc(), lcst.value() * rcst.value(), 32);
                rewriter.replaceOp(op, newValue);
                return success();
            }
            else
            {
                return failure();
            }

        }

    };


    //Pass
    //pass1
    struct MyPass : PassWrapper<MyPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MyPass);

        StringRef getArgument() const override
        {
            return "pass";
        }

        StringRef getDescription() const override
        {
            return "Simple MLIR optimizaiton pass";
        }
        
        void runOnOperation() override
        {
            RewritePatternSet patterns(&getContext());
            patterns.add<AddZeroPattern, MulOnePattern, ConstantFoldPattern, MulZeroPattern, SubSelfPattern, ConstantMulFoldPattern>(&getContext());
            if(failed(applyPatternsGreedily(getOperation(), std::move(patterns))))
            {
                signalPassFailure();
            }
            
        }

    };

    //pass2
    struct PrintOpsPass : PassWrapper<PrintOpsPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(PrintOpsPass);

        StringRef getArgument() const override
        {
            return "print-ops";
        }

        void runOnOperation() override
        {
            getOperation()->walk([](arith::AddIOp op) { llvm::outs() << "ADD: " << op << "\n"; });
            getOperation()->walk([](arith::MulIOp op) { llvm::outs() << "MUL: " << op << "\n"; });
        }

    };

    //pass3
    struct FunctionStatsPass : PassWrapper<FunctionStatsPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(FunctionStatsPass);

        StringRef getArgument() const override
        {
            return "func-stats";
        }

        StringRef getDescription() override
        {
            return "Print function statistics";
        }

        void runOnOperation() override
        {
            getOperation()->walk([](func::FuncOp func)
            {
                int opCount = 0;
                func.walk([&](Operation *op) { opCount++;});
            });

        }

    }

   
}//namespace

//Register
void registerMyPass()
{
    PassRegistration<MyPass>();
    PassRegistration<PrintOpsPass>();
}