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
    //pass - patterns
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

    //pass3 - Function
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

    //pass - LICM
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
            //Disply start
            llvm::outs() << "-----LICM start -----" << "\n";

            //travers all functions
            getOperation()->walk([&](func::FuncOp func)
            {
                //Traverse all loops
                bool funcChanged = false;
                func.walk([&](scf::ForOp loop)
                {
                    //current loop
                    bool moved = true;
                    while(true)
                    {
                        //TC
                        if(moved == false)
                        {
                            break;
                        }

                        //Body
                        SmallVector<Operation*> movedOps;
                        loop.getBody()->walk([&](Operation *op)
                        {
                            //Check current op
                            bool found = false;
                            if(isa<arith::ConstantOp>(op))
                            {
                                found = true;
                            }
                            else if(!isa<scf::YieldOp>(op) && !isa<func::ReturnOp>(op))
                            {
                                bool flag = true;
                                for(Value operand : op->getOperands())
                                {
                                    if(operand != loop.getInductionVar())
                                    {
                                        auto *defOp = operand.getDefiningOp();
                                        flag &= defOp && loop->isAncestor(defOp) ? false : true; 
                                    }
                                    else
                                    {
                                        flag = false;
                                        break;
                                    }
                                    
                                }//for

                                //Update found
                                found = flag;

                            }//else

                            //Update movedOps
                            if(found == true)
                            {
                                movedOps.push_back(op);
                            }

                        });
                        
                        //Move operations
                        if(!movedOps.empty())
                        {
                            for(Operation *op : movedOps)
                            {
                                op->moveBefore(loop);
                            }//

                            moved = true;
                            funcChanged = true;

                        }//if
                        else
                        {
                            moved = false;
                        }
                        
                    }//while
                    
                });

                //Display optimized func
                if(funcChanged == true)
                {
                    llvm::outs() << "Optimized! : " << func << "\n";
                }

            });
            
            //Display end
            llvm::outs() << "-----LICM end -----\n" << "\n";

            //return
            return;

        }//void

    }; //LICM Pass

    //pass - DCE
    struct DCEPass : PassWrapper<DCEPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(DCEPass);
        
        StringRef getArgument() const override
        {
            return "dce";
        }

        StringRef getDescription() const override
        {
            return "dce elimination!";
        }
        
        void runOnOperation() override
        {
            //Display start
            llvm::outs() << "-----DCE Start-----" << "\n";

            //Travers all ops
            getOperation()->walk([](func::FuncOp func)
            {
                //Dec found status
                bool found = false;

                //Dec checking
                bool moved = true;
                SmallVector<Operation*> movedOps;
                while(true)
                {
                    //tc
                    if(moved == false)
                    {
                        break;
                    }

                    //body
                    func.walk([&](Operation* op)
                    {
                        if(op->use_empty() && op->getNumResults() >= 1)
                        {
                            movedOps.push_back(op);
                            found = true;
                        }

                    });

                    //moved
                    if(!movedOps.empty())
                    {
                        for(Operation* op : movedOps)
                        {
                            op->erase();
                        }
                        movedOps.clear();
                        
                        moved = true;
                    }
                    else
                    {
                        moved = false;
                    }
                    
                }//while

                //show dced func
                if(found == true)
                {
                    llvm::outs() << "DECed Func : " << func << "\n";
                }
                
            });

            //Display end
            llvm::outs() << "-----DCE End-----" << "\n";
            
            //Return
            return;
        }

    }; //DCE Pass

    //pass - CF
    struct CFPass: PassWrapper<CFPass, OperationPass<ModuleOp>>
    {
        MLIR_DEFINE_EXPLICIT_INLINE_TYPE_ID(CFPass);
        
        StringRef getArgument() const override
        {
            return "cf";
        }

        StringRef getDescription() const override
        {
            return "cf elimination";
        }

        //get all dead ops of current func
        llvm::DenseMap<Operation* op, int64_t> getFoldedOps(func::FuncOp func)
        {
            //Check validity
            if(func == nullptr)
            {
                return {};
            }
            
            //Get all deadOps of current funct
            llvm::DenseMap<Operation* op, int64_t> foldedOpsMap;
            func.walk([&](Operation* op)
            {
                //Init
                if(op->getNumResults() != 1 || op->getOperands().size() != 2)
                {
                    return; 
                }
                
                //Check current op is dead op
                auto operands = op->getOperands();
                auto lhsDef = operands[0].getDefiningOp<arith::ConstantOp>();
                auto rhsDef = operands[1].getDefiningOp<arith::ConstantOp>();
                if(lhsDef != nullptr && rhsDef != nullptr)
                {
                    //get left attrs and right attrs
                    auto lhsAttr = dyn_cast<IntegerAttr>(lhsDef.getValue());
                    auto rhsAttr = dyn_cast<IntegerAttr>(rhsDef.getValue());
                    if(lhsAttr == nullptr || rhsAttr == nullptr)
                    {
                        return;
                    }

                    //compute new constant
                    int64_t lV = lhsAttr.getInt(), rV = rhsAttr.getInt();
                    if(isa<arith::AddIOp>(op) || isa<arith::MulIOp>(op) || isa<arith::SubIOp>(op) || (isa<arith::RemSIOp>(op) && rV != 0) || (isa<arith::DivSIOp>(op) && rV != 0))
                    {
                        foldedOpsMap[op] = getConstantResult(op, lV, rV);
                    }

                }//if

                //Return
                return;
            });

            //Return
            return foldedOpsMap;
        
        }//getDeadOps()

        int64_t getConstantResult(Operation* op, int64_t lV, int64_t rV)
        {
            //Check validity
            if(op == nullptr)
            {
                return 0;
            }

            //compoute
            int64_t result = 0;
            if(isa<arith::AddIOp>(op))
            {
                result = lV + rV;
            }
            else if(isa<arith::MulIOp>(op))
            {
                result = lV * rV;
            }
            else if(isa<arith::SubIOp>(op))
            {
                result = lV - rV;
            }
            else if(is<arith::DivSIOp>(op))
            {
                result = lV / rV;
            }
            else // % computatiob
            {
                result = lV % rV;
            }

            //Return
            return result;
        }//

        //operations
        void runOnOperation() override
        {   
            //traverse all funcs
            getOperation()->walk([](func::FuncOp func)
            {
                //check validity
                if(func == nullptr)
                {
                    return;
                }

                //CF action
                bool deleted = true;
                llvm::DenseMap<Operation* op, int64_t> foldedOpsMap;
                while(true)
                {
                    if(deleted == false)
                    {
                        break;
                    }

                    //get dead ops of current func
                    foldedOpsMap = getDeadOps(func);
                    
                    //batch erase dead ops
                    if(!foldedOpsMap.empty())
                    {
                        for(auto &[op, result] : foldedOpsMap)
                        {
                            //replace CF ops
                            OpBuilder builder(op);
                            auto newConst = builder.create<arith::ConstantIntOp>(op->getLoc(), result, 32);
                            op->getResult(0).replaceAllUsesWith(newConst.getResult());
                            
                            //erase op
                            op->erase();
                        }//

                        //update flag delete
                        deleted = true;
                    }
                    else
                    {
                        deleted = false;
                    }

                }//while

                //Return
                return;

            }); //getOperation()

            //Return
            return;
        }//void

    }; // CF pass
   
}//namespace

//Register
void registerMyPass()
{
    PassRegistration<MyPass>();
    PassRegistration<PrintOpsPass>();
    PassRegistration<FunctionStatsPass>();
    PassRegistration<LICMPass>();
    PassRegistration<DCEPass>();
    PassRegistration<CFPass>();
}