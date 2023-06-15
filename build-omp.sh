#!/bin/bash

module load gcc/12.3.0 boost

set -e

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
LLVM_DIR=${PREFIX}/llvm-project
LLVM_VERSION=16.0.6
OMP_DIR=${LLVM_DIR}/openmp
PROJECT=omp
BUILD_DIR=${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}/

mkdir -p ${PREFIX}

if [ ! -d ${LLVM_DIR} ]; then
  git clone --depth=1 -b llvmorg-${LLVM_VERSION} git@github.com:llvm/llvm-project.git ${LLVM_DIR}
  #git clone --depth=1 -b hpxc git@github.com:light2802/llvm-project.git ${LLVM_DIR}
fi

cmake                                \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}   \
  -DCMAKE_VERBOSE_MAKEFILE=ON        \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_CXX_FLAGS="-std=c++17"     \
  -DCMAKE_CXX_COMPILER=g++           \
  -DCMAKE_C_COMPILER=gcc             \
  -DOPENMP_ENABLE_LIBOMPTARGET=OFF   \
  -DLIBOMP_OMPD_SUPPORT=OFF          \
  -DLIBOMP_USE_STDCPPLIB:BOOL=TRUE   \
  -DCMAKE_INSTALL_PREFIX=${OMP_DIR}/cmake-install-${PROJECT}/${BUILD_TYPE} \
  -Wdev -S ${OMP_DIR} -B ${BUILD_DIR}

cmake --build ${BUILD_DIR} --parallel
cmake --install ${BUILD_DIR}/ --prefix ${OMP_DIR}/cmake-install-${PROJECT}/${BUILD_TYPE}

