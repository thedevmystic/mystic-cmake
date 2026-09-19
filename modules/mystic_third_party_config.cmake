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
# File: mystic_third_party_config.cmake
# Description: This CMake module is used to include a third-party dependency in the project. It
# checks for system-installed libraries first (if enabled), and if not found, fetches the library
# from GitHub using FetchContent.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_third_party_config)
# # Use the function to include a third-party dependency:
# mystic_third_party_config(MyLib
#   VERSION 1.2.3
#   GIT_URL https://github.com/username/repo.git
#   GIT_TAG v1.2.3
# )
#
# If we have to pass build flags to a library define then before using this.
# set(MY_LIB_TEST OFF CACHE INTERNAL "Turn off my_lib's test suites.")
# ... other build flags
#
# include(mystic_third_party_config)
# mystic_third_party_config(MyLib
#   VERSION 1.2.3
#   GIT_URL https://github.com/username/repo.git
#   GIT_TAG v1.2.3
# )
# --------------------------------------------------------------------------------------------------

include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/helpers.cmake")

# --------------------------------------------------------------------------------------------------
# Function: mystic_third_party_config
# Description: This function includes a third-party dependency in the project. It checks for
# system-installed libraries first (if enabled), and if not found, fetches the library from
# GitHub using FetchContent.
# Args:
# NAME: Name of the library, e.g., Catch2.
# VERSION: Version of the library, e.g., 2.13.7 (Optional).
# GIT_URL: URL of the Git repository (Optional if only using system-installed libraries).
# GIT_TAG: Library's Git Tag. (Optional, defaults to the "main")
# FAIL_IF_SYSTEM_NOT_FOUND: Flag to fail if find_package fails (Optional).
# --------------------------------------------------------------------------------------------------
function(mystic_third_party_config NAME)
  # Get the project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_third_party_config'.")
  endif()

  set(options "FAIL_IF_SYSTEM_NOT_FOUND")
  set(singleValueArgs "VERSION" "GIT_URL" "GIT_TAG")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  # Check if unprocessed arguments exist
  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_third_party_config received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Validate Args
  if(NOT NAME)
    mystic_message(FATAL_ERROR "NAME not defined in mystic_third_party_config.")
  endif()

  # Check for system-installed library first if enabled
  _mystic_to_constant_case("${NAME}" NAME_CONSTANT)
  if(${PROJECT_PREFIX}_USE_SYSTEM_${NAME_CONSTANT})
    mystic_message(STATUS "Searching for system-installed ${NAME}...")

    # When VERSION is provided use it
    if(ARG_VERSION)
      find_package(${NAME} ${ARG_VERSION} QUIET)
    else()
      find_package(${NAME} QUIET)
    endif()

    # Check if it found, otherwise fallback to FetchContent
    if(${NAME}_FOUND OR TARGET ${NAME}::${NAME})
      mystic_message(STATUS "Found system-installed ${NAME}. Done.")
      return()
    else()
      if(ARG_FAIL_IF_SYSTEM_NOT_FOUND)
        mystic_message(FATAL_ERROR "Unable to find system-installed ${NAME}.")
      else()
        mystic_message(STATUS "Unable to find system-installed ${NAME}. Fallback to FetchContent.")
      endif()
    endif()
  endif()

  # Validate URL when system-installed library is not used
  if(NOT ARG_GIT_URL)
    mystic_message(FATAL_ERROR "GIT_URL is required when system-install library cannot be used.")
  endif()

  # Determine tag
  if(ARG_GIT_TAG)
    set(GIT_TAG "${ARG_GIT_TAG}")
  else()
    set(GIT_TAG "main")
  endif()

  mystic_message(STATUS "Fetching ${NAME} via FetchContent...")

  # Fetch it
  string(TOLOWER "${NAME}" NAME_LOWER)
  FetchContent_Declare(
    ${NAME_LOWER}
    GIT_REPOSITORY ${ARG_GIT_URL}
    GIT_TAG ${GIT_TAG}
    QUIET
  )
  FetchContent_MakeAvailable(${NAME_LOWER})

  mystic_message(STATUS "Fetched ${NAME}. Done.")
endfunction()
