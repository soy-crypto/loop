// Original matmul pipeline. One thread computes one output and reloads A, B,
// and C from global memory on every step of K.
//
//   1. one-shot-bufferize turns the tensors into memrefs.
//   2. convert-linalg-to-parallel-loops makes loops over row, column, and K.
//   3. scf-parallel-loop-tiling{16,16} splits the row and column loops.
//   4. gpu-map-parallel-loops assigns blocks and threads.
//   5. convert-parallel-loops-to-gpu creates gpu.launch.
//   6. gpu-kernel-outlining moves the launch body into gpu.func @matmul_kernel.
//   7. toy-matmul-gpu-output checks the launch.
//   8. The lowering string compiles the gpu.module to PTX.
//
// The shared-tiles pipeline in ../shared-tiles adds hoist-matmul-acc and
// stage-matmul-tiles after step 6.

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/ErrorHandling.h"

using namespace mlir;

namespace {

struct MakeMatmulGPUOutputPass : PassWrapper<MakeMatmulGPUOutputPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MakeMatmulGPUOutputPass)

  StringRef getArgument() const override { return "toy-matmul-gpu-output"; }
  StringRef getDescription() const override {
    return "Check the 128x128 matmul kernel and share an allocated result";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<gpu::GPUDialect, memref::MemRefDialect>();
  }

  void runOnOperation() override {
    auto function = getOperation().lookupSymbol<func::FuncOp>("matmul");
    if (!function) {
      getOperation().emitError("matmul GPU pipeline requires @matmul");
      signalPassFailure();
      return;
    }

    SmallVector<gpu::LaunchFuncOp> launches;
    function.walk([&](gpu::LaunchFuncOp launch) { launches.push_back(launch); });
    if (launches.size() != 1) {
      function.emitError("expected one GPU launch in @matmul");
      signalPassFailure();
      return;
    }

    SmallVector<memref::AllocOp> outputs;
    function.walk([&](memref::AllocOp allocation) {
      for (Operation *user : allocation.getResult().getUsers()) {
        if (isa<gpu::LaunchFuncOp>(user)) {
          outputs.push_back(allocation);
          break;
        }
      }
    });
    if (outputs.empty())
      return;
    if (outputs.size() != 1) {
      function.emitError("expected at most one output allocation in @matmul");
      signalPassFailure();
      return;
    }

    memref::AllocOp allocation = outputs.front();
    MemRefType type = allocation.getType();
    if (type.getRank() != 2 || !type.hasStaticShape() ||
        type.getDimSize(0) != 128 || type.getDimSize(1) != 128 ||
        !type.getElementType().isF32() || !type.getLayout().isIdentity() ||
        type.getMemorySpace()) {
      allocation.emitError("this matmul pipeline expects memref<128x128xf32> output");
      signalPassFailure();
      return;
    }
    for (Operation *user : allocation.getResult().getUsers()) {
      if (isa<memref::DeallocOp>(user)) {
        allocation.emitError("expected returned matmul output, without memref.dealloc");
        signalPassFailure();
        return;
      }
    }

    IRRewriter rewriter(&getContext());
    rewriter.setInsertionPoint(allocation);
    auto shared = rewriter.create<gpu::AllocOp>(
        allocation.getLoc(), type, Type(), ValueRange{},
        allocation.getDynamicSizes(), allocation.getSymbolOperands(),
        /*hostShared=*/true);
    rewriter.replaceOp(allocation, shared.getMemref());
  }
};

constexpr const char *matmulMappingPipeline =
    "one-shot-bufferize{bufferize-function-boundaries=true},"
    "canonicalize,cse,"
    "func.func("
      "convert-linalg-to-parallel-loops,canonicalize,cse,"
      "scf-parallel-loop-tiling{parallel-loop-tile-sizes=16,16},"
      "gpu-map-parallel-loops,"
      "convert-parallel-loops-to-gpu,canonicalize,cse"
    "),"
    "gpu-kernel-outlining,"
    "toy-matmul-gpu-output";

constexpr const char *matmulLoweringPipeline =
    "gpu.module("
      "lower-affine,convert-scf-to-cf,convert-gpu-to-nvvm,"
      "reconcile-unrealized-casts,canonicalize,cse"
    "),"
    "nvvm-attach-target{chip=sm_86 features=+ptx80},"
    "gpu-module-to-binary{format=isa},"
    "func.func(llvm-request-c-wrappers),"
    "expand-strided-metadata,lower-affine,convert-scf-to-cf,"
    "convert-to-llvm,gpu-to-llvm,reconcile-unrealized-casts";

void appendMatmulPipeline(OpPassManager &manager, StringRef pipeline) {
  if (failed(parsePassPipeline(pipeline, manager)))
    llvm::report_fatal_error("Could not build the original matmul pipeline; see diagnostic above");
}

[[maybe_unused]] static bool matmulPipelineIsRegistered = [] {
  PassRegistration<MakeMatmulGPUOutputPass>();

  PassPipelineRegistration<>(
      "toy-matmul-outline-pipeline",
      "Map the 128x128 matmul to an outlined GPU kernel",
      [](OpPassManager &manager) { appendMatmulPipeline(manager, matmulMappingPipeline); });

  PassPipelineRegistration<>(
      "toy-matmul-gpu-pipeline",
      "Compile the 128x128 matmul for sm_86 with a C host wrapper and embedded PTX",
      [](OpPassManager &manager) {
        appendMatmulPipeline(manager, matmulMappingPipeline);
        appendMatmulPipeline(manager, matmulLoweringPipeline);
      });
  return true;
}();

} // namespace
