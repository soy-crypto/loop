cmake_minimum_required(VERSION 3.20)

project(MyMLIRPass LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(LLVM REQUIRED CONFIG)
find_package(MLIR REQUIRED CONFIG)

list(APPEND CMAKE_MODULE_PATH
  "${LLVM_CMAKE_DIR}"
  "${MLIR_CMAKE_DIR}"
)

include(AddLLVM)
include(AddMLIR)
include(TableGen)
include(HandleLLVMOptions)

message(STATUS "Using LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using MLIR ${MLIR_PACKAGE_VERSION}")

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})

add_mlir_library(MyMLIRPass
  lib/MyPass.cpp

  EXCLUDE_FROM_LIBMLIR

  LINK_LIBS PUBLIC
    MLIRIR
    MLIRPass
    MLIRRewrite
    MLIRTransforms
    MLIRArithDialect
)

target_compile_features(MyMLIRPass PRIVATE cxx_std_17)

add_executable(my-opt tools/main.cpp)
target_link_libraries(my-opt PRIVATE MyMLIRPass MLIROptLib MLIRFuncDialect)