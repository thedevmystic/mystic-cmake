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
# File: private_helpers.cmake
# Description: This file contains general private helpers.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------

# This function converts a variable name to constant case (uppercase with underscores).
function(_mystic_to_constant_case VARIABLE_NAME OUTPUT_VARIABLE)
  string(TOUPPER "${VARIABLE_NAME}" ${OUTPUT_VARIABLE})
  string(REPLACE " " "_" ${OUTPUT_VARIABLE} "${${OUTPUT_VARIABLE}}")
  string(REPLACE "-" "_" ${OUTPUT_VARIABLE} "${${OUTPUT_VARIABLE}}")
  set(${OUTPUT_VARIABLE} "${${OUTPUT_VARIABLE}}" PARENT_SCOPE)
endfunction()

# This function capitalizes the first letter of a variable name.
function(_mystic_capitalize_first_letter VARIABLE_NAME OUTPUT_VARIABLE)
  string(SUBSTRING "${VARIABLE_NAME}" 0 1 FIRST_LETTER)
  string(SUBSTRING "${VARIABLE_NAME}" 1 -1 REMAINDER)
  string(TOUPPER "${FIRST_LETTER}" FIRST_LETTER_UPPER)
  set(${OUTPUT_VARIABLE} "${FIRST_LETTER_UPPER}${REMAINDER}" PARENT_SCOPE)
endfunction()
