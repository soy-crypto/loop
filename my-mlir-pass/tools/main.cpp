#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/IR/DialectRegistry.h"

int main(int argc, char **argv)
{
    mlir::DialectRegistry registry;

    return mlir::asMainReturnCode(mlir::MlirOptMain(argc, argv, "my mlir toot \n", registry));
}