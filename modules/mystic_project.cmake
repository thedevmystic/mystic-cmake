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
# File: mystic_project.cmake
# Description: This CMake module is used to simplify the process of a project.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(mystic_project)
# # Then call the mystic_project function:
# mystic_project()
# # It reads from the project.json file and sets the parameters for the project() command.
# project(<YOUR_PROJECT_NAME>_PROJECT_ARGUMENTS)
# # If your project name is "MyProject",then the arguments for the project() command are as follows:
# project(MYPROJECT_PROJECT_ARGUMENTS)
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Valid example of project.json file: 
# --------------------------------------------------------------------------------------------------
# {
#   "name": "MyProject",
#   "version": "3.4.5",
#   "description": "This is a sample project.",
#   "homepage": "https://example.com",
#   "languages": ["CXX"],
#   "cxx_standard": "23",
#   "license": "<SPDX_LICENSE_IDENTIFIER>",
# }
# --------------------------------------------------------------------------------------------------
# Here:
# - "name" is the name of the project. (Required)
# - "version" is the version of the project. (Optional)
# - "description" is a brief description of the project. (Optional)
# - "homepage" is the URL of the project's homepage. (Optional)
# - "languages" is a list of programming languages used in the project. (Optional)
# - "cxx_standard" is the C++ standard version used in the project. (Optional, only applicable
#   if CXX is specified in "languages")
# - "license" is the SPDX license identifier for the project. (Optional)
# Note:
# - The "name" field is required and must be a non-empty string. It is used as the prefix for the
#   project() command arguments.
# - If you specify "name" as "MyProject", then the project() command arguments will be called as:
#   MYPROJECT_PROJECT_ARGUMENTS.
# - The "version" field is optional. If not specified, it will be set to "1.0.0" by default.
# - The "languages" field should be a list of strings, where each string is a valid CMake
#   language identifier.
# - The "cxx_standard" field should be a string representing the C++ standard version, such as
#   "11", "14", "17", "20", or "23".
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/mystic_message.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/helpers.cmake")

function(_mystic_project_read_content JSON_CONTENT VARIABLE_NAME REQ)
  # Read the content of the specified variable from the JSON content
  string(JSON VARIABLE_CONTENT ERROR_VARIABLE JSON_ERROR GET "${JSON_CONTENT}" "${VARIABLE_NAME}")

  # Stop the build if the required field is missing in the project.json file
  if(REQ AND NOT VARIABLE_CONTENT)
    mystic_message(FATAL_ERROR "Required field '${VARIABLE_NAME}' is missing in the project.json file.")
  endif()

  # If the variable content is empty, return without setting any variable
  if(NOT VARIABLE_CONTENT)
    return()
  endif()

  # Get prefix if it's already set
  get_property(_MYSTIC_PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Set prefix for the every variable name or prefixes used in Mystic Framework.
  if(VARIABLE_NAME STREQUAL "name" AND NOT _MYSTIC_PROJECT_PREFIX)
    _mystic_to_constant_case("${VARIABLE_CONTENT}" _MYSTIC_PROJECT_PREFIX)
    set_property(DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX "${_MYSTIC_PROJECT_PREFIX}")
  endif()

  # Handle languages field, which is an array of strings. Convert it to a semicolon-separated list for CMake.
  if(VARIABLE_NAME STREQUAL "languages")
    string(JSON ARRAY_LEN LENGTH "${JSON_CONTENT}" "${VARIABLE_NAME}")
    if(ARRAY_LEN GREATER 0)
      set(LANGUAGES_LIST "")
      math(EXPR MAX_INDEX "${ARRAY_LEN} - 1")
      foreach(INDEX RANGE 0 ${MAX_INDEX})
        string(JSON LANGUAGES_ITEM GET "${JSON_CONTENT}" "${VARIABLE_NAME}" "${INDEX}")
        list(APPEND LANGUAGES_LIST "${LANGUAGES_ITEM}")
      endforeach()
      set(VARIABLE_CONTENT "${LANGUAGES_LIST}")
    endif()
  endif()

  # Re-fetch the prefix in case it was set in this function
  get_property(_MYSTIC_PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  _mystic_to_constant_case("${VARIABLE_NAME}" VARIABLE_NAME_CONSTANT)
  set("${_MYSTIC_PROJECT_PREFIX}_${VARIABLE_NAME_CONSTANT}" "${VARIABLE_CONTENT}" CACHE INTERNAL "Project ${VARIABLE_NAME}.")
endfunction()

function(_mystic_append_project_command FIELD CONTENT OUT_VAR)
  if(NOT CONTENT)
    return()
  endif()

  # Pull in the caller's current list via the output variable name
  set(ARGUMENTS "${${OUT_VAR}}")

  # Handle the LANGUAGES field (space-separate instead of semicolon-separate)
  if(FIELD STREQUAL "LANGUAGES")
    string(REPLACE ";" " " CONTENT "${CONTENT}")
  endif()

  list(APPEND ARGUMENTS "${FIELD}" "${CONTENT}")

  # Write the updated list back to the caller's scope
  set(${OUT_VAR} "${ARGUMENTS}" PARENT_SCOPE)
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_project
# Description: This function reads the project.json file and sets the parameters for the project()
# command. It also sets the C++ standard version if specified in the project.json file.
# Args:
#   JSON_PATH: to the project.json file (optional, default is "${CMAKE_SOURCE_DIR}/project.json")
# --------------------------------------------------------------------------------------------------
function(mystic_project)
  set(options "")
  set(singleValueArgs "JSON_PATH")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${singleValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(SEND_ERROR "mystic_project received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()

  # Read the project.json file
  if(ARG_JSON_PATH)
    set(PROJECT_JSON_PATH "${ARG_JSON_PATH}")
  else()
    set(PROJECT_JSON_PATH "${CMAKE_SOURCE_DIR}/project.json")
  endif()

  # Read the content of the project.json file
  if(EXISTS "${PROJECT_JSON_PATH}")
    file(READ "${PROJECT_JSON_PATH}" PROJECT_JSON_CONTENT)
  else()
    mystic_message(FATAL_ERROR "Configuration file not found at ${PROJECT_JSON_PATH}")
  endif()

  # Validate the project.json content
  if(NOT PROJECT_JSON_CONTENT)
    mystic_message(FATAL_ERROR "Failed to read configuration file at ${PROJECT_JSON_PATH}")
  endif()

  # Read the required and optional fields from the project.json file
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "name" TRUE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "version" FALSE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "description" FALSE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "homepage" FALSE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "languages" FALSE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "cxx_standard" FALSE)
  _mystic_project_read_content("${PROJECT_JSON_CONTENT}" "license" FALSE)

  # Get the project prefix for use in constructing variable names
  get_property(_MYSTIC_PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  # Set the project command arguments
  set(_MYSTIC_PROJECT_ARGUMENTS "${${_MYSTIC_PROJECT_PREFIX}_NAME}")
  _mystic_append_project_command("VERSION" "${${_MYSTIC_PROJECT_PREFIX}_VERSION}" _MYSTIC_PROJECT_ARGUMENTS)
  _mystic_append_project_command("DESCRIPTION" "${${_MYSTIC_PROJECT_PREFIX}_DESCRIPTION}" _MYSTIC_PROJECT_ARGUMENTS)
  _mystic_append_project_command("HOMEPAGE_URL" "${${_MYSTIC_PROJECT_PREFIX}_HOMEPAGE}" _MYSTIC_PROJECT_ARGUMENTS)
  _mystic_append_project_command("LANGUAGES" "${${_MYSTIC_PROJECT_PREFIX}_LANGUAGES}" _MYSTIC_PROJECT_ARGUMENTS)

  # SPDX_LICENSE was only added to project() in CMake 4.3. On older CMake it would be
  # misread as an extra language name, so only pass it through when it's supported.
  if(${_MYSTIC_PROJECT_PREFIX}_LICENSE)
    if(CMAKE_VERSION VERSION_GREATER "4.3")
      _mystic_append_project_command("SPDX_LICENSE" "${${_MYSTIC_PROJECT_PREFIX}_LICENSE}" _MYSTIC_PROJECT_ARGUMENTS)
    endif()
  endif()

  # Set the C++ standard version if specified in the project.json file
  if(${_MYSTIC_PROJECT_PREFIX}_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD "${${_MYSTIC_PROJECT_PREFIX}_CXX_STANDARD}")
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
  endif()

  # Set the project command arguments as a cache variable for use in the project() command
  set("${_MYSTIC_PROJECT_PREFIX}_PROJECT_ARGUMENTS" "${_MYSTIC_PROJECT_ARGUMENTS}" CACHE INTERNAL "Arguments for the project() command.")
endfunction()
