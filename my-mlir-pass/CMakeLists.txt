cmake_minimum_required(VERSION 3.20)
project(MyMLIRPass LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM REQUIRED CONFIG)
find_package(MLIR REQUIRED CONFIG)

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}" "${MLIR_CMAKE_DIR}")
include(AddLLVM)
include(AddMLIR)
include(TableGen)
include(HandleLLVMOptions)

message(STATUS "Using LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using MLIR ${MLIR_PACKAGE_VERSION}")
include_directories(${LLVM_INCLUDE_DIRS} ${MLIR_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})

# Preserve the existing custom fusion and tiling implementations.
add_mlir_library(
  MyMLIRPass
  lib/MyPass.cpp
  EXCLUDE_FROM_LIBMLIR
  LINK_LIBS PUBLIC
    MLIRIR MLIRPass MLIRRewrite MLIRTransforms
    MLIRArithDialect MLIRSCFDialect
    MLIRLinalgDialect MLIRLinalgTransforms MLIRTensorDialect
)
target_compile_features(MyMLIRPass PRIVATE cxx_std_17)

# MLIR 21's InitAll*.h inline functions reference these installed libraries.
get_property(my_dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(my_conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
get_property(my_extension_libs GLOBAL PROPERTY MLIR_EXTENSION_LIBS)


add_executable(my-opt tools/main.cpp tools/GpuPipeline.cpp)
target_link_libraries(my-opt PRIVATE
  MyMLIRPass
  ${my_dialect_libs}
  ${my_conversion_libs}
  ${my_extension_libs}
  MLIROptLib
  MLIRAffineAnalysis MLIRAnalysis MLIRCastInterfaces MLIRDialect
  MLIRParser MLIRPass MLIRTransforms MLIRTransformUtils MLIRSupport MLIRIR
  MLIRGPUPipelines
  MLIRNVVMTarget
  MLIRLLVMToLLVMIRTranslation 
  MLIRNVVMToLLVMIRTranslation
  LLVM
  MLIRGPUToLLVMIRTranslation
)
