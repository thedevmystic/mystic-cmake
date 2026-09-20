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
# File: mystic_import_module.cmake
# Description: This CMake module is used to import first-party modules from the Mystic Framework.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_import_module)
# # Prepare for import by specifying the module name:
# mystic_prepare_for_import(<MODULE_NAME>)
# # Import the module by specifying the module name and optional version:
# mystic_import_module(<MODULE_NAME> [VERSION <VERSION>] [GIT_TAG <GIT_TAG>])
# --------------------------------------------------------------------------------------------------
# Note:
#   - VERSION is used for find_package and should be a valid version string.
#   - GIT_TAG is used for FetchContent and should be a valid git tag or branch name.
# --------------------------------------------------------------------------------------------------

include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/private_helpers.cmake")

# Checks if the module name is valid
function(_mystic_is_valid_module MODULE_NAME)
  set(_MYSTIC_VALID_MODULES
    "common"
    "traits"
    # Add new modules here
  )

  string(TOLOWER "${MODULE_NAME}" MODULE_NAME_LOWER)
  list(FIND _MYSTIC_VALID_MODULES "${MODULE_NAME_LOWER}" MODULE_INDEX)
  if(MODULE_INDEX EQUAL -1)
    mystic_message(FATAL_ERROR "Invalid module name: ${MODULE_NAME}. Please check the list of valid modules.")
  endif()
endfunction()

# -------------------------------------------------------------------------------------------------
# Function: mystic_prepare_for_import
# Description: Prepares the environment for importing a Mystic Framework module.
# Args:
#   MODULE_NAME: The name of the module to prepare for import.
# -------------------------------------------------------------------------------------------------
function(mystic_prepare_for_import MODULE_NAME)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_prepare_for_import'.")
  endif()

  # Check if MODULE_NAME is defined
  if(NOT DEFINED MODULE_NAME)
    mystic_message(FATAL_ERROR "MODULE_NAME not defined in mystic_prepare_for_import.")
  endif()

  # Check if the module name is valid
  _mystic_is_valid_module("${MODULE_NAME}")

  _mystic_to_constant_case("${MODULE_NAME}" MODULE_NAME_CONSTANT_CASE)
  set(PREFIX "MYSTIC${MODULE_NAME_CONSTANT_CASE}")

  # Set default build configuration
  set(${PREFIX}_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Build type.")
  set(${PREFIX}_BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries (static, if OFF).")

  # Disable standard options by default
  set(${PREFIX}_ENABLE_BENCHMARKS OFF CACHE BOOL "Build benchmarks.")
  set(${PREFIX}_ENABLE_COVERAGE   OFF CACHE BOOL "Build code coverage.")
  set(${PREFIX}_ENABLE_DOCS       OFF CACHE BOOL "Build documentation.")
  set(${PREFIX}_ENABLE_EXAMPLES   OFF CACHE BOOL "Build example programs.")
  set(${PREFIX}_ENABLE_LINT       OFF CACHE BOOL "Enable static code analysis.")
  set(${PREFIX}_ENABLE_PROFILER   OFF CACHE BOOL "Enable profiling.")
  set(${PREFIX}_ENABLE_SANITIZERS OFF CACHE BOOL "Enable sanitizers.")
  set(${PREFIX}_ENABLE_TESTING    OFF CACHE BOOL "Build test suites.")
  set(${PREFIX}_ENABLE_WARNINGS   OFF CACHE BOOL "Enable strict compiler warnings.")
  set(${PREFIX}_INSTALL           OFF CACHE BOOL "Enable installation of the library.")

  # Conditional toggles
  set(${PREFIX}_ENABLE_LTO ${${PROJECT_PREFIX}_ENABLE_LTO} CACHE BOOL "Enable Link Time Optimization.")
  set(${PREFIX}_ENABLE_NARCH ${${PROJECT_PREFIX}_ENABLE_NARCH} CACHE BOOL "Enable host CPU optimization.")
  set(${PREFIX}_USE_SYSTEM ${${PROJECT_PREFIX}_USE_SYSTEM} CACHE BOOL "Use system-installed libraries.")

  # Enable internal build flag
  set(${PREFIX}_INTERNAL ON CACHE BOOL "Whether this library is being built as part of a larger project.")
endfunction()

# -------------------------------------------------------------------------------------------------
# Function: mystic_import_module
# Description: Imports a Mystic Framework module, either from the system or by fetching it.
# Args:
#   MODULE_NAME: The name of the module to import.
#   VERSION: Optional version string for find_package.
#   GIT_TAG: Optional git tag or branch name for FetchContent.
# -------------------------------------------------------------------------------------------------
function(mystic_import_module MODULE_NAME)
  set(options "")
  set(singleValueArgs "VERSION" "GIT_TAG")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_import_module received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Check if MODULE_NAME is defined
  if(NOT DEFINED MODULE_NAME)
    mystic_message(FATAL_ERROR "MODULE_NAME not defined in mystic_import_module.")
  endif()

  # Check if the module name is valid
  _mystic_is_valid_module("${MODULE_NAME}")

  # Disable standard output and ASCII banner for cleaner output
  set(MYSTIC_MESSAGE_ONLY_ERRORS ON)
  set(MYSTIC_ASCII_BANNER_DISABLE ON)

  mystic_message(STATUS "Importing module: ${MODULE_NAME}...")

  # First, check if the module is already available via find_package
  _mystic_capitalize_first_letter("${MODULE_NAME}" MODULE_NAME_CAPITALIZED)
  set(FIND_PACKAGE_NAME "Mystic${MODULE_NAME_CAPITALIZED}")
  if(ARG_VERSION)
    find_package(${FIND_PACKAGE_NAME} ${ARG_VERSION} QUIET)
  else()
    find_package(${FIND_PACKAGE_NAME} QUIET)
  endif()

  if(${FIND_PACKAGE_NAME}_FOUND)
    mystic_message(STATUS "Found system-installed module: ${MODULE_NAME}. Done.")
    return()
  endif()

  # If not found, fetch the module using FetchContent
  string(TOLOWER "${MODULE_NAME}" MODULE_NAME_LOWER)
  set(REPOSITORY_URL "https://github.com/mystic-framework/${MODULE_NAME_LOWER}.git")
  if(ARG_GIT_TAG)
    set(GIT_TAG "${ARG_GIT_TAG}")
  else()
    set(GIT_TAG "main")
  endif()

  FetchContent_Declare(
    mystic_${MODULE_NAME_LOWER}
      GIT_REPOSITORY ${REPOSITORY_URL}
      GIT_TAG        ${GIT_TAG}
      QUIET
  )
  FetchContent_MakeAvailable(mystic_${MODULE_NAME_LOWER})

  mystic_message(STATUS "Imported module: ${MODULE_NAME} from GitHub. Done.")
endfunction()
