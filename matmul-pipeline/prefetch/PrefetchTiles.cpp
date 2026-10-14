// Prefetch the next K tile into a second shared-memory buffer.
//
// After vectorize-matmul-copies the outer loop is: copy tile t, barrier,
// compute tile t, barrier. This pass allocates two 16x16 planes, copies tile
// 0 first, then issues the loads for tile t+16, computes tile t, and only then
// stores the prefetched vectors. The global load can sit in flight during the
// inner FMA loop.

#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Pass/PassRegistry.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/Support/ErrorHandling.h"

using namespace mlir;

namespace {

bool isWorkgroup2D(Value value) {
  auto type = dyn_cast<MemRefType>(value.getType());
  if (!type || type.getRank() != 2 || !type.hasStaticShape())
    return false;
  if (type.getDimSize(0) != 16 || type.getDimSize(1) != 16)
    return false;
  auto space = dyn_cast_or_null<gpu::AddressSpaceAttr>(type.getMemorySpace());
  return space && space.getValue() == gpu::AddressSpace::Workgroup;
}

Value newBuffer(IRRewriter &rewriter, Location loc, Type elementType) {
  auto space = gpu::AddressSpaceAttr::get(rewriter.getContext(), gpu::AddressSpace::Workgroup);
  auto type = MemRefType::get({2, 16, 16}, elementType, MemRefLayoutAttrInterface{}, space);
  return rewriter.create<memref::AllocaOp>(loc, type);
}

bool dependsOn(Value value, Value iv, Block *copyBody) {
  if (value == iv)
    return true;
  Operation *def = value.getDefiningOp();
  if (!def || def->getBlock() != copyBody)
    return false;
  return llvm::any_of(def->getOperands(), [&](Value operand) { return dependsOn(operand, iv, copyBody); });
}

void emitCopy(OpBuilder &builder, Location loc, Value k, Value plane, Value pred, scf::IfOp origIf,
              Value iv, Value oldAs, Value oldBs, Value newAs, Value newBs, const IRMapping &preludeMap) {
  builder.create<scf::IfOp>(loc, pred, [&](OpBuilder &b, Location ifLoc) {
    IRMapping mapping = preludeMap;
    mapping.map(iv, k);
    for (Operation &op : origIf.thenBlock()->without_terminator()) {
      if (auto store = dyn_cast<vector::StoreOp>(&op)) {
        SmallVector<Value> indices;
        indices.push_back(plane);
        for (Value index : store.getIndices())
          indices.push_back(mapping.lookupOrDefault(index));
        Value dst = store.getBase() == oldAs ? newAs : newBs;
        b.create<vector::StoreOp>(ifLoc, mapping.lookupOrDefault(store.getValueToStore()), dst, indices);
      } else {
        b.clone(op, mapping);
      }
    }
    b.create<scf::YieldOp>(ifLoc);
  });
}

scf::IfOp emitPrefetchLoads(OpBuilder &builder, Location loc, Value k, Value pred, scf::IfOp origIf,
                            Value iv, const IRMapping &invMap, VectorType vecTy) {
  auto loadIf = builder.create<scf::IfOp>(loc, TypeRange{vecTy, vecTy}, pred, /*withElseRegion=*/true);
  {
    OpBuilder::InsertionGuard guard(builder);
    builder.setInsertionPointToStart(&loadIf.getThenRegion().front());
    IRMapping mapping = invMap;
    mapping.map(iv, k);
    SmallVector<Value> loaded;
    for (Operation &op : origIf.thenBlock()->without_terminator()) {
      if (isa<vector::StoreOp>(op))
        continue;
      if (auto load = dyn_cast<vector::LoadOp>(op)) {
        SmallVector<Value> indices;
        for (Value index : load.getIndices())
          indices.push_back(mapping.lookupOrDefault(index));
        auto newLoad =
            builder.create<vector::LoadOp>(loc, load.getType(), mapping.lookupOrDefault(load.getBase()), indices);
        mapping.map(load.getResult(), newLoad.getResult());
        loaded.push_back(newLoad);
      } else if (dependsOn(op.getResult(0), iv, origIf.thenBlock())) {
        builder.clone(op, mapping);
      }
    }
    builder.create<scf::YieldOp>(loc, ValueRange{loaded[0], loaded[1]});
    builder.setInsertionPointToStart(&loadIf.getElseRegion().front());
    auto zero = builder.create<arith::ConstantOp>(loc, DenseElementsAttr::get(vecTy, builder.getF32FloatAttr(0.0f)));
    builder.create<scf::YieldOp>(loc, ValueRange{zero, zero});
  }
  return loadIf;
}

void emitPrefetchStores(OpBuilder &builder, Location loc, Value pred, Value va, Value vb, Value plane,
                        Value row, Value col, Value newAs, Value newBs) {
  builder.create<scf::IfOp>(loc, pred, [&](OpBuilder &b, Location ifLoc) {
    b.create<vector::StoreOp>(ifLoc, va, newAs, ValueRange{plane, row, col});
    b.create<vector::StoreOp>(ifLoc, vb, newBs, ValueRange{plane, row, col});
    b.create<scf::YieldOp>(ifLoc);
  });
}

struct PrefetchMatmulTilesPass : PassWrapper<PrefetchMatmulTilesPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(PrefetchMatmulTilesPass)

  StringRef getArgument() const override { return "prefetch-matmul-tiles"; }
  StringRef getDescription() const override {
    return "Double-buffer the matmul shared-memory tiles and prefetch the next K tile";
  }
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<arith::ArithDialect, memref::MemRefDialect, scf::SCFDialect,
                    vector::VectorDialect, gpu::GPUDialect>();
  }

  void runOnOperation() override {
    SmallVector<scf::ForOp> loops;
    getOperation().walk([&](scf::ForOp loop) {
      if (match(loop))
        loops.push_back(loop);
    });
    if (loops.size() != 1) {
      getOperation().emitError("expected one vectorized tile loop to prefetch");
      signalPassFailure();
      return;
    }
    IRRewriter rewriter(&getContext());
    if (failed(prefetch(rewriter, loops.front()))) {
      loops.front().emitError("could not prefetch the next shared-memory tile");
      signalPassFailure();
    }
  }

  static bool match(scf::ForOp loop) {
    scf::IfOp copyIf;
    gpu::BarrierOp firstBarrier;
    scf::ForOp inner;
    gpu::BarrierOp secondBarrier;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (!copyIf) {
        copyIf = dyn_cast<scf::IfOp>(op);
        continue;
      }
      if (!firstBarrier) {
        firstBarrier = dyn_cast<gpu::BarrierOp>(op);
        continue;
      }
      if (!inner) {
        inner = dyn_cast<scf::ForOp>(op);
        continue;
      }
      if (!secondBarrier)
        secondBarrier = dyn_cast<gpu::BarrierOp>(op);
    }
    if (!copyIf || !firstBarrier || !inner || !secondBarrier || copyIf.getNumResults() != 0)
      return false;
    int stores = 0;
    for (Operation &op : copyIf.thenBlock()->without_terminator()) {
      if (auto store = dyn_cast<vector::StoreOp>(op)) {
        if (!isWorkgroup2D(store.getBase()) || store.getIndices().size() != 2)
          return false;
        ++stores;
      }
    }
    return stores == 2;
  }

  static LogicalResult prefetch(IRRewriter &rewriter, scf::ForOp loop) {
    scf::IfOp copyIf;
    scf::ForOp inner;
    SmallVector<Operation *> prelude;
    for (Operation &op : loop.getBody()->without_terminator()) {
      if (!copyIf) {
        if (auto candidate = dyn_cast<scf::IfOp>(op))
          copyIf = candidate;
        else
          prelude.push_back(&op);
        continue;
      }
      if (!inner)
        inner = dyn_cast<scf::ForOp>(op);
    }
    if (!copyIf || !inner)
      return failure();

    Value oldAs, oldBs;
    for (Operation &op : copyIf.thenBlock()->without_terminator()) {
      if (auto store = dyn_cast<vector::StoreOp>(op)) {
        if (!oldAs)
          oldAs = store.getBase();
        else if (store.getBase() != oldAs)
          oldBs = store.getBase();
      }
    }
    if (!oldAs || !oldBs)
      return failure();

    rewriter.setInsertionPoint(loop);
    Location loc = loop.getLoc();
    Value newAs = newBuffer(rewriter, loc, cast<MemRefType>(oldAs.getType()).getElementType());
    Value newBs = newBuffer(rewriter, loc, cast<MemRefType>(oldBs.getType()).getElementType());
    Value plane0 = rewriter.create<arith::ConstantIndexOp>(loc, 0);
    Value plane1 = rewriter.create<arith::ConstantIndexOp>(loc, 1);

    IRMapping invMap;
    for (Operation *op : prelude)
      rewriter.clone(*op, invMap);
    Value pred = invMap.lookupOrDefault(copyIf.getCondition());
    Value iv = loop.getInductionVar();
    Block *copyBody = copyIf.thenBlock();
    for (Operation &op : copyBody->without_terminator()) {
      if (isa<vector::LoadOp, vector::StoreOp>(op))
        continue;
      if (!llvm::any_of(op.getOperands(), [&](Value operand) { return dependsOn(operand, iv, copyBody); }))
        rewriter.clone(op, invMap);
    }

    Value row, col;
    for (Operation &op : copyBody->without_terminator()) {
      if (auto store = dyn_cast<vector::StoreOp>(op)) {
        row = invMap.lookupOrDefault(store.getIndices()[0]);
        col = invMap.lookupOrDefault(store.getIndices()[1]);
        break;
      }
    }
    if (!row || !col)
      return failure();
    auto vecTy = VectorType::get({4}, rewriter.getF32Type());

    emitCopy(rewriter, loc, loop.getLowerBound(), plane0, pred, copyIf, iv, oldAs, oldBs, newAs, newBs,
             invMap);
    rewriter.create<gpu::BarrierOp>(loc);

    SmallVector<Value> initArgs = {loop.getInitArgs().front(), plane0};
    auto outer = rewriter.create<scf::ForOp>(
        loc, loop.getLowerBound(), loop.getUpperBound(), loop.getStep(), initArgs,
        [&](OpBuilder &builder, Location bodyLoc, Value loopIv, ValueRange iterArgs) {
          Value acc = iterArgs[0];
          Value plane = iterArgs[1];
          Value nextK = builder.create<arith::AddIOp>(bodyLoc, loopIv, loop.getStep());
          Value hasNext =
              builder.create<arith::CmpIOp>(bodyLoc, arith::CmpIPredicate::ult, nextK, loop.getUpperBound());
          Value nextPlane = builder.create<arith::SubIOp>(bodyLoc, plane1, plane);
          Value predNext = builder.create<arith::AndIOp>(bodyLoc, hasNext, pred);
          auto loaded = emitPrefetchLoads(builder, bodyLoc, nextK, predNext, copyIf, iv, invMap, vecTy);

          auto newInner = builder.create<scf::ForOp>(
              bodyLoc, inner.getLowerBound(), inner.getUpperBound(), inner.getStep(), ValueRange{acc},
              [&](OpBuilder &innerBuilder, Location innerLoc, Value innerIv, ValueRange innerArgs) {
                IRMapping mapping;
                mapping.map(inner.getInductionVar(), innerIv);
                mapping.map(inner.getRegionIterArgs().front(), innerArgs.front());
                for (Operation &op : inner.getBody()->without_terminator()) {
                  if (auto load = dyn_cast<memref::LoadOp>(op)) {
                    SmallVector<Value> indices;
                    indices.push_back(plane);
                    for (Value index : load.getIndices())
                      indices.push_back(mapping.lookupOrDefault(index));
                    Value src = load.getMemRef() == oldAs ? newAs : newBs;
                    auto newLoad = innerBuilder.create<memref::LoadOp>(innerLoc, src, indices);
                    mapping.map(load.getResult(), newLoad.getResult());
                  } else {
                    innerBuilder.clone(op, mapping);
                  }
                }
                innerBuilder.create<scf::YieldOp>(
                    innerLoc, ValueRange{mapping.lookupOrDefault(inner.getBody()->getTerminator()->getOperand(0))});
              });
          emitPrefetchStores(builder, bodyLoc, predNext, loaded.getResult(0), loaded.getResult(1), nextPlane,
                             row, col, newAs, newBs);
          builder.create<gpu::BarrierOp>(bodyLoc);
          builder.create<scf::YieldOp>(bodyLoc, ValueRange{newInner.getResult(0), nextPlane});
        });

    rewriter.replaceOp(loop, outer.getResult(0));
    if (oldAs.use_empty())
      rewriter.eraseOp(oldAs.getDefiningOp());
    if (oldBs.use_empty())
      rewriter.eraseOp(oldBs.getDefiningOp());
    return success();
  }
};

constexpr const char *prefetchMappingPipeline =
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
    "prefetch-matmul-tiles,canonicalize,cse,"
    "toy-matmul-tiled-output";

constexpr const char *prefetchLoweringPipeline =
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

void appendPrefetchPipeline(OpPassManager &manager, StringRef pipeline) {
  if (failed(parsePassPipeline(pipeline, manager)))
    llvm::report_fatal_error("Could not build the prefetch matmul pipeline");
}

[[maybe_unused]] static bool prefetchPipelineIsRegistered = [] {
  PassRegistration<PrefetchMatmulTilesPass>();

  PassPipelineRegistration<>(
      "toy-matmul-prefetch-outline-pipeline",
      "Map the 128x128 matmul, vectorize copies, and prefetch the next K tile",
      [](OpPassManager &manager) { appendPrefetchPipeline(manager, prefetchMappingPipeline); });

  PassPipelineRegistration<>(
      "toy-matmul-prefetch-gpu-pipeline",
      "Compile the prefetch 128x128 matmul for sm_86",
      [](OpPassManager &manager) {
        appendPrefetchPipeline(manager, prefetchMappingPipeline);
        appendPrefetchPipeline(manager, prefetchLoweringPipeline);
      });
  return true;
}();

} // namespace
