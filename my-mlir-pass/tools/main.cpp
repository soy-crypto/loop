#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/IR/DialectRegistry.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"

extern void registerMyPass();

int main(int argc, char **argv)
{
    registerMyPass();

    mlir::DialectRegistry registry;

    registry.insert<mlir::func::FuncDialect, mlir::arith::ArithDialect>();

    return mlir::asMainReturnCode(mlir::MlirOptMain(argc, argv, "my mlir tool\n", registry));
}