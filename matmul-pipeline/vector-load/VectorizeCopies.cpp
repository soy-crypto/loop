// Vector loads of the shared-memory tile copy.
//
// stage-matmul-tiles has every thread load one float. Consecutive threads
// read different rows, so those loads are not one memory transaction.
// A 16x16 tile is 256 floats, which is 64 loads of vector<4xf32>. The first
// 64 threads of the block do those loads: thread linear_id reads four
// consecutive elements of one row, and the next thread reads the next four.
// The other threads skip the copy. The barrier stays outside the if.
//
// The global memrefs come out of bufferization with a dynamic stride. A
// vector load is only legal when the last stride is 1, which is the row-major
// layout this pipeline allocates. The pass rebuilds that view first.

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Support/ErrorHandling.h"

#include <string>

using namespace mlir;

namespace {

constexpr int64_t kVectorWidth = 4;

bool isWorkgroup(Value value) {
  auto type = dyn_cast<MemRefType>(value.getType());
  if (!type)
    return false;
  auto space = dyn_cast_or_null<gpu::AddressSpaceAttr>(type.getMemorySpace());
  return space && space.getValue() == gpu::AddressSpace::Workgroup;
}

// Last stride becomes the constant 1. The leading stride is copied from the
// source, so a row is still `sizes[1]` elements apart.
FailureOr<Value> unitStrideView(IRRewriter &rewriter, Location loc, Value source) {
  auto type = dyn_cast<MemRefType>(source.getType());
  if (!type || type.getRank() != 2 || !type.hasStaticShape() || !type.getElementType().isF32())
    return failure();
  if (auto layout = dyn_cast<StridedLayoutAttr>(type.getLayout())) {
    if (layout.getStrides().back() == 1)
      return source;
  } else if (type.getLayout().isIdentity()) {
    return source;
  }

  auto meta = rewriter.create<memref::ExtractStridedMetadataOp>(loc, source);
  auto resultLayout = StridedLayoutAttr::get(type.getContext(), ShapedType::kDynamic,
                                              {ShapedType::kDynamic, 1});
  auto resultType = type.getMemorySpace()
                        ? MemRefType::get(type.getShape(), type.getElementType(), resultLayout,
                                          type.getMemorySpace())
                        : MemRefType::get(type.getShape(), type.getElementType(), resultLayout);
  SmallVector<OpFoldResult> sizes;
  for (int64_t dim : type.getShape())
    sizes.push_back(rewriter.getIndexAttr(dim));
  return rewriter
      .create<memref::ReinterpretCastOp>(
          loc, resultType, meta.getBaseBuffer(), meta.getOffset(), sizes,
          ArrayRef<OpFoldResult>{meta.getStrides()[0], rewriter.getIndexAttr(1)})
      .getResult();
}

struct VectorizeMatmulCopiesPass
    : PassWrapper<VectorizeMatmulCopiesPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(VectorizeMatmulCopiesPass)

  StringRef getArgument() const override { return "vectorize-matmul-copies"; }
  StringRef getDescription() const override {
    return "Load the matmul shared-memory tiles as vector<4xf32>";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, memref::MemRefDialect, scf::SCFDialect,
                    vector::VectorDialect, gpu::GPUDialect>();
  }

  void runOnOperation() override {
    SmallVector<scf::ForOp> loops;
    getOperation().walk([&](scf::ForOp loop) {
      if (matchTileCopy(loop))
        loops.push_back(loop);
    });
    if (loops.size() != 1) {
      getOperation().emitError("expected one shared-memory tile copy to vectorize");
      signalPassFailure();
      return;
    }
    IRRewriter rewriter(&getContext());
    if (failed(vectorize(rewriter, loops.front()))) {
      loops.front().emitError("could not vectorize the tile copy");
      signalPassFailure();
    }
  }

  static bool matchTileCopy(scf::ForOp loop) {
    gpu::BarrierOp barrier;
    SmallVector<memref::StoreOp> stores;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (isa<gpu::BarrierOp>(op)) {
        barrier = cast<gpu::BarrierOp>(op);
        break;
      }
      if (auto store = dyn_cast<memref::StoreOp>(op)) {
        if (isWorkgroup(store.getMemRef()) && store.getValue().getType().isF32())
          stores.push_back(store);
      }
    }
    if (!barrier || stores.size() != 2)
      return false;
    if (stores[0].getIndices().size() != 2 ||
        stores[0].getIndices().back() != stores[1].getIndices().back())
      return false;
    for (memref::StoreOp store : stores) {
      auto load = store.getValue().getDefiningOp<memref::LoadOp>();
      if (!load || load->getParentOp() != loop || isWorkgroup(load.getMemRef()))
        return false;
      auto type = dyn_cast<MemRefType>(load.getMemRef().getType());
      if (!type || type.getRank() != 2)
        return false;
    }
    return true;
  }

  // A is loaded as A[row, k + thread_y]. B is loaded as B[k + thread_x, col].
  static bool indexUsesIV(Value index, Value iv) {
    if (index == iv)
      return true;
    if (auto add = index.getDefiningOp<arith::AddIOp>())
      return add.getLhs() == iv || add.getRhs() == iv;
    return false;
  }

  static Value otherAddOperand(Value value, Value known) {
    auto add = value.getDefiningOp<arith::AddIOp>();
    if (!add)
      return {};
    if (add.getLhs() == known)
      return add.getRhs();
    if (add.getRhs() == known)
      return add.getLhs();
    return {};
  }

  static LogicalResult vectorize(IRRewriter &rewriter, scf::ForOp loop) {
    auto step = loop.getStep().getDefiningOp<arith::ConstantIndexOp>();
    if (!step || step.value() != 16)
      return failure();

    SmallVector<memref::StoreOp> stores;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (isa<gpu::BarrierOp>(op))
        break;
      if (auto store = dyn_cast<memref::StoreOp>(op)) {
        if (isWorkgroup(store.getMemRef()))
          stores.push_back(store);
      }
    }
    memref::LoadOp aLoad, bLoad;
    memref::StoreOp aStore, bStore;
    Value iv = loop.getInductionVar();
    for (memref::StoreOp store : stores) {
      auto load = store.getValue().getDefiningOp<memref::LoadOp>();
      if (indexUsesIV(load.getIndices()[1], iv)) {
        aLoad = load;
        aStore = store;
      } else if (indexUsesIV(load.getIndices()[0], iv)) {
        bLoad = load;
        bStore = store;
      }
    }
    if (!aLoad || !bLoad || aStore.getIndices().size() != 2 ||
        bStore.getIndices().size() != 2 ||
        aStore.getIndices()[0] != bStore.getIndices()[0] ||
        aStore.getIndices()[1] != bStore.getIndices()[1])
      return failure();

    Value threadX = aStore.getIndices()[0];
    Value threadY = aStore.getIndices()[1];
    Value blockRow = otherAddOperand(aLoad.getIndices()[0], threadX);
    Value blockCol = otherAddOperand(bLoad.getIndices()[1], threadY);
    if (!blockRow || !blockCol)
      return failure();

    rewriter.setInsertionPoint(loop);
    auto aView = unitStrideView(rewriter, aLoad.getLoc(), aLoad.getMemRef());
    auto bView = unitStrideView(rewriter, bLoad.getLoc(), bLoad.getMemRef());
    if (failed(aView) || failed(bView))
      return failure();

    rewriter.setInsertionPoint(stores.front());
    Location loc = stores.front().getLoc();
    auto vecType = VectorType::get({kVectorWidth}, rewriter.getF32Type());
    Value c4 = rewriter.create<arith::ConstantIndexOp>(loc, kVectorWidth);
    Value c16 = rewriter.create<arith::ConstantIndexOp>(loc, 16);
    Value c64 = rewriter.create<arith::ConstantIndexOp>(loc, (16 * 16) / kVectorWidth);
    Value linear = rewriter.create<arith::AddIOp>(
        loc, threadX, rewriter.create<arith::MulIOp>(loc, threadY, c16));
    Value pred = rewriter.create<arith::CmpIOp>(loc, arith::CmpIPredicate::ult, linear, c64);
    rewriter.create<scf::IfOp>(loc, pred, [&](OpBuilder &builder, Location ifLoc) {
      Value row = builder.create<arith::DivUIOp>(ifLoc, linear, c4);
      Value group = builder.create<arith::RemUIOp>(ifLoc, linear, c4);
      Value col = builder.create<arith::MulIOp>(ifLoc, group, c4);
      Value aRow = builder.create<arith::AddIOp>(ifLoc, blockRow, row);
      Value aCol = builder.create<arith::AddIOp>(ifLoc, iv, col);
      Value bRow = builder.create<arith::AddIOp>(ifLoc, iv, row);
      Value bCol = builder.create<arith::AddIOp>(ifLoc, blockCol, col);
      auto aVec = builder.create<vector::LoadOp>(ifLoc, vecType, *aView, ValueRange{aRow, aCol});
      builder.create<vector::StoreOp>(ifLoc, aVec, aStore.getMemRef(), ValueRange{row, col});
      auto bVec = builder.create<vector::LoadOp>(ifLoc, vecType, *bView, ValueRange{bRow, bCol});
      builder.create<vector::StoreOp>(ifLoc, bVec, bStore.getMemRef(), ValueRange{row, col});
      builder.create<scf::YieldOp>(ifLoc);
    });

    SmallVector<Operation *> dead;
    for (memref::StoreOp store : stores)
      dead.push_back(store);
    dead.push_back(aLoad);
    dead.push_back(bLoad);
    for (Operation *op : dead)
      rewriter.eraseOp(op);
    return success();
  }
};

// Same rewrite as the tiled pipeline's shared-alloca pass, with 16-byte
// alignment so a vector<4xf32> shared store is a legal st.shared.v4.f32.
struct SharedAllocaToGlobal16Pass
    : PassWrapper<SharedAllocaToGlobal16Pass, OperationPass<gpu::GPUModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(SharedAllocaToGlobal16Pass)

  StringRef getArgument() const override { return "shared-alloca-to-global-16"; }
  StringRef getDescription() const override {
    return "Turn shared-memory allocas into 16-byte-aligned internal globals";
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
          "shared_tile_" + std::to_string(index++), /*value=*/Attribute(), /*alignment=*/16,
          /*addrSpace=*/3);
      rewriter.setInsertionPoint(alloca);
      auto address = rewriter.create<LLVM::AddressOfOp>(alloca.getLoc(), global);
      auto element = rewriter.create<LLVM::GEPOp>(
          alloca.getLoc(), alloca.getType(), arrayType, address, ArrayRef<LLVM::GEPArg>{0, 0});
      rewriter.replaceOp(alloca, element.getResult());
    }

    module.walk([](LLVM::StoreOp store) {
      auto vec = dyn_cast<VectorType>(store.getValue().getType());
      auto pointer = dyn_cast<LLVM::LLVMPointerType>(store.getAddr().getType());
      if (vec && vec.getNumElements() == kVectorWidth && pointer && pointer.getAddressSpace() == 3)
        store.setAlignment(16);
    });
  }
};

constexpr const char *vectorMappingPipeline =
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
    "vectorize-matmul-copies,canonicalize,cse,"
    "toy-matmul-tiled-output";

constexpr const char *vectorLoweringPipeline =
    "gpu.module("
      "lower-affine,convert-scf-to-cf,"
      "convert-vector-to-llvm{use-vector-alignment=true},"
      "convert-gpu-to-nvvm,"
      "reconcile-unrealized-casts,canonicalize,cse,"
      "shared-alloca-to-global-16"
    "),"
    "nvvm-attach-target{chip=sm_86 features=+ptx80},"
    "gpu-module-to-binary{format=isa},"
    "func.func(llvm-request-c-wrappers),"
    "expand-strided-metadata,lower-affine,convert-scf-to-cf,"
    "convert-to-llvm,gpu-to-llvm,reconcile-unrealized-casts";

void appendVectorPipeline(OpPassManager &manager, StringRef pipeline) {
  if (failed(parsePassPipeline(pipeline, manager)))
    llvm::report_fatal_error("Could not build the vector-load matmul pipeline");
}

[[maybe_unused]] static bool vectorPipelineIsRegistered = [] {
  PassRegistration<VectorizeMatmulCopiesPass>();
  PassRegistration<SharedAllocaToGlobal16Pass>();

  PassPipelineRegistration<>(
      "toy-matmul-vector-outline-pipeline",
      "Map the 128x128 matmul and vectorize the shared-memory tile copy",
      [](OpPassManager &manager) { appendVectorPipeline(manager, vectorMappingPipeline); });

  PassPipelineRegistration<>(
      "toy-matmul-vector-gpu-pipeline",
      "Compile the vector-load 128x128 matmul for sm_86",
      [](OpPassManager &manager) {
        appendVectorPipeline(manager, vectorMappingPipeline);
        appendVectorPipeline(manager, vectorLoweringPipeline);
      });
  return true;
}();

} // namespace
