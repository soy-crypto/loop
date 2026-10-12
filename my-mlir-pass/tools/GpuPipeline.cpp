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

// This implements the one host-memory edit used by our successful GPU test.
// It is deliberately scoped to add_then_mul; callers must supply inputs in
// GPU-accessible memory and free the returned CUDA allocation themselves.
struct MakeGPUOutputSharedPass
    : PassWrapper<MakeGPUOutputSharedPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MakeGPUOutputSharedPass)

  StringRef getArgument() const override { return "toy-gpu-shared-output"; }
  StringRef getDescription() const override {
    return "Allocate add_then_mul output in CUDA managed memory";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<gpu::GPUDialect, memref::MemRefDialect>();
  }

  void runOnOperation() override {
    auto function = getOperation().lookupSymbol<func::FuncOp>("add_then_mul");
    if (!function) {
      getOperation().emitError("toy GPU pipeline requires @add_then_mul");
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
    if (outputs.size() != 1) {
      function.emitError("expected one output allocation passed to the GPU kernel");
      signalPassFailure();
      return;
    }

    memref::AllocOp allocation = outputs.front();
    MemRefType type = allocation.getType();
    if (type.getRank() != 2 || !type.hasStaticShape() ||
        type.getDimSize(0) != 8 || type.getDimSize(1) != 8 ||
        !type.getElementType().isF32() || !type.getLayout().isIdentity() ||
        type.getMemorySpace()) {
      allocation.emitError("this test pipeline expects memref<8x8xf32> output");
      signalPassFailure();
      return;
    }
    // Replacing the allocation must also preserve its deallocation API.
    // The current function returns ownership and has no local deallocation.
    for (Operation *user : allocation.getResult().getUsers()) {
      if (isa<memref::DeallocOp>(user)) {
        allocation.emitError("expected returned output ownership, without memref.dealloc");
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

// Nest function passes explicitly. In particular, do not canonicalize between
// parallel tiling and GPU mapping: it would merge the nested parallel loops.
constexpr const char *mappingPipeline =
    "toy-fusion,"
    "empty-tensor-to-alloc-tensor,"
    "one-shot-bufferize{bufferize-function-boundaries=true},"
    "canonicalize,cse,"
    "func.func("
      "convert-linalg-to-parallel-loops,canonicalize,cse,"
      "scf-parallel-loop-tiling{parallel-loop-tile-sizes=2,2},"
      "gpu-map-parallel-loops,"
      "convert-parallel-loops-to-gpu,canonicalize,cse"
    "),"
    "gpu-kernel-outlining,"
    "toy-gpu-shared-output";

constexpr const char *loweringPipeline =
    "gpu.module("
      "lower-affine,convert-scf-to-cf,convert-gpu-to-nvvm,"
      "reconcile-unrealized-casts,canonicalize,cse"
    "),"
    "nvvm-attach-target{chip=sm_86 features=+ptx80},"
    "gpu-module-to-binary{format=isa},"
    "func.func(llvm-request-c-wrappers),"
    "expand-strided-metadata,lower-affine,convert-scf-to-cf,"
    "convert-to-llvm,gpu-to-llvm,reconcile-unrealized-casts";

// Use the same built-in pass names already exercised with mlir-opt-21.
// A parsing failure here means the installed pass registration differs.
void appendPipeline(OpPassManager &manager, StringRef pipeline) {
  if (failed(parsePassPipeline(pipeline, manager)))
    llvm::report_fatal_error("Could not build the toy GPU pipeline; see diagnostic above");
}

} // namespace

void registerMyGPUPipelines() {
  PassRegistration<MakeGPUOutputSharedPass>();

  // An inspection endpoint for seeing the automatically generated GPU kernel.
  PassPipelineRegistration<>(
      "toy-gpu-outline-pipeline",
      "Fuse and map the 8x8 example to outlined GPU kernels",
      [](OpPassManager &manager) {
        appendPipeline(manager, mappingPipeline);
      });

  // The complete tested route, ending in LLVM-dialect host code + embedded PTX.
  PassPipelineRegistration<>(
      "toy-gpu-pipeline",
      "Compile the 8x8 example for sm_86 with a C host wrapper and embedded PTX",
      [](OpPassManager &manager) {
        appendPipeline(manager, mappingPipeline);
        appendPipeline(manager, loweringPipeline);
      });
}
