// Shared-tile matmul pipeline. Same lowering as ../original, plus two passes
// after gpu-kernel-outlining.
//
// Input: matmul.mlir, one linalg.matmul, 128x128 f32.
// Output: a GPU kernel with a 16x16 thread block. Each thread computes one
// output element and loops over K itself.
//
// Stages, in order:
//   1. one-shot-bufferize turns the tensors into memrefs. C is updated in place.
//   2. convert-linalg-to-parallel-loops makes a parallel loop over (row, col)
//      and a sequential loop over K inside it.
//   3. scf-parallel-loop-tiling{16,16} splits that parallel loop into an outer
//      tile loop and an inner 16x16 loop.
//   4. gpu-map-parallel-loops assigns the outer loop to blocks and the inner
//      loop to threads. Do not canonicalize between steps 3 and 4: that would
//      merge the two loops and the mapping would have nothing to split on.
//   5. convert-parallel-loops-to-gpu turns the mapped loops into gpu.launch.
//   6. gpu-kernel-outlining moves the launch body into a gpu.func.
//   7. hoist-matmul-acc keeps the sum in a register and stores C once.
//   8. stage-matmul-tiles loads 16x16 tiles of A and B into shared memory.
//   9. toy-matmul-tiled-output checks that @matmul has one launch. If bufferization
//      allocated a new result, it replaces that alloc with CUDA managed memory.
//  10. The lowering string compiles the gpu.module to PTX and the host to LLVM.

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/ErrorHandling.h"

#include <string>

using namespace mlir;

namespace {

struct MakeMatmulGPUOutputPass : PassWrapper<MakeMatmulGPUOutputPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(MakeMatmulGPUOutputPass)

  StringRef getArgument() const override { return "toy-matmul-tiled-output"; }
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

static bool isInduction(Value value, scf::ForOp loop) { return value == loop.getInductionVar(); }

static std::optional<int64_t> constantIndex(Value value) {
  if (auto constant = value.getDefiningOp<arith::ConstantIndexOp>())
    return constant.value();
  auto argument = dyn_cast<BlockArgument>(value);
  if (!argument)
    return std::nullopt;
  auto kernel = dyn_cast<gpu::GPUFuncOp>(argument.getOwner()->getParentOp());
  if (!kernel)
    return std::nullopt;
  std::optional<int64_t> found;
  kernel->getParentOfType<ModuleOp>()->walk([&](gpu::LaunchFuncOp launch) {
    if (launch.getKernelName() != kernel.getName() ||
        launch.getNumKernelOperands() <= argument.getArgNumber())
      return;
    if (auto constant = launch.getKernelOperand(argument.getArgNumber()).getDefiningOp<arith::ConstantIndexOp>())
      found = constant.value();
  });
  return found;
}

static bool indicesUseInduction(ValueRange indices, scf::ForOp loop) {
  return llvm::any_of(indices, [&](Value index) { return isInduction(index, loop); });
}

// The outlined kernel body is:
//   load A[row, k], load B[k, col], load C[row, col], mulf, addf, store C.
// C does not depend on k, so the sum can live in the loop's iter_arg.
struct HoistMatmulAccPass : PassWrapper<HoistMatmulAccPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(HoistMatmulAccPass)

  StringRef getArgument() const override { return "hoist-matmul-acc"; }
  StringRef getDescription() const override {
    return "Keep the matmul sum in a register and store C once";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, memref::MemRefDialect, scf::SCFDialect>();
  }

  void runOnOperation() override {
    SmallVector<scf::ForOp> loops;
    getOperation()->walk([&](scf::ForOp loop) {
      if (loop.getNumRegionIterArgs() == 0)
        loops.push_back(loop);
    });
    if (loops.size() != 1) {
      getOperation()->emitError("hoist-matmul-acc expected one K loop");
      signalPassFailure();
      return;
    }

    scf::ForOp loop = loops.front();
    memref::StoreOp store;
    arith::AddFOp add;
    arith::MulFOp mul;
    SmallVector<memref::LoadOp> loads;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (auto candidate = dyn_cast<memref::StoreOp>(op))
        store = candidate;
      else if (auto candidate = dyn_cast<arith::AddFOp>(op))
        add = candidate;
      else if (auto candidate = dyn_cast<arith::MulFOp>(op))
        mul = candidate;
      else if (auto candidate = dyn_cast<memref::LoadOp>(op))
        loads.push_back(candidate);
      else {
        op.emitError("hoist-matmul-acc did not expect this operation in the K loop");
        signalPassFailure();
        return;
      }
    }
    if (!store || !add || !mul || loads.size() != 3 || store.getValue() != add.getResult()) {
      loop.emitError("hoist-matmul-acc expected load, multiply, add, and store");
      signalPassFailure();
      return;
    }

    Value carried = add.getLhs() == mul.getResult() ? add.getRhs() : add.getLhs();
    if (add.getLhs() != mul.getResult() && add.getRhs() != mul.getResult()) {
      add.emitError("hoist-matmul-acc expected the add to use the product");
      signalPassFailure();
      return;
    }
    memref::LoadOp loadC;
    SmallVector<memref::LoadOp> factors;
    for (memref::LoadOp load : loads) {
      if (load.getResult() == carried)
        loadC = load;
      else
        factors.push_back(load);
    }
    if (!loadC || factors.size() != 2 || indicesUseInduction(loadC.getIndices(), loop) ||
        store.getMemRef() != loadC.getMemRef() || store.getIndices() != loadC.getIndices() ||
        !indicesUseInduction(factors[0].getIndices(), loop) ||
        !indicesUseInduction(factors[1].getIndices(), loop)) {
      loop.emitError("hoist-matmul-acc expected C to be invariant and A and B to use K");
      signalPassFailure();
      return;
    }

    IRRewriter rewriter(&getContext());
    rewriter.setInsertionPoint(loop);
    auto zero = rewriter.create<arith::ConstantOp>(loop.getLoc(), rewriter.getF32FloatAttr(0));
    auto hoisted = rewriter.create<scf::ForOp>(
        loop.getLoc(), loop.getLowerBound(), loop.getUpperBound(), loop.getStep(), ValueRange{zero},
        [&](OpBuilder &builder, Location loc, Value induction, ValueRange acc) {
          auto remap = [&](Value index) { return index == loop.getInductionVar() ? induction : index; };
          SmallVector<Value> leftIndices, rightIndices;
          for (Value index : factors[0].getIndices())
            leftIndices.push_back(remap(index));
          for (Value index : factors[1].getIndices())
            rightIndices.push_back(remap(index));
          auto left = builder.create<memref::LoadOp>(loc, factors[0].getMemRef(), leftIndices);
          auto right = builder.create<memref::LoadOp>(loc, factors[1].getMemRef(), rightIndices);
          auto product = builder.create<arith::MulFOp>(loc, left, right);
          auto sum = builder.create<arith::AddFOp>(loc, acc.front(), product);
          builder.create<scf::YieldOp>(loc, ValueRange{sum});
        });
    rewriter.setInsertionPointAfter(hoisted);
    rewriter.create<memref::StoreOp>(loop.getLoc(), hoisted.getResult(0), loadC.getMemRef(), loadC.getIndices());
    rewriter.eraseOp(loop);
  }
};

// After hoist-matmul-acc the K loop is a multiply-add into an iter_arg.
// Split K by 16 and reuse each tile from workgroup memory.
struct StageMatmulTilesPass : PassWrapper<StageMatmulTilesPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(StageMatmulTilesPass)

  StringRef getArgument() const override { return "stage-matmul-tiles"; }
  StringRef getDescription() const override {
    return "Stage 16x16 A and B tiles in shared memory";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, gpu::GPUDialect, memref::MemRefDialect, scf::SCFDialect>();
  }

  void runOnOperation() override {
    SmallVector<scf::ForOp> loops;
    getOperation()->walk([&](scf::ForOp loop) {
      if (loop.getNumRegionIterArgs() == 1)
        loops.push_back(loop);
    });
    if (loops.size() != 1) {
      getOperation()->emitError("stage-matmul-tiles expected one accumulator loop");
      signalPassFailure();
      return;
    }
    scf::ForOp loop = loops.front();
    auto lower = constantIndex(loop.getLowerBound());
    auto upper = constantIndex(loop.getUpperBound());
    auto step = constantIndex(loop.getStep());
    if (!lower || !upper || !step || *step != 1 || (*upper - *lower) % 16 != 0) {
      loop.emitError("stage-matmul-tiles expected a constant K loop divisible by 16");
      signalPassFailure();
      return;
    }

    memref::LoadOp loadA, loadB;
    arith::MulFOp mul;
    arith::AddFOp add;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (auto candidate = dyn_cast<memref::LoadOp>(op)) {
        if (!loadA)
          loadA = candidate;
        else if (!loadB)
          loadB = candidate;
        else {
          op.emitError("stage-matmul-tiles expected two loads");
          signalPassFailure();
          return;
        }
      } else if (auto candidate = dyn_cast<arith::MulFOp>(op))
        mul = candidate;
      else if (auto candidate = dyn_cast<arith::AddFOp>(op))
        add = candidate;
      else {
        op.emitError("stage-matmul-tiles did not expect this operation");
        signalPassFailure();
        return;
      }
    }
    if (!loadA || !loadB || !mul || !add || loadA.getIndices().size() != 2 || loadB.getIndices().size() != 2 ||
        !isInduction(loadA.getIndices()[1], loop) || !isInduction(loadB.getIndices()[0], loop)) {
      loop.emitError("stage-matmul-tiles expected A[row, k] * B[k, col]");
      signalPassFailure();
      return;
    }

    auto kernel = loop->getParentOfType<gpu::GPUFuncOp>();
    if (!kernel) {
      loop.emitError("stage-matmul-tiles expected the loop inside a gpu.func");
      signalPassFailure();
      return;
    }
    gpu::ThreadIdOp threadX, threadY;
    kernel.walk([&](gpu::ThreadIdOp id) {
      if (id.getDimension() == gpu::Dimension::x)
        threadX = id;
      else if (id.getDimension() == gpu::Dimension::y)
        threadY = id;
    });
    if (!threadX || !threadY) {
      kernel.emitError("stage-matmul-tiles expected gpu.thread_id x and y");
      signalPassFailure();
      return;
    }

    IRRewriter rewriter(&getContext());
    rewriter.setInsertionPoint(loop);
    auto loc = loop.getLoc();
    auto space = gpu::AddressSpaceAttr::get(rewriter.getContext(), gpu::AddressSpace::Workgroup);
    auto tileType = MemRefType::get({16, 16}, rewriter.getF32Type(), MemRefLayoutAttrInterface(), space);
    auto tileA = rewriter.create<memref::AllocaOp>(loc, tileType);
    auto tileB = rewriter.create<memref::AllocaOp>(loc, tileType);
    auto tileStep = rewriter.create<arith::ConstantIndexOp>(loc, 16);
    auto zero = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    auto one = rewriter.create<arith::ConstantIndexOp>(loc, 1);
    Value row = loadA.getIndices()[0];
    Value column = loadB.getIndices()[1];
    auto outer = rewriter.create<scf::ForOp>(
        loc, loop.getLowerBound(), loop.getUpperBound(), tileStep, loop.getInitArgs(),
        [&](OpBuilder &builder, Location loc, Value tileStart, ValueRange acc) {
          auto columnInTile = builder.create<arith::AddIOp>(loc, tileStart, threadY);
          auto rowInTile = builder.create<arith::AddIOp>(loc, tileStart, threadX);
          auto aElement = builder.create<memref::LoadOp>(loc, loadA.getMemRef(), ValueRange{row, columnInTile});
          auto bElement = builder.create<memref::LoadOp>(loc, loadB.getMemRef(), ValueRange{rowInTile, column});
          builder.create<memref::StoreOp>(loc, aElement, tileA, ValueRange{threadX, threadY});
          builder.create<memref::StoreOp>(loc, bElement, tileB, ValueRange{threadX, threadY});
          builder.create<gpu::BarrierOp>(loc);
          auto inner = builder.create<scf::ForOp>(
              loc, zero, tileStep, one, acc, [&](OpBuilder &innerBuilder, Location loc, Value k, ValueRange innerAcc) {
                auto a = innerBuilder.create<memref::LoadOp>(loc, tileA, ValueRange{threadX, k});
                auto b = innerBuilder.create<memref::LoadOp>(loc, tileB, ValueRange{k, threadY});
                auto product = innerBuilder.create<arith::MulFOp>(loc, a, b);
                auto sum = innerBuilder.create<arith::AddFOp>(loc, innerAcc.front(), product);
                innerBuilder.create<scf::YieldOp>(loc, ValueRange{sum});
              });
          builder.create<gpu::BarrierOp>(loc);
          builder.create<scf::YieldOp>(loc, inner.getResult(0));
        });
    rewriter.replaceOp(loop, outer.getResult(0));
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
    "hoist-matmul-acc,"
    "stage-matmul-tiles,"
    "toy-matmul-tiled-output";

// llvm.alloca in address space 3 is lowered by NVPTX to local memory, then the
// loads still use shared memory. A real .shared buffer is an internal global.
struct SharedAllocaToGlobalPass : PassWrapper<SharedAllocaToGlobalPass, OperationPass<gpu::GPUModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(SharedAllocaToGlobalPass)

  StringRef getArgument() const override { return "shared-alloca-to-global"; }
  StringRef getDescription() const override {
    return "Turn shared-memory allocas into internal globals";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<LLVM::LLVMDialect>();
  }

  void runOnOperation() override {
    auto module = getOperation();
    SmallVector<LLVM::AllocaOp> allocas;
    module.walk([&](LLVM::AllocaOp alloca) {
      auto pointer = dyn_cast<LLVM::LLVMPointerType>(alloca.getType());
      if (pointer && pointer.getAddressSpace() == 3)
        allocas.push_back(alloca);
    });

    IRRewriter rewriter(&getContext());
    int index = 0;
    for (LLVM::AllocaOp alloca : allocas) {
      auto size = alloca.getArraySize().getDefiningOp<LLVM::ConstantOp>();
      if (!size || !isa<IntegerAttr>(size.getValue())) {
        alloca.emitError("shared alloca size is not a constant");
        signalPassFailure();
        return;
      }
      auto count = cast<IntegerAttr>(size.getValue()).getInt();
      auto arrayType = LLVM::LLVMArrayType::get(alloca.getElemType(), count);
      rewriter.setInsertionPointToStart(module.getBody());
      auto global = rewriter.create<LLVM::GlobalOp>(
          alloca.getLoc(), arrayType, /*isConstant=*/false, LLVM::Linkage::Internal,
          "shared_tile_" + std::to_string(index++), /*value=*/Attribute(), /*alignment=*/4,
          /*addrSpace=*/3);
      rewriter.setInsertionPoint(alloca);
      auto address = rewriter.create<LLVM::AddressOfOp>(alloca.getLoc(), global);
      auto element = rewriter.create<LLVM::GEPOp>(alloca.getLoc(), alloca.getType(), arrayType, address,
                                                   ArrayRef<LLVM::GEPArg>{0, 0});
      rewriter.replaceOp(alloca, element.getResult());
    }
  }
};

constexpr const char *matmulLoweringPipeline =
    "gpu.module("
      "lower-affine,convert-scf-to-cf,convert-gpu-to-nvvm,"
      "reconcile-unrealized-casts,canonicalize,cse,"
      "shared-alloca-to-global"
    "),"
    "nvvm-attach-target{chip=sm_86 features=+ptx80},"
    "gpu-module-to-binary{format=isa},"
    "func.func(llvm-request-c-wrappers),"
    "expand-strided-metadata,lower-affine,convert-scf-to-cf,"
    "convert-to-llvm,gpu-to-llvm,reconcile-unrealized-casts";

void appendMatmulPipeline(OpPassManager &manager, StringRef pipeline) {
  if (failed(parsePassPipeline(pipeline, manager)))
    llvm::report_fatal_error("Could not build the matmul GPU pipeline; see diagnostic above");
}

// Register before main, so my-opt sees the pipeline without a call from main.cpp.
[[maybe_unused]] static bool matmulPipelineIsRegistered = [] {
  PassRegistration<MakeMatmulGPUOutputPass>();
  PassRegistration<HoistMatmulAccPass>();
  PassRegistration<StageMatmulTilesPass>();
  PassRegistration<SharedAllocaToGlobalPass>();

  PassPipelineRegistration<>(
      "toy-matmul-tiled-outline-pipeline",
      "Map the 128x128 matmul and stage A and B in shared memory",
      [](OpPassManager &manager) { appendMatmulPipeline(manager, matmulMappingPipeline); });

  PassPipelineRegistration<>(
      "toy-matmul-tiled-gpu-pipeline",
      "Compile the shared-memory 128x128 matmul for sm_86",
      [](OpPassManager &manager) {
        appendMatmulPipeline(manager, matmulMappingPipeline);
        appendMatmulPipeline(manager, matmulLoweringPipeline);
      });
  return true;
}();

} // namespace
