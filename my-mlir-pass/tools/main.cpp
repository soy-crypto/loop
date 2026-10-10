#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Linalg/Passes.h"

extern void registerMyPass();

int main(int argc, char **argv)
{
    //register
    registerMyPass();
    mlir::registerLinalgElementwiseOpFusionPass(); 

    //dialect registration
    mlir::DialectRegistry registry;
    registry.insert<mlir::func::FuncDialect, 
                    mlir::arith::ArithDialect, 
                    mlir::scf::SCFDialect, 
                    mlir::linalg::LinalgDialect>();

    //Return
    return mlir::asMainReturnCode(mlir::MlirOptMain(argc, argv, "my mlir tool\n", registry));
}