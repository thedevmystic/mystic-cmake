# --------------------------------------------------------------------------------------------------
# Copyright 2026-present The Mystic Framework Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# --------------------------------------------------------------------------------------------------
# File: MysticCompileOptions.cmake
# Description: This CMake module is used to set up compile options for a CMake target.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticCompileOptions)
# # Then call the function to set compile options for your target:
# mystic_compile_options(<TARGET_NAME>)
# --------------------------------------------------------------------------------------------------

include(CheckIPOSupported)
include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# This function sets build type-specific compile options.
function(_mystic_add_build_options TARGET_NAME)
  if(MSVC)
    target_compile_options(${TARGET_NAME} PRIVATE
      "/utf-8;/Zc:__cplusplus;/Zc:preprocessor;" # Ensure proper C++ standard compliance and UTF-8 encoding
      "$<$<CONFIG:Debug>:/Od;/Zi;/FS;/D_DEBUG>"
      "$<$<CONFIG:Release>:/O2;/Ob2;/Gy;/Gw;/Zc:inline;/DNDEBUG>"
      "$<$<CONFIG:MinSizeRel>:/O1;/Ob1;/Gy;/Gw;/Zc:inline;/DNDEBUG>"
      "$<$<CONFIG:RelWithDebInfo>:/O2;/Ob1;/Zi;/FS;/Oy-;/Gy;/Gw;/Zc:inline;/DNDEBUG>"
    )

    target_link_options(${TARGET_NAME} PRIVATE
      "$<$<CONFIG:Debug>:/DEBUG>"
      "$<$<CONFIG:Release>:/OPT:REF;/OPT:ICF;/INCREMENTAL:NO>"
      "$<$<CONFIG:MinSizeRel>:/OPT:REF;/OPT:ICF;/INCREMENTAL:NO>"
      "$<$<CONFIG:RelWithDebInfo>:/DEBUG;/OPT:REF;/OPT:ICF;/INCREMENTAL:NO>"
    )
  else()
    target_compile_options(${TARGET_NAME} PRIVATE
      "$<$<CONFIG:Debug>:-O0;-g3;-D_DEBUG;-fno-omit-frame-pointer>"
      "$<$<CONFIG:Release>:-O3;-DNDEBUG;-ffunction-sections;-fdata-sections>"
      "$<$<CONFIG:MinSizeRel>:-Os;-DNDEBUG;-ffunction-sections;-fdata-sections>"
      "$<$<CONFIG:RelWithDebInfo>:-O2;-g;-DNDEBUG;-fno-omit-frame-pointer;-ffunction-sections;-fdata-sections>"
    )

    # Dead-code stripping on every optimized config (Apple uses a different linker flag)
    if(APPLE)
      target_link_options(${TARGET_NAME} PRIVATE
        "$<$<CONFIG:Release,MinSizeRel,RelWithDebInfo>:-Wl,-dead_strip>"
      )
    else()
      target_link_options(${TARGET_NAME} PRIVATE
        "$<$<CONFIG:Release,MinSizeRel,RelWithDebInfo>:-Wl,--gc-sections>"
      )
    endif()
  endif()
endfunction()

# This function enables LTO (Link Time Optimization) for a given target.
function(_mystic_enable_lto TARGET_NAME)
  check_ipo_supported(RESULT ipo_supported OUTPUT error_message)
  if(ipo_supported)
    # Enable LTO for all configurations other than Debug
    set_target_properties(${TARGET_NAME} PROPERTIES
      INTERPROCEDURAL_OPTIMIZATION "$<$<NOT:$<CONFIG:Debug>>:TRUE>"
    )
  else()
    mystic_message(WARNING "LTO is not supported by the current compiler. Error: ${error_message}")
  endif()
endfunction()

# This function enables native architecture optimizations for a given target.
function(_mystic_enable_native_arch TARGET_NAME)
  if(MSVC)
    # MSVC does not have a direct equivalent for -march=native.
  else()
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" PROCESSOR)
    if("${PROCESSOR}" MATCHES "^(x86_64|amd64)$")
      target_compile_options(${TARGET_NAME} PRIVATE -march=native)
    elseif("${PROCESSOR}" MATCHES "^(arm64|aarch64)$")
      target_compile_options(${TARGET_NAME} PRIVATE -mcpu=native)
    endif()
  endif()
endfunction()

# This function enables extended warnings for a given target.
function(_mystic_enable_warning TARGET_NAME)
  # MSVC and clang-cl (Clang with the MSVC command-line frontend) share flags
  if(MSVC)
    set(_mystic_warning_flags
      /W4
      /permissive-
      /w14242 # possible loss of data in conversion
      /w14254 # larger bit field type conversion
      /w14263 # member function does not override any base class virtual
      /w14265 # class has virtual functions but destructor is not virtual
      /w14287 # unsigned/negative constant mismatch
      /w14296 # expression is always true/false
      /w14311 # pointer truncation
      /w14545 # comma expression before function call has no effect
      /w14546 # function call before comma missing argument list
      /w14547 # operator before comma has no effect
      /w14549 # operator before comma has no effect
      /w14555 # expression has no effect
      /w14619 # pragma warning: unknown warning number
      /w14640 # thread-unsafe static member initialization
      /w14826 # sign-extended conversion
      /w14905 # wide string literal cast to LPSTR
      /w14906 # string literal cast to LPWSTR
      /w14928 # illegal copy-initialization, multiple user-defined conversions
    )

  else()
    set(_mystic_warning_flags
      -Wall
      -Wextra
      -Wpedantic
      -Wconversion
      -Wsign-conversion
      -Wold-style-cast
      -Wcast-align
      -Wcast-qual
      -Wdouble-promotion
      -Wnon-virtual-dtor
      -Woverloaded-virtual
      -Wshadow
      -Wnull-dereference
      -Wformat=2
      -Wimplicit-fallthrough
      -Wmisleading-indentation
      -Wunused
    )

    # GCC-only diagnostics (Clang rejects or ignores these)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      list(APPEND _mystic_warning_flags
        -Wduplicated-cond
        -Wduplicated-branches
        -Wlogical-op
        -Wuseless-cast
      )
    endif()
  endif()

  # C++ only: several of these flags are invalid or noisy for C sources
  target_compile_options(${TARGET_NAME} PRIVATE
    "$<$<COMPILE_LANGUAGE:CXX>:${_mystic_warning_flags}>"
  )
endfunction()

# This function enables PIC (Position Independent Code) for a given target.
function(_mystic_enable_pic TARGET_NAME)
  set_target_properties(${TARGET_NAME} PROPERTIES POSITION_INDEPENDENT_CODE ON)
endfunction()

# QoL: Add colors to the output messages for better visibility
function(_mystic_enable_diagnostic_colors TARGET_NAME)
  if(MSVC)
    target_compile_options(${TARGET_NAME} PRIVATE /diagnostics:color)
  elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    target_compile_options(${TARGET_NAME} PRIVATE -fdiagnostics-color=always)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "^(Clang|AppleClang)$")
    target_compile_options(${TARGET_NAME} PRIVATE -fcolor-diagnostics)
  endif()
endfunction()


function(_mystic_compile_options_impl TARGET_NAME)
  if(NOT TARGET ${TARGET_NAME})
    mystic_message(FATAL_ERROR "Target '${TARGET_NAME}' is not a valid CMake target.")
  endif()

  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_compile_options'.")
  endif()

  # Set up standard
  set_target_properties(${TARGET_NAME} PROPERTIES
    CXX_STANDARD ${${PROJECT_PREFIX}_CXX_STANDARD}
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
  )

  # Set up build type-specific compile options
  _mystic_add_build_options(${TARGET_NAME})

  # Enable LTO if requested
  if(${PROJECT_PREFIX}_ENABLE_LTO)
    _mystic_enable_lto(${TARGET_NAME})
  endif()

  # Enable native architecture optimizations if requested
  if(${PROJECT_PREFIX}_ENABLE_NARCH)
    _mystic_enable_native_arch(${TARGET_NAME})
  endif()

  # Enable extended warnings if requested
  if(${PROJECT_PREFIX}_ENABLE_WARNINGS)
    _mystic_enable_warning(${TARGET_NAME})
  endif()

  # Enable PIC always
  _mystic_enable_pic(${TARGET_NAME})

  # Enable diagnostic colors for better visibility
  _mystic_enable_diagnostic_colors(${TARGET_NAME})
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_compile_options
# Description: This function sets up compile options for a given CMake target.
# Args:
#   ...: List of CMake target names to set compile options for.
# --------------------------------------------------------------------------------------------------
function(mystic_compile_options)
  if(NOT ARGN)
    mystic_message(FATAL_ERROR "No target names provided to 'mystic_compile_options'.")
  endif()

  foreach(TARGET_NAME IN LISTS ARGN)
    _mystic_compile_options_impl(${TARGET_NAME})
  endforeach()
endfunction()
