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
# File: MysticAsciiBanner.cmake
# Description: This CMake module provides a function to display an ASCII banner in the console
# output during the build process. It can be used to add a visual touch to your CMake build scripts.
# Author: thedevmystic (Surya) <thedevmystic@gmail.com>
# License: Apache License 2.0
# --------------------------------------------------------------------------------------------------
# Usage:
# # Include this module in your CMakeLists.txt file:
# include(MysticAsciiBanner)
# # # Call the function to display the banner:
# mystic_ascii_banner("Welcome to Mystic Framework")
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------
# ASCII art letters
# -------------------------------------------------------------------------------------------------
list(APPEND _MYSTIC_ASCII_FONT_A " █████╗ " "██╔══██╗" "███████║" "██╔══██║" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_B "██████╗ " "██╔══██╗" "██████╔╝" "██╔══██╗" "██████╔╝" "╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_C " ██████╗" "██╔════╝" "██║     " "██║     " "╚██████╗" " ╚═════╝")
list(APPEND _MYSTIC_ASCII_FONT_D "██████╗ " "██╔══██╗" "██║  ██║" "██║  ██║" "██████╔╝" "╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_E "███████╗" "██╔════╝" "█████╗  " "██╔══╝  " "███████╗" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_F "███████╗" "██╔════╝" "█████╗  " "██╔══╝  " "██║     " "╚═╝     ")
list(APPEND _MYSTIC_ASCII_FONT_G " ██████╗ " "██╔════╝ " "██║  ███╗" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_H "██╗  ██╗" "██║  ██║" "███████║" "██╔══██║" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_I "██╗" "██║" "██║" "██║" "██║" "╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_J "     ██╗" "     ██║" "     ██║" "██   ██║" "╚█████╔╝" " ╚════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_K "██╗  ██╗" "██║ ██╔╝" "█████═╝ " "██╔═██╗ " "██║  ██╗" "╚═╝  ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_L "██╗     " "██║     " "██║     " "██║     " "███████╗" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_M "███╗   ███╗" "████╗ ████║" "██╔████╔██║" "██║╚██╔╝██║" "██║ ╚═╝ ██║" "╚═╝     ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_N "███╗   ██╗" "████╗  ██║" "██╔██╗ ██║" "██║╚██╗██║" "██║ ╚████║" "╚═╝  ╚═══╝")
list(APPEND _MYSTIC_ASCII_FONT_O " ██████╗ " "██╔═══██╗" "██║   ██║" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_P "██████╗ " "██╔══██╗" "██████╔╝" "██╔═══╝ " "██║     " "╚═╝     ")
list(APPEND _MYSTIC_ASCII_FONT_Q " ██████╗ " "██╔═══██╗" "██║   ██║" "██║▄▄ ██║" "╚██████╔╝" " ╚══▀▀═╝ ")
list(APPEND _MYSTIC_ASCII_FONT_R "██████╗ " "██╔══██╗" "██████╔╝" "██╔══██╗" "██║  ██║" "╚═╝  ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_S "███████╗" "██╔════╝" "███████╗" "╚════██║" "███████║" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_T "████████╗" "╚══██╔══╝" "   ██║   " "   ██║   " "   ██║   " "   ╚═╝   ")
list(APPEND _MYSTIC_ASCII_FONT_U "██╗   ██╗" "██║   ██║" "██║   ██║" "██║   ██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_V "██╗   ██╗" "██║   ██║" "██║   ██║" "╚██╗ ██╔╝" " ╚████╔╝ " "  ╚═══╝  ")
list(APPEND _MYSTIC_ASCII_FONT_W "██╗    ██╗" "██║    ██║" "██║ █╗ ██║" "██║███╗██║" "╚███╔███╔╝" " ╚══╝╚══╝ ")
list(APPEND _MYSTIC_ASCII_FONT_X "██╗  ██╗" "╚██╗██╔╝" " ╚███╔╝ " " ██╔██╗ " "██╔╝ ██╗" "╚═╝  ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_Y "██╗   ██╗" "╚██╗ ██╔╝" " ╚████╔╝ " "  ╚██╔╝  " "   ██║   " "   ╚═╝   ")
list(APPEND _MYSTIC_ASCII_FONT_Z "███████╗" "╚══███╔╝" "  ███╔╝ " " ███╔╝  " "███████╗" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_0 " ██████╗ " "██╔═████╗" "██║██╔██║" "████╔╝██║" "╚██████╔╝" " ╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_1 " ██╗" "███║" "╚██║" " ██║" " ██║" " ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_2 "██████╗ " "╚════██╗" " █████╔╝" "██╔═══╝ " "███████╗" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_3 "██████╗ " "╚════██╗" " █████╔╝" " ╚═══██╗" "██████╔╝" "╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_4 "██╗  ██╗" "██║  ██║" "███████║" "╚════██║" "     ██║" "     ╚═╝")
list(APPEND _MYSTIC_ASCII_FONT_5 "███████╗" "██╔════╝" "███████╗" "╚════██║" "███████║" "╚══════╝")
list(APPEND _MYSTIC_ASCII_FONT_6 " ██████╗" "██╔════╝" "███████╗" "██╔═══██╗" "╚██████╔╝" " ╚═════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_7 "███████╗" "╚════██║" "    ██╔╝" "  ██╔╝ " "  ██║  " "  ╚═╝  ")
list(APPEND _MYSTIC_ASCII_FONT_8 " █████╗ " "██╔══██╗" "╚█████╔╝" "██╔══██╗" "╚█████╔╝" " ╚════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_9 " █████╗ " "██╔══██╗" "╚██████║" " ╚═══██║" " █████╔╝" " ╚════╝ ")
list(APPEND _MYSTIC_ASCII_FONT_COLON "     " " ██╗ " " ╚═╝ " " ██╗ " " ╚═╝ " "     ")

# -------------------------------------------------------------------------------------------------
# Color gradient definitions for ASCII art output
# -------------------------------------------------------------------------------------------------
string(ASCII 27 ESC)
set(_MYSTIC_COLOR_RESET   "${ESC}[0m")
set(_MYSTIC_COLOR_0 "${ESC}[38;5;196m") # Vivid Red
set(_MYSTIC_COLOR_1 "${ESC}[38;5;202m") # Orange-Red
set(_MYSTIC_COLOR_2 "${ESC}[38;5;208m") # Dark Orange
set(_MYSTIC_COLOR_3 "${ESC}[38;5;214m") # Orange-Yellow
set(_MYSTIC_COLOR_4 "${ESC}[38;5;220m") # Yellow
set(_MYSTIC_COLOR_5 "${ESC}[38;5;226m") # Bright Yellow

# -------------------------------------------------------------------------------------------------
# Desc: Function to generate ASCII art for a given input string.
# Note: This supports A-Z, 0-9, colon, and space characters.
# Args:
#   INPUT_STRING: The string to be converted into ASCII art.
# -------------------------------------------------------------------------------------------------
function(mystic_ascii_banner INPUT_STRING)
  # When the MYSTIC_ASCII_BANNER_DISABLE variable is set to TRUE, the function will not
  # output any banner.
  if(MYSTIC_ASCII_BANNER_DISABLE)
    return()
  endif()

  # Split space-separated input string into individual word tokens
  string(REPLACE " " ";" WORDS "${INPUT_STRING}")

  # Output each word in ASCII art format
  foreach(WORD IN LISTS WORDS)
    string(TOUPPER "${WORD}" WORD_UPPER)
    string(LENGTH "${WORD_UPPER}" WORD_LEN)
    
    if(WORD_LEN EQUAL 0)
      continue()
    endif()

    set(LINE_0 "")
    set(LINE_1 "")
    set(LINE_2 "")
    set(LINE_3 "")
    set(LINE_4 "")
    set(LINE_5 "")

    math(EXPR MAX_IDX "${WORD_LEN} - 1")
    foreach(I RANGE ${MAX_IDX})
      string(SUBSTRING "${WORD_UPPER}" ${I} 1 CHAR)

      # Map colon correctly
      if(CHAR STREQUAL ":")
        set(CHAR "COLON")
      endif()
      
      if(DEFINED _MYSTIC_ASCII_FONT_${CHAR})
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 0 C0)
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 1 C1)
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 2 C2)
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 3 C3)
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 4 C4)
        list(GET _MYSTIC_ASCII_FONT_${CHAR} 5 C5)

        string(APPEND LINE_0 "${C0} ")
        string(APPEND LINE_1 "${C1} ")
        string(APPEND LINE_2 "${C2} ")
        string(APPEND LINE_3 "${C3} ")
        string(APPEND LINE_4 "${C4} ")
        string(APPEND LINE_5 "${C5} ")
      endif()
    endforeach()

    # Output the word block
    message(NOTICE "${_MYSTIC_COLOR_0}${LINE_0}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "${_MYSTIC_COLOR_1}${LINE_1}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "${_MYSTIC_COLOR_2}${LINE_2}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "${_MYSTIC_COLOR_3}${LINE_3}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "${_MYSTIC_COLOR_4}${LINE_4}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "${_MYSTIC_COLOR_5}${LINE_5}${_MYSTIC_COLOR_RESET}")
    message(NOTICE "") # Line break between words
  endforeach()
endfunction()
