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
# File: mystic_setup_options.cmake
# Description: This CMake module is used to setup the options for a project.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_setup_options)
# # Then call the mystic_project function:
# mystic_setup_options()
# --------------------------------------------------------------------------------------------------
# Note: It automatically prefixes the options with the project name. So, to use it you first
# have to setup the project using mystic_project() function.
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/helpers.cmake")

# --------------------------------------------------------------------------------------------------
# Function: mystic_setup_options
# Description: This function sets up the general-purpose options for a project.
# --------------------------------------------------------------------------------------------------
function(mystic_setup_options)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Build Type
  # Valid options: Debug, Release, MinSizeRel, RelWithDebInfo.
  set(${PROJECT_PREFIX}_BUILD_TYPE "Release" CACHE STRING "Build type.")
  set_property(CACHE ${PROJECT_PREFIX}_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "${${PROJECT_PREFIX}_BUILD_TYPE}" CACHE STRING "Build type." FORCE)
  endif()

  # Static/Shared Library
  option(${PROJECT_PREFIX}_BUILD_SHARED_LIBS "Build shared libraries (static, if OFF.)" ON)

  # Map correct lib type
  if(${PROJECT_PREFIX}_BUILD_SHARED_LIBS)
    set(${PROJECT_PREFIX}_LIB_TYPE SHARED PARENT_SCOPE)
  else()
    set(${PROJECT_PREFIX}_LIB_TYPE STATIC PARENT_SCOPE)
  endif()

  # Toggles
  option(${PROJECT_PREFIX}_ENABLE_BENCHMARKS "Build benchmarks."                OFF)
  option(${PROJECT_PREFIX}_ENABLE_COVERAGE   "Build code coverage."             OFF)
  option(${PROJECT_PREFIX}_ENABLE_DOCS       "Build documentation."             ON)
  option(${PROJECT_PREFIX}_ENABLE_EXAMPLES   "Build example programs."          ON)
  option(${PROJECT_PREFIX}_ENABLE_LTO        "Enable Link Time Optimization."   OFF)
  option(${PROJECT_PREFIX}_ENABLE_LINT       "Enable static code analysis."     OFF) # clang-tidy, clang-format, cppcheck.
  option(${PROJECT_PREFIX}_ENABLE_NARCH      "Enable host CPU optimization."    OFF) # -march=native
  option(${PROJECT_PREFIX}_ENABLE_PROFILER   "Enable profiling."                OFF)
  option(${PROJECT_PREFIX}_ENABLE_SANITIZERS "Enable sanitizers."               OFF) # ASan, UBSan, TSan, MSan.
  option(${PROJECT_PREFIX}_ENABLE_TESTING    "Build test suites."               ON)
  option(${PROJECT_PREFIX}_ENABLE_WARNINGS   "Enable strict compiler warnings." OFF)

  # Sanitizer Type
  # Valid Options: Address, Undefined, Thread, Memory
  set(${PROJECT_PREFIX}_SANITIZER_TYPE "Address" CACHE STRING "Sanitizer")
  set_property(CACHE ${PROJECT_PREFIX}_SANITIZER_TYPE PROPERTY STRINGS "Address" "Undefined" "Thread" "Memory")

  # Installation Options
  option(${PROJECT_PREFIX}_INSTALL "Enable installation of the library." OFF)

  # Whether it is being built as a part of larger project.
  option(${PROJECT_PREFIX}_INTERNAL "Whether this library is being built as part of a larger project." OFF)
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_setup_feature_options
# Description: This function sets up the options for specific features of a project.
# Args:
#   ...: List of feature names to create options for.
# --------------------------------------------------------------------------------------------------
function(mystic_setup_feature_options)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Feature Toggles
  foreach(FEATURE IN LISTS ARGN)
    _mystic_to_constant_case(FEATURE FEATURE_FORMATTED)
    set(${PROJECT_PREFIX}_ENABLE_${FEATURE_FORMATTED} "OFF" CACHE BOOL "Enable ${FEATURE} feature.")
  endforeach()
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_setup_third_party_options
# Description: This function sets up the options for third-party libraries used in a project.
# Args:
#   ...: List of third-party library names to create options for.
# --------------------------------------------------------------------------------------------------
function(mystic_setup_third_party_options)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Toggles for third-party libraries to use system-installed versions.
  option(${PROJECT_PREFIX}_USE_SYSTEM "Use system-installed third-party libraries." OFF)

  # Check if the master toggle changed since the last CMake configure run
  set(PREV_STATE_VAR "_${PROJECT_PREFIX}_USE_SYSTEM_PREV")
  set(MASTER_CHANGED FALSE)
  if(NOT DEFINED ${PREV_STATE_VAR} OR NOT "${${PREV_STATE_VAR}}" STREQUAL "${${PROJECT_PREFIX}_USE_SYSTEM}")
    set(MASTER_CHANGED TRUE)
    set(${PREV_STATE_VAR} "${${PROJECT_PREFIX}_USE_SYSTEM}" CACHE INTERNAL "Previous state of ${PROJECT_PREFIX}_USE_SYSTEM")
  endif()

  # For each third-party library, create an option to use the system-installed version.
  foreach(LIB IN LISTS ARGN)
    _mystic_to_constant_case(LIB LIB_FORMATTED)
    set(OPT_VAR "${PROJECT_PREFIX}_USE_SYSTEM_${LIB_FORMATTED}")

    # If the user flipped the master USE_SYSTEM switch, propagate it to all children
    if(MASTER_CHANGED)
      set(${OPT_VAR} ${${PROJECT_PREFIX}_USE_SYSTEM} CACHE BOOL "Use system installed ${LIB}." FORCE)
    else()
      option(${OPT_VAR} "Use system installed ${LIB}." OFF)
    endif()
  endforeach()
endfunction()
