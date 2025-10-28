#!/bin/bash
set -e

# === CONFIG ===
ANDROID_API=21   # Minimum API for arm64-v8a
CLIENT_DIR="$(dirname "${BASH_SOURCE[0]}")/.."
BUILD_DIR="$CLIENT_DIR/../build"

# Use Ninja instead of Eclipse/Makefiles
GENERATOR="Ninja"

# Define build directories & modes
declare -a BUILD_DIRECTORIES=(
  "${BUILD_DIR}/release"
  "${BUILD_DIR}/noopt"
  "${BUILD_DIR}/debug"
)

declare -a BUILD_MODES=("Release" "RelWithDebInfo" "Debug")

# Common CMake arguments (modern NDK toolchain)
COMMON_CMAKE_ARGS="-DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DANDROID_ABI=arm64-v8a"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DANDROID_PLATFORM=android-${ANDROID_API}"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DANDROID_STL=c++_static"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DCONTRIB_PATH='${CONTRIB_PATH}'"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DBOOST_ROOT='${CONTRIB_PATH}/boost_1_55_0/'"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DRBX_PLATFORM_ANDROID=ON"
COMMON_CMAKE_ARGS="$COMMON_CMAKE_ARGS -DCMAKE_CXX_FLAGS='-DRBX_PLATFORM_ANDROID'"

# === BUILD LOOP ===
for ((i = 0; i < ${#BUILD_DIRECTORIES[@]}; i++)); do
    build_dir=${BUILD_DIRECTORIES[$i]}
    build_mode=${BUILD_MODES[$i]}

    if [[ ! -d $build_dir ]]; then
        echo "Creating build dir: $build_dir"
        mkdir -p "$build_dir"
    fi

    pushd "$build_dir" >/dev/null

    echo "== Configuring $build_mode in $(pwd) =="
    cmake $COMMON_CMAKE_ARGS \
          -DCMAKE_BUILD_TYPE=$build_mode \
          -G "$GENERATOR" \
          ../../Client "$@"


    echo
done
