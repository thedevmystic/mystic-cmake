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
# File: MysticInstall.cmake
# Description: This CMake module is used to simplify the process of installing files and directories
#              in a CMake project.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticInstall)
# # Then use the provided functions to install files and directories:
# mystic_install(<MAIN_TARGET>)
# --------------------------------------------------------------------------------------------------

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include("${CMAKE_CURRENT_LIST_DIR}/MysticMessage.cmake")

# --------------------------------------------------------------------------------------------------
# Function: mystic_install
# Description: This function installs the specified target and its associated files and directories.
# Args:
#   MAIN_TARGET: The main target to install (e.g., a library or executable).
# --------------------------------------------------------------------------------------------------
function(mystic_install MAIN_TARGET)
  # Get project prefix
  get_property(PROJECT_PREFIX DIRECTORY PROPERTY _MYSTIC_PROJECT_PREFIX)

  if(NOT PROJECT_PREFIX)
    mystic_message(FATAL_ERROR "Project prefix not set. Ensure that 'mystic_project' is called before 'mystic_install'.")
  endif()
  
  # If install is disabled, skip installation
  if(NOT ${PROJECT_PREFIX}_INSTALL)
    return()
  endif()

  # Export targets
  install(TARGETS ${MAIN_TARGET} EXPORT ${${PROJECT_PREFIX}_PROJECT_NAME}Targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET CXX_MODULES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mystic/modules
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/mystic
  )

  # Install target export file
  install(EXPORT ${${PROJECT_PREFIX}_PROJECT_NAME}Targets
    NAMESPACE Mystic::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${${PROJECT_PREFIX}_PROJECT_NAME}
  )

  # Version file
  write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${${PROJECT_PREFIX}_PROJECT_NAME}ConfigVersion.cmake
    VERSION ${${PROJECT_PREFIX}_PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
  )

  # Install CMake configuration files
  configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${${PROJECT_PREFIX}_PROJECT_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${${PROJECT_PREFIX}_PROJECT_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${${PROJECT_PREFIX}_PROJECT_NAME}
  )

  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/${${PROJECT_PREFIX}_PROJECT_NAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${${PROJECT_PREFIX}_PROJECT_NAME}ConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${${PROJECT_PREFIX}_PROJECT_NAME}
  )
endfunction()
