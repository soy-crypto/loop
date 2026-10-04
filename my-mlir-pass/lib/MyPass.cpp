#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

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

        StringRef getDescription() const override
        {
            return "Print function statistics";
        }

        void runOnOperation() override
        {
            getOperation()->walk([](func::FuncOp func)
            {
                //show func
                llvm::outs() << "-----" << func.getName() << "-----\n"; 
                //Compute
                llvm::StringMap<int> freqMap;
                func.walk([&](Operation *op)
                {
                    if(!isa<func::FuncOp>(op))
                    {
                        freqMap[op->getName().getStringRef()]++;
                    }

                });

                //Output
                llvm::outs() << "Function: " << func.getName() << "\n";
                llvm::outs() << "Content: \n" << func << "\n";
                llvm::outs() << "Arguments: "<< func.getNumArguments() << "\n";

                for(auto arg : func.getArguments())
                {
                    llvm::outs() << "Arg Type: " << arg.getType() << "\n";
                }

                llvm::outs() << "Operations: \n";
                for (auto &it : freqMap)
                {
                    llvm::outs() << it.getKey() << " : " << it.getValue() << "\n";
                }

                for (Type t : func.getResultTypes())
                {
                    llvm::outs() << "Return Type: " << t << "\n";
                }
                
                //LOOP 
                int loopCount = 0;
                func.walk([&](scf::ForOp loop)
                {
                    //count number of loops
                    loopCount++;

                    //output parameters
                    llvm::outs() << "Found loop \n";
                    llvm::outs() << "Lower Bound: " << loop.getLowerBound() << "\n";
                    llvm::outs() << "Upper Bound: " << loop.getUpperBound() << "\n";
                    llvm::outs() << "Step: " << loop.getStep() << "\n";
                    llvm::outs() << loop << "\n";
                    
                    //inside loop body
                    llvm::StringMap<int> counts;
                    loop.getBody()->walk([&](Operation *op)
                    {
                        if(!isa<scf::YieldOp>(op))
                        {
                            counts[op->getName().getStringRef()]++;
                        }

                    });

                    for(auto &item : counts)
                    {
                        llvm::outs() << item.getKey() << " : " << item.getValue() << "\n";
                    }

                });

                bool optimized = false;
                func.walk([&](scf::ForOp loop)
                {
                    loop.getBody()->walk([&](arith::AddIOp add)
                    {
                        bool invariant = true;
                        for(Value operand : add.getOperands())
                        {
                            auto *defOp = operand.getDefiningOp();
                            if(defOp && loop->isAncestor(defOp))
                            {
                                invariant = false;
                                break;
                            }

                        }//

                        if(invariant == true)
                        {
                            llvm::outs() << "Found invariant: " << add << "\n";
                            add->moveBefore(loop);
                            optimized = true;
                        }

                    });

                });
                
                llvm::outs() << "Loop count " << loopCount << "\n";

                //Optimized function
                if(optimized == true)
                {
                    llvm::outs() << "Optimized Func :" << func << "\n";
                }
                
                llvm::outs() << "\n\n";

            });

        }

    };

    //pass - licm
    struct LICMPass : PassWrapper<LICMPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LICMPass);
        StringRef getArgument() const override
        {
            return "licm";
        }

        StringRef getDescription() const override
        {
            return "licm code elimination!";
        }

        void runOnOperation() override
        {
            //travers all functions
            getOperation()->walk([&](func::FuncOp func)
            {
                //init
                bool global_Invariant = false;
                
                //traverse all loops
                func.walk([&](scf::ForOp loop)
                {
                    //current loop
                    bool invariant = false;

                    //traverse ops in the loop
                    loop.getBody()->walk([&](arith::AddIOp op)
                    {
                        //current op
                        bool localFlag = true;
                        for(Value operand : op.getOperands())
                        {
                           auto *defOp = operand.getDefiningOp();
                           localFlag |= defOp && loop->isAncestor(defOp) ? false : true; 
                        }//for

                        if(localFlag == true)
                        {
                            op->moveBefore(loop);
                        }

                        //update invariant
                        invariant |= localFlag;

                    });
                    
                    //update global invariant
                    global_Invariant |= invariant;
                    
                });

                //output
                if(global_Invariant == true)
                {
                    llvm::outs() << "LIVMed function" << func << "\n";
                }

            });

        }//void

    };

   
}//namespace

//Register
void registerMyPass()
{
    PassRegistration<MyPass>();
    PassRegistration<PrintOpsPass>();
    PassRegistration<FunctionStatsPass>();
    PassRegistration<LICMPass>();
}