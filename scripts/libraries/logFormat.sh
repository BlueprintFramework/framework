#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

export PROGRESS_THEME_PRIMARY="\x1b[34;1m"
export PROGRESS_THEME_SECONDARY="\033[0;2m"

# Move cursor up one line
cursor_up() {
  echo -en "\033[1A"
}

# Clear from cursor to end of line
clear_line() {
  echo -en "\033[K"
}

# Move cursor to start of line
cursor_start() {
  echo -en "\r"
}

# Hide progress bar
hide_progress() {
  if [[ -n "${PROGRESS_TOTAL}" && -n "${PROGRESS_NOW}" ]]; then
    echo -e ""
    cursor_up
    clear_line
    cursor_start
  fi
}

# Draw progress bar
draw_progress() {
  # Calculate available width for the progress bar
  local term_width
  term_width=$(tput cols)
  # Account for the percentage text (e.g., " 100%" = 5 characters)
  local width=$((term_width - 5))  # Width of the progress bar
  local progress=$1
  local total=$2
  local percentage=$((progress * 100 / total))
  local filled=$((width * progress / total))
  local empty=$((width - filled))

  # Create the filled and empty parts of the bar
  local bar="$PROGRESS_THEME_PRIMARY"
  for ((i = 0; i < filled; i++)); do
    bar+="─"
  done
  bar+="$PROGRESS_THEME_SECONDARY"
  for ((i = 0; i < empty; i++)); do
    bar+="─"
  done

  # Clear the line and draw the progress bar
  cursor_start
  clear_line
  echo -n -e "${bar} ${percentage}%\x1b[0m"
}

PRINT() {
  local DATE=""; DATE="$(date +"%H:%M:%S")"
  local DATEDEBUG=""; DATEDEBUG="$(date +"%Y-%m-%d %H:%M:%S")"
  local TYPE="$1"
  local MESSAGE="$2"
  local BOLD=""; BOLD="$(tput bold)"
  local RESET=""; RESET="$(tput sgr0)"
  local SECONDARY="\033[2m"
  local PRIMARY=""

  if [[ $TYPE == "INFO" ]]; then local ICON="󰋼"; local READABLETYPE="Info"; PRIMARY=$(tput setaf 4); fi
  if [[ $TYPE == "WARNING" ]]; then local ICON=""; local READABLETYPE="Warning"; PRIMARY=$(tput setaf 3); fi
  if [[ $TYPE == "FATAL" ]]; then local ICON="󰅙"; local READABLETYPE="Fatal"; PRIMARY=$(tput setaf 1); fi
  if [[ $TYPE == "SUCCESS" ]]; then local ICON="󰗠"; local READABLETYPE="Success"; PRIMARY=$(tput setaf 2); fi
  if [[ $TYPE == "INPUT" ]]; then local ICON="󰋗"; local READABLETYPE="Input"; PRIMARY=$(tput setaf 5); fi
  if [[ $TYPE == "DEBUG" ]]; then local PRIMARY="$SECONDARY"; fi

  # If progress bar is visible, handle its clearing
  if [[ -n "${PROGRESS_TOTAL}" && -n "${PROGRESS_NOW}" ]]; then
    # Print a newline first to ensure proper scrolling
    echo -e "\n"

    # Move up to the newly created line and clear the previous progress bar
    cursor_up
    cursor_up
    clear_line
    cursor_start
    # Create a blank line as wide as the terminal
    printf "%*s\n" "$(tput cols)" ""
    cursor_up
    clear_line
  fi

  if [[ $TYPE != "DEBUG" ]]; then
    echo -e "${SECONDARY}${DATE}${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE${RESET}"
  fi

  if [[ -d "$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt ]]; then
    echo -e "${BOLD}${SECONDARY}$DATEDEBUG${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE" >> "$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
  fi

  # If progress variables exist, draw progress bar
  if [[ -n "${PROGRESS_TOTAL}" && -n "${PROGRESS_NOW}" ]]; then
    draw_progress "${PROGRESS_NOW}" "${PROGRESS_TOTAL}"
  fi
}
