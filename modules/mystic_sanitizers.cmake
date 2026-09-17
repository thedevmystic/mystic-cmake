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
# File: mystic_sanitizers.cmake
# Description: This CMake module is used to enable sanitizers for the project. It provides a
# function to set the appropriate compiler flags based on the selected sanitizer.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_sanitizers)
# # Call the mystic_sanitizers function to enable sanitizers:
# mystic_sanitizers(
#   SANITIZER <SANITIZER_VARIANT>  # The sanitizer variant (address, undefined, thread, memory)
#   TARGETS <LIST_OF_TARGETS>      # The list of targets to apply the sanitizer to
# )
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# Helper functions to add the appropriate sanitizer flags
function(_mystic_add_address_sanitizer target)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    target_compile_options(${target} PRIVATE /fsanitize=address /Zi)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${target} PRIVATE -fsanitize=address -g -fno-omit-frame-pointer)
    target_link_options(${target} PRIVATE -fsanitize=address)
  else()
    mystic_message(WARNING "Unknown compiler. Skipping sanitizer flags for ${target}.")
  endif()
endfunction()

function(_mystic_add_undefined_sanitizer target)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "UndefinedBehaviorSanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${target} PRIVATE -fsanitize=undefined -g -fno-omit-frame-pointer)
    target_link_options(${target} PRIVATE -fsanitize=undefined)
  else()
    mystic_message(WARNING "Unknown compiler. Skipping sanitizer flags for ${target}.")
  endif()
endfunction()

function(_mystic_add_thread_sanitizer target)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "ThreadSanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(${target} PRIVATE -fsanitize=thread -g -fno-omit-frame-pointer)
    target_link_options(${target} PRIVATE -fsanitize=thread)
  else()
    mystic_message(WARNING "Unknown compiler. Skipping sanitizer flags for ${target}.")
  endif()
endfunction()

function(_mystic_add_memory_sanitizer target)
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    mystic_message(FATAL_ERROR "MemorySanitizer is not available in MSVC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    mystic_message(FATAL_ERROR "MemorySanitizer is not available in GCC.")
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(${target} PRIVATE -fsanitize=memory -g -fno-omit-frame-pointer)
    target_link_options(${target} PRIVATE -fsanitize=memory)
  else()
    mystic_message(WARNING "Unknown compiler. Skipping sanitizer flags for ${target}.")
  endif()
endfunction()

# ---------------------------------------------------------------------------------------------------
# Function: mystic_sanitizers
# Description: Enables the specified sanitizer for the given targets.
# Args:
#   SANITIZER: The sanitizer variant (address, undefined, thread, memory).
#   TARGETS: A list of targets to apply the sanitizer to.
# ---------------------------------------------------------------------------------------------------
function(mystic_sanitizers)
  set(options)
  set(oneValueArgs "SANITIZER")
  set(multiValueArgs "TARGETS")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_sanitizers received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARG_SANITIZER)
    mystic_message(FATAL_ERROR "mystic_sanitizers: SANITIZER argument is required.")
  endif()

  if(NOT ARG_TARGETS)
    mystic_message(FATAL_ERROR "mystic_sanitizers: TARGETS argument is required.")
  endif()

  foreach(target IN LISTS ARG_TARGETS)
    if(ARG_SANITIZER STREQUAL "address")
      _mystic_add_address_sanitizer(${target})
    elseif(ARG_SANITIZER STREQUAL "undefined")
      _mystic_add_undefined_sanitizer(${target})
    elseif(ARG_SANITIZER STREQUAL "thread")
      _mystic_add_thread_sanitizer(${target})
    elseif(ARG_SANITIZER STREQUAL "memory")
      _mystic_add_memory_sanitizer(${target})
    else()
      mystic_message(FATAL_ERROR "mystic_sanitizers: Unknown sanitizer: ${ARG_SANITIZER}. Valid options are: address, undefined, thread, memory.")
    endif()
  endforeach()
endfunction()
