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
# File: MysticLint.cmake
# Description: This CMake module is used to lint CMake projects. It provides linting for C/C++
# projects using clang-format and clang-tidy.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticLint)
# # Then call the function to enable code coverage:
# mystic_lint(<TARGET_NAME(S)>
#   [FORMAT_ARGS <args>]        # Optional: Additional arguments to pass to clang-format.
#   [TIDY_ARGS <args>]          # Optional: Additional arguments to pass to clang-tidy.
#   [DISABLE_FORMAT]            # Optional: Disable clang-format linting.
#   [DISABLE_TIDY]              # Optional: Disable clang-tidy linting.
# )
# --------------------------------------------------------------------------------------------------
# Note:
# This module requires:
# - clang-format
# - clang-tidy
# - Working installation of Python3 since it uses python to scan tidy deps.
# --------------------------------------------------------------------------------------------------

include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# This needs Compile Commands to work properly
if(NOT CMAKE_EXPORT_COMPILE_COMMANDS)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

# Helper function to find binaries
function(_mystic_find_lint_binaries)
  find_program(CLANG_FORMAT_EXE NAMES clang-format)
  find_program(CLANG_TIDY_EXE NAMES clang-tidy)
  find_program(CLANG_SCAN_DEPS_EXE NAMES clang-scan-deps)
  find_package(Python3 COMPONENTS Interpreter QUIET)

  if(NOT CLANG_FORMAT_EXE)
    mystic_message(WARNING "clang-format not found. Format targets will be no-ops.")
  endif()
   
  if(NOT CLANG_TIDY_EXE)
    mystic_message(WARNING "clang-tidy not found. Lint targets will be no-ops.")
  endif()

  if(NOT CLANG_SCAN_DEPS_EXE)
    mystic_message(WARNING "clang-scan-deps not found. Falling back to coarse target-level deps only.")
  endif()

  if(NOT Python3_Interpreter_FOUND)
    mystic_message(WARNING "python3 not found. fine-grained deps disabled, falling back to coarse target-level deps.")
  endif()
endfunction()

# Sanitize paths
function(_mystic_sanitize_path OUT_VAR PATH)
  string(REGEX REPLACE "[^A-Za-z0-9]" "_" _SANITIZED "${PATH}")
  set(${OUT_VAR} "${_SANITIZED}" PARENT_SCOPE)
endfunction()

# Creates format target
function(_mystic_create_format_target TARGET_NAME FORMAT_ARGS)
  # All files: Sources, headers, and modules.
  set(ALL_FILES "")

  # Source files
  get_target_property(SRC_FILES ${TARGET_NAME} SOURCES)
  if(SRC_FILES)
    list(APPEND ALL_FILES "${SRC_FILES}")
  endif()

  # Header file and modules file sets
  foreach(SET_TYPE HEADER CXX_MODULE)
    foreach(PROP_PREFIX "" "INTERFACE_")
      get_target_property(SETS ${TARGET_NAME} ${PROP_PREFIX}${SET_TYPE}_SETS)
      if(SETS)
        foreach(SET_NAME IN LISTS SETS)
          get_target_property(SET_FILES ${TARGET_NAME} ${PROP_PREFIX}${SET_TYPE}_SET_${SET_NAME})
          if(SET_FILES)
            list(APPEND ALL_FILES "${SET_FILES}")
          endif()
        endforeach()
      endif()
    endforeach()
  endforeach()

  # If no files found, warn and return
  if(NOT ALL_FILES)
    mystic_message(WARNING "No source, header, or module files found for target: ${TARGET_NAME}. Skipping format target creation.")
    return()
  endif()

  # Filter generator expressions
  list(FILTER ALL_FILES EXCLUDE REGEX "\\$<")

  # Convert to absolute paths
  set(ABS_FILES "")
  get_target_property(TARGET_DIR ${TARGET_NAME} SOURCE_DIR)
  foreach(FILE IN LISTS ALL_FILES)
    cmake_path(ABSOLUTE_PATH FILE BASE_DIRECTORY ${TARGET_DIR} NORMALIZE)
    list(APPEND ABS_FILES "${FILE}")
  endforeach()

  # Deduplicate the list of files
  list(REMOVE_DUPLICATES ABS_FILES)

  # Add a custom target for formatting the specific target
  add_custom_target("format_${TARGET_NAME}"
    COMMAND ${CLANG_FORMAT_EXE} ${FORMAT_ARGS} ${ABS_FILES}
    COMMENT "Formatting target: ${TARGET_NAME}"
    VERBATIM
  )

  # Add a global format target if it doesn't exist
  if(NOT TARGET format)
    add_custom_target(format)
  endif()

  # Add the target-specific format target as a dependency of the global format target
  add_dependencies(format "format_${TARGET_NAME}")
endfunction()

# Creates lint target
function(_mystic_create_lint_target TARGET_NAME TIDY_ARGS)
  # Get source files
  get_target_property(SRC_FILES ${TARGET_NAME} SOURCES)

  # If no source files found, warn and return
  if(NOT SRC_FILES)
    mystic_message(WARNING "No source files found for target: ${TARGET_NAME}. Skipping lint target creation.")
    return()
  endif()

  # Filter out generator expressions
  list(FILTER SRC_FILES EXCLUDE REGEX "\\$<")

  # Convert to absolute paths
  set(ABS_FILES "")
  set(REL_FILES "")
  get_target_property(TARGET_DIR ${TARGET_NAME} SOURCE_DIR)
  foreach(FILE IN LISTS SRC_FILES)
    cmake_path(ABSOLUTE_PATH ABS_FILE BASE_DIRECTORY ${TARGET_DIR} NORMALIZE)
    file(RELATIVE_PATH REL_FILE "${TARGET_DIR}" "${ABS_FILE}")
    list(APPEND ABS_FILES "${ABS_FILE}")
    list(APPEND REL_FILES "${REL_FILE}")
  endforeach()

  # Deduplicate the list of files
  list(REMOVE_DUPLICATES ABS_FILES)

  # Phase 1: Regenrate raw P1689 scans
  set(SCAN_DEPS_JSON "${CMAKE_BINARY_DIR}/module_deps_${TARGET_NAME}.json")

  # If clang-scan-deps is available, generate a P1689 scan for the target.
  # Otherwise, generate a mock scan to satisfy DEPENDS.
  if(CLANG_SCAN_DEPS_EXE)
    add_custom_command(
      OUTPUT "${SCAN_DEPS_JSON}"
      COMMAND ${CLANG_SCAN_DEPS_EXE} -format=p1689
              -compilation-database=${CMAKE_BINARY_DIR}/compile_commands.json
              > ${SCAN_DEPS_JSON}
      DEPENDS ${ABS_FILES} ${CMAKE_BINARY_DIR}/compile_commands.json
      COMMENT "Generating P1689 scan for target: ${TARGET_NAME}"
      VERBATIM
    )
  else()
    add_custom_command(
      OUTPUT "${SCAN_DEPS_JSON}"
      COMMAND ${CMAKE_COMMAND} -E touch "${SCAN_DEPS_JSON}"
      DEPENDS ${ABS_FILES}
      COMMENT "clang-scan-deps not found. Generating mock scan for target: ${TARGET_NAME}"
      VERBATIM
    )
  endif()

  # Phase 2: Generate tidy deps CMake file
  set(TIDY_DEPS_CMAKE "${CMAKE_BINARY_DIR}/tidy_deps_${TARGET_NAME}.cmake")

  # If python3 is available, generate the tidy deps CMake file using the helper script.
  # Otherwise, generate a mock tidy deps CMake file to satisfy DEPENDS.
  if(Python3_Interpreter_FOUND)
    add_custom_command(
      OUTPUT "${TIDY_DEPS_CMAKE}"
      COMMAND ${Python3_EXECUTABLE}
              ${CMAKE_CURRENT_LIST_DIR}/scripts/gen_tidy_deps.py
              ${SCAN_DEPS_JSON} ${TIDY_DEPS_CMAKE}
              --target ${TARGET_NAME}
      DEPENDS "${SCAN_DEPS_JSON}" ${CMAKE_CURRENT_LIST_DIR}/scripts/generate_tidy_deps.py
      COMMENT "Generating tidy deps CMake file for target: ${TARGET_NAME}"
      VERBATIM
    )
  else()
    add_custom_command(
      OUTPUT "${TIDY_DEPS_CMAKE}"
      COMMAND ${CMAKE_COMMAND} -E touch "${TIDY_DEPS_CMAKE}"
      DEPENDS "${SCAN_DEPS_JSON}"
      COMMENT "python3 not found. Generating mock tidy deps CMake file for target: ${TARGET_NAME}"
      VERBATIM
    )
  endif()

  # Add scanning as custom target so it becomes a build node and can be depended on.
  add_custom_target("scan_deps_${TARGET_NAME}" 
    DEPENDS "${TIDY_DEPS_CMAKE}"
    COMMENT "Scanning dependencies for target: ${TARGET_NAME}"
  )

  # Include the generated tidy deps CMake file to get the list of files to lint.
  # If it does not exist, then we fallback to coarse target-level linting.
  if(EXISTS "${TIDY_DEPS_CMAKE}")
    include("${TIDY_DEPS_CMAKE}")
  endif()

  # Stamp directory
  set(STAMPS_DIR "${CMAKE_BINARY_DIR}/stamps/tidy/${TARGET_NAME}")
  file(MAKE_DIRECTORY "${STAMPS_DIR}")

  # Phase 3: Add the tidy target
  set(STAMP_FILES "")
  list(LENGTH ABS_FILES NUM_FILES)
  if(NUM_FILES GREATER 0)
    math(EXPR LAST_INDEX "${NUM_FILES} - 1")
    foreach(INDEX RANGE ${LAST_INDEX})
      list(GET ABS_FILES ${INDEX} ABS_FILE)
      list(GET REL_FILES ${INDEX} REL_FILE)

      # Stamp filename is the flat path of the given file
      string(REPLACE "/" "_" FLAT_PATH "${REL_FILE}")
      set(STAMP "${STAMPS_DIR}/${FLAT_PATH}.stamp")

      # Sanitize the file path for CMake var
      _mystic_sanitize_path(FILE_HASH ${ABS_FILE})
      set(DEP_VAR "TIDY_DEPS_${FILE_HASH}")

      # Target file
      set(TARGET_FILE_NAME "$<TARGET_FILE:${TARGET_NAME}>")

      # Per-file Deps
      set(EXTRA_DEPS "")
      if(DEFINED ${DEP_VAR} AND NOT "${${DEP_VAR}}" STREQUAL "")
        set(EXTRA_DEPS ${${DEP_VAR}})
      else()
        # If fine-grained deps are not available then fallback to coarse target-level dep
        set(EXTRA_DEPS ${TARGET_FILE_NAME})
      endif()

      # Tidy command
      add_custom_command(
        OUTPUT ${STAMP}
        COMMAND ${CLANG_TIDY_EXE} -p ${CMAKE_BINARY_DIR} ${ABS_FILE} ${TIDY_ARGS}
        COMMAND ${CMAKE_COMMAND} -E touch ${STAMP}
        # It depends on:
        # ABS_FILE: The file itself.
        # TIDY_DEPS_CMAKE: The CMake file laying out dependencies
        # EXTRA_DEPS: If any dependency of this file changes it should propagate.
        # TARGET_NAME: The target itself (so, its BMIs are built correctlt).
        DEPENDS ${ABS_FILE} ${TIDY_DEPS_CMAKE} ${EXTRA_DEPS} ${TARGET_NAME}
        COMMENT "Running clang-tidy on ${ABS_FILE} for target: ${TARGET_NAME}"
        VERBATIM
      )

      # Append the stamp to the list of stamp files
      list(APPEND STAMP_FILES ${STAMP})
    endforeach()
  endif()

  # Add a custom target for linting the specific target
  add_custom_target("lint_${TARGET_NAME}"
    DEPENDS ${STAMP_FILES}
    COMMENT "Linting target: ${TARGET_NAME}"
  )
  # Add scanning as a dependency of the lint target
  add_dependencies("lint_${TARGET_NAME}" "scan_deps_${TARGET_NAME}")

  # Add a global lint target if it doesn't exist
  if(NOT TARGET lint)
    add_custom_target(lint)
  endif()

  # Add the target-specific lint target as a dependency of the global lint target
  add_dependencies(lint "lint_${TARGET_NAME}")

  # Full unconditional re-lint
  add_custom_target("lint_full_${TARGET_NAME}"
    COMMAND ${CMAKE_COMMAND} -E remove -f ${STAMP_FILES}
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target "lint_${TARGET_NAME}"
    COMMENT "Full linting target: ${TARGET_NAME}"
    VERBATIM
  )
  add_dependencies("lint_full_${TARGET_NAME}" ${TARGET_NAME})

  # Add a global full lint target if it doesn't exist
  if(NOT TARGET lint_full)
    add_custom_target(lint_full)
  endif()

  # Add the target-specific full lint target as a dependency of the global full lint target
  add_dependencies(lint_full "lint_full_${TARGET_NAME}")
endfunction()

# _mystic_lint_impl
function(_mystic_lint_impl TARGET_NAME FORMAT_ARGS TIDY_ARGS DISABLE_FORMAT DISABLE_TIDY)
  # Guard against invalid targets
  if(NOT TARGET "${TARGET_NAME}")
    mystic_message(FATAL_ERROR "'${TARGET_NAME}' provided in 'mystic_lint' is not a valid CMake target.")
  endif()

  if (NOT CLANG_FORMAT_EXE AND NOT CLANG_TIDY_EXE)
    mystic_message(WARNING "Neither clang-format nor clang-tidy found. Skipping lint setup for target: ${TARGET_NAME}.")
    return()
  endif()

  if(DISABLE_FORMAT AND DISABLE_TIDY)
    mystic_message(STATUS "Both format and tidy are disabled for target: ${TARGET_NAME}. No linting will be performed.")
    return()
  endif()

  if(CLANG_FORMAT_EXE)
    if(NOT DISABLE_FORMAT)
      _mystic_create_format_target("${TARGET_NAME}" "${FORMAT_ARGS}")
    else()
      mystic_message(STATUS "Formatting is disabled for target: ${TARGET_NAME}. Skipping format target creation.")
    endif()
  endif()

  if(CLANG_TIDY_EXE)
    if(NOT DISABLE_TIDY)
      _mystic_create_lint_target("${TARGET_NAME}" "${TIDY_ARGS}")
    else()
      mystic_message(STATUS "Linting is disabled for target: ${TARGET_NAME}. Skipping lint target creation.")
    endif()
  endif()
endfunction()

# --------------------------------------------------------------------------------------------------
# Function: mystic_lint
# Description: This function sets up linting for the specified target. It checks for the presence
# of clang-format and clang-tidy, and creates custom targets for formatting and linting.
# Args:
#   ...: List of target names to enable linting for.
# --------------------------------------------------------------------------------------------------
function(mystic_lint)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_lint'.")
  endif()

  # If linting is disabled, return early
  if(NOT ${PROJECT_PREFIX}_ENABLE_LINT)
    return()
  endif()

  # Guard against empty argument list
  if(NOT ARGN)
    mystic_message(FATAL_ERROR "mystic_lint requires at least one target name.")
  endif()

  set(options "DISABLE_FORMAT" "DISABLE_TIDY")
  set(oneValueArgs "FORMAT_ARGS" "TIDY_ARGS")
  set(multiValueArgs "")

  cmake_parse_arguments(
    ARG
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
  )

  if(ARG_UNPARSED_ARGUMENTS)
    mystic_message(FATAL_ERROR "mystic_lint received unknown arguments: ${ARG_UNPARSED_ARGUMENTS}")

  # Set default values for optional arguments if not provided
  if(NOT ARG_FORMAT_ARGS)
    set(ARG_FORMAT_ARGS "-i --style=file")
  endif()
  if(NOT ARG_TIDY_ARGS)
    set(ARG_TIDY_ARGS "--fix")
  endif()

  # Find the required binaries for linting
  _mystic_find_lint_binaries()

  # Iterate over each target provided in the arguments
  foreach(target IN LISTS ARGN)
    _mystic_lint_impl(${target} "${ARG_FORMAT_ARGS}" "${ARG_TIDY_ARGS}" "${ARG_DISABLE_FORMAT}" "${ARG_DISABLE_TIDY}")
  endforeach()
endfunction()
