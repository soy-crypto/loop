cmake_minimum_required(VERSION 3.20)

project(MyMLIRPass LANGUAGES C CXX)

find_package(LLVM REQUIRED CONFIG)
find_package(MLIR REQUIRED CONFIG)

message(STATUS "Using LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using MLIR ${MLIR_PACKAGE_VERSION}")

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})

add_library(MyMLIRPass MODULE
  lib/MyPass.cpp
)


target_compile_features(MyMLIRPass PRIVATE cxx_std_17)

target_link_libraries(MyMLIRPass PRIVATE
  MLIRArithDialect
  MLIRIR
  MLIRPass
  MLIRRewrite
  MLIRSupport
)