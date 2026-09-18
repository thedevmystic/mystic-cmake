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
# File: mystic_coverage.cmake
# Description: This CMake module is used to set up code coverage options for a CMake project. It
# provides a function to enable code coverage flags and settings for supported compilers.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_coverage)
# # Then call the function to enable code coverage:
# mystic_coverage(<TARGET_NAME>)
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# --------------------------------------------------------------------------------------------------
# Function: mystic_coverage
# Description: This function enables code coverage flags and settings for the specified target.
# It checks the compiler being used and applies the appropriate flags for code coverage.
# Supported compilers: GCC, Clang.
# Args:
#   ...: List of target names to enable code coverage for.
# --------------------------------------------------------------------------------------------------
function(mystic_coverage)
  # Guard against empty argument list
  if(NOT ARGN)
    mystic_message(FATAL_ERROR "mystic_coverage requires at least one target name as an argument.")
  endif()

  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_coverage'.")
  endif()

  # Check if coverage is enabled
  if(NOT ${PROJECT_PREFIX}_ENABLE_COVERAGE)
    mystic_message(STATUS "Code coverage is disabled. Skipping coverage setup for targets.")
    return()
  endif()

  # Iterate over each target provided in the arguments
  foreach(target IN LISTS ARGN)
    # Guard against invalid targets
    if(NOT TARGET "${target}")
      mystic_message(FATAL_ERROR "'${target}' provided in 'mystic_coverage' is not a valid CMake target.")
    endif()

    mystic_message(STATUS "Adding coverage flags to the following target: ${target}")

    # Check the compiler and apply appropriate coverage flags
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      target_compile_options(${target} PRIVATE -fprofile-instr-generate -fcoverage-mapping -g)
      target_link_options(${target} PRIVATE -fprofile-instr-generate)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
      target_compile_options(${target} PRIVATE --coverage -g)
      target_link_options(${target} PRIVATE --coverage)
    else()
      mystic_message(FATAL_ERROR "Coverage is only supported in Clang and GCC.")
    endif()
  endforeach()
endfunction()
