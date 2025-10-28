cmake_minimum_required(VERSION 2.8)

project(roblox C CXX ASM)

if(NOT UNIX)
  message(FATAL_ERROR "Unsupported platform.")
endif()

list(APPEND CMAKE_PREFIX_PATH "${CONTRIB_PATH}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")

if(NOT CONTRIB_PATH)
  file(TO_CMAKE_PATH "$ENV{CONTRIB_PATH}" CONTRIB_PATH)
endif()
if(NOT CONTRIB_PATH)
  message(FATAL_ERROR "CONTRIB_PATH is not set")
endif()
file(TO_CMAKE_PATH "${CONTRIB_PATH}" CONTRIB_PATH)
message(STATUS "CONTRIB_PATH=${CONTRIB_PATH}")

set(Boost_NO_SYSTEM_PATHS ON)
set(BOOST_ROOT ${CONTRIB_PATH}/boost_1_55_0)
set(Boost_INCLUDE_DIR ${BOOST_ROOT}/)
include_directories(${Boost_INCLUDE_DIR})
string(TOLOWER ${CMAKE_BUILD_TYPE} RBX_BUILD_TYPE)

add_definitions(-DROBLOX_BOOST_CONFIGS)

add_compile_options(
    -Wno-c++11-narrowing
    -Wno-reserved-user-defined-literal
    -Wno-missing-field-initializers
    -Wnonportable-include-path
)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(${CONTRIB_PATH}/android/armeabi-v7a/curl/curl-7.43.0/include)

if(ANDROID)
  message(STATUS "ANDROID_TOOLCHAIN_NAME=${ANDROID_TOOLCHAIN_NAME}")
  message(STATUS "ANDROID_STL=${ANDROID_STL}")
  message(STATUS "ANDROID_ABI=${ANDROID_ABI}")
  message(STATUS "ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}")
  message(STATUS "ANDROID_SYSROOT=${ANDROID_SYSROOT}")
  message(STATUS "ANDROID_EXCEPTIONS=${ANDROID_EXCEPTIONS}")
  message(STATUS "ANDROID_RTTI=${ANDROID_RTTI}")
  message(STATUS "ANDROID_NDK_HOST_X64=${ANDROID_NDK_HOST_X64}")
endif()
message(STATUS "CMAKE_SYSROOT=${CMAKE_SYSROOT}")
message(STATUS "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
if(NOT RBX_STL_INCLUDE_DIRS)
  set(RBX_STL_INCLUDE_DIRS
      "${CMAKE_SYSROOT}/usr/include/c++/v1")
endif()

message(STATUS "RBX_STL_INCLUDE_DIRS=")
set(_RBX_STL_INCLUDE_PATTERNS "")
foreach(dir ${RBX_STL_INCLUDE_DIRS})
  message(STATUS "    ${dir}")
  list(APPEND _RBX_STL_INCLUDE_PATTERNS "${dir}/*")
endforeach()


include(ListFilter)
include(IncludeProjectFiles)
include(Boost)
include(FMOD)
include(SSL)
include(SDL2)

if(NOT RBX_SETTINGS_INITIALIZED)
  if(UNIX)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden" CACHE STRING "" FORCE)
    set(CMAKE_ECLIPSE_MAKE_ARGUMENTS "-j -l4")
  endif()
  if(ANDROID)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfloat-abi=softfp -MMD -MP" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfloat-abi=softfp -MMD -MP" CACHE STRING "" FORCE)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -g" CACHE STRING "" FORCE)
  endif()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall" CACHE STRING "" FORCE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unknown-pragmas -Wno-unused-variable -Wno-unused-local-typedefs -Wno-main" CACHE STRING "" FORCE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-reorder -Wno-unused-local-typedefs" CACHE STRING "" FORCE)
  set(RBX_SETTINGS_INITIALIZED TRUE CACHE INTERNAL "" FORCE)
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(APPLE ON)
  if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm")
    set(APPLE_IOS ON)
  endif()
endif()

include_project_files(SystemHeaders "${CMAKE_SYSROOT}/usr/include/*.h;${RBX_STL_INCLUDE_DIRS}")

if(WIN32)
  add_subdirectory(DeviceCaps)
endif()

add_subdirectory(boostlibs)
add_subdirectory(ClientShared)
add_subdirectory(Base)
add_subdirectory(Log)
add_subdirectory(Rendering)
add_subdirectory(Network)
add_subdirectory(App)
add_subdirectory(Android)
add_subdirectory(App.BulletPhysics)

if(UNIX)
  if(ANDROID)
    include(Curl)
    include_project_files(curl "${CURL_ROOT}/include/*.h")
    set(DEPENDENCIES "${DEPENDENCIES} \"${CURL_ROOT}/lib/libcurl.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} \"${SSL_ROOT}/lib/libssl.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} \"${SSL_ROOT}/lib/libcrypto.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} \"/mnt/f/Trunk2012/Contribs/android/armeabi-v7a/RakNet/raknetlibstatic_android.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} \"/mnt/f/Trunk2012/Contribs/android/armeabi-v7a/png/libpng.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} \"/mnt/f/Trunk2012/Contribs/android/armeabi-v7a/png/libjpeg.a\"")
    set(DEPENDENCIES "${DEPENDENCIES} -landroid")
    set(DEPENDENCIES "${DEPENDENCIES} -lGLESv2")
    set(DEPENDENCIES "${DEPENDENCIES} -lEGL")
    set(DEPENDENCIES "${DEPENDENCIES} -llog")
  else()
    set(DEPENDENCIES "${DEPENDENCIES} -lGLESv2")
  endif()
  if(RBX_BUILD_TYPE MATCHES "release")
    set(DEPENDENCIES "${DEPENDENCIES} -lfmod")
  else()
    set(DEPENDENCIES "${DEPENDENCIES} -lfmodL")
  endif()
  set(DEPENDENCIES "${DEPENDENCIES} -lz")
endif()

add_library(roblox SHARED
  $<TARGET_OBJECTS:boost>
  $<TARGET_OBJECTS:Base>
  $<TARGET_OBJECTS:Log>
  $<TARGET_OBJECTS:App>
  $<TARGET_OBJECTS:Network>
  $<TARGET_OBJECTS:G3D>
  $<TARGET_OBJECTS:AppDraw>
  $<TARGET_OBJECTS:RbxG3D>
  $<TARGET_OBJECTS:GfxBase>
  $<TARGET_OBJECTS:GfxCore>
  $<TARGET_OBJECTS:GfxRender>
  $<TARGET_OBJECTS:Android>
  $<TARGET_OBJECTS:App.BulletPhysics>)
set_target_properties(roblox PROPERTIES LINKER_LANGUAGE CXX)

if(UNIX)
  set(RBX_LINKER_DEPENDENCY_FLAGS "-Wl,--no-whole-archive,--no-gc-sections")
endif()

string(STRIP "${DEPENDENCIES}" deps_strip_str)
target_link_libraries(roblox
  ${RBX_LINKER_DEPENDENCY_FLAGS} ${deps_strip_str})
