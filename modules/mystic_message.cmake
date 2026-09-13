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
# File: mystic_message.cmake
# Description: This CMake module is used to wrap the `message()` function to provide additional
# functionality and customization options for displaying messages during the configuration process.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file
# include(mystic_message)
# # Drop-in replacement for the `message()` function with additional features
# mystic_message(STATUS "This is a status message.")
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# Function: mystic_message
# Description: This function wraps around CMake's `message()` command to provide additional control
# options for displaying messages during the configuration process.
# Arguments:
#   LEVEL: The message level (e.g., STATUS, WARNING, FATAL_ERROR).
#   MESSAGE: The message to display.
# --------------------------------------------------------------------------------------------------
function(mystic_message LEVEL MESSAGE)
  # MODE 1: Disabled
  if(MYSTIC_MESSAGE_DISABLE)
    return()
  endif()

  # Prefix the message with a custom tag for better visibility
  if(MYSTIC_MESSAGE_CUSTOM_PREFIX)
    set(MESSAGE "${MYSTIC_MESSAGE_CUSTOM_PREFIX} - ${MESSAGE}")
  else()
    set(MESSAGE "[MYSTIC] - ${MESSAGE}")
  endif()

  # MODE 2: Only Errors
  if(MYSTIC_MESSAGE_ONLY_ERRORS)
    if(LEVEL STREQUAL "FATAL_ERROR" OR LEVEL STREQUAL "SEND_ERROR")
      message(${LEVEL} "${MESSAGE}" "${ARGN}")
    endif()
    return()
  endif()

  # MODE 3: Normal
  message(${LEVEL} "${MESSAGE}" "${ARGN}")
endfunction()
