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
# File: mystic_include_third_party.cmake
# Description: This CMake module is used to include third-party libraries from "third_parties" in
#              a CMake project.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_include_third_party)
# # Call the function to include third-party libraries:
# mystic_include_third_party()
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")

# -------------------------------------------------------------------------------------------------
# Function: mystic_include_third_party
# Description: This function scans a specified root directory for third-party libraries and
# processes them.
# Args:
#   ROOT_DIR: The root directory containing third-party libraries. Defaults to:
#             "${CMAKE_CURRENT_SOURCE_DIR}/third_party".
# -------------------------------------------------------------------------------------------------
function(mystic_include_third_party)
  # Determine the root directory for third-party libraries
  if(ARGC EQUAL 0)
    set(ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party")
  else()
    set(ROOT_DIR "${ARGV0}")
  endif()

  mystic_message(STATUS "Scanning for third-party libraries...")

  # Find all CMakeLists.txt files recursively in third_party
  file(GLOB_RECURSE CMAKE_FILES CONFIGURE_DEPENDS RELATIVE "${ROOT_DIR}" "${ROOT_DIR}/**/CMakeLists.txt")

  foreach(CMAKE_FILE IN LISTS CMAKE_FILES)
    # Get the relative directory path (e.g., "libfoo" out of "libfoo/CMakeLists.txt")
    get_filename_component(SUB_DIR "${CMAKE_FILE}" DIRECTORY)

    # Skip the root directory itself if it accidentally matches
    if(SUB_DIR STREQUAL "")
      continue()
    endif()

    set(FULL_SUB_DIR_PATH "${ROOT_DIR}/${SUB_DIR}")
    get_filename_component(DIR_NAME "${SUB_DIR}" NAME)

    # Add the subdirectory to the build layout
    add_subdirectory("${FULL_SUB_DIR_PATH}" "${CMAKE_BINARY_DIR}/third_party/${DIR_NAME}")
  endforeach()

  mystic_message(STATUS "Imported all third-party libraries. Done.")
endfunction()
