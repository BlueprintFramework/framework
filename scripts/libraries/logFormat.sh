#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

PRINT() {
  local DATE=$(date +"%H:%M:%S")
  local DATEDEBUG=$(date +"%Y-%m-%d %H:%M:%S")
  local TYPE="$1"
  local MESSAGE="$2"

  local BOLD=$(tput bold)
  local RESET=$(tput sgr0)
  local SECONDARY="\033[2m"

  if [[ $TYPE == "INFO"    ]]; then local ICON="󰋼"; local READABLETYPE="Info"; local PRIMARY=$(tput setaf 4); fi
  if [[ $TYPE == "WARNING" ]]; then local ICON=""; local READABLETYPE="Warning"; local PRIMARY=$(tput setaf 3); fi
  if [[ $TYPE == "FATAL"   ]]; then local ICON="󰅙"; local READABLETYPE="Fatal"; local PRIMARY=$(tput setaf 1); fi
  if [[ $TYPE == "SUCCESS" ]]; then local ICON="󰗠"; local READABLETYPE="Success"; local PRIMARY=$(tput setaf 2); fi
  if [[ $TYPE == "INPUT"   ]]; then local ICON="󰋗"; local READABLETYPE="Input"; local PRIMARY=$(tput setaf 5); fi
  if [[ $TYPE == "DEBUG"   ]]; then local PRIMARY="$SECONDARY"; fi

  if [[ $TYPE != "DEBUG" ]]; then echo -e "${SECONDARY}${DATE}${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE${RESET}"; fi
  echo -e "${BOLD}${SECONDARY}$DATEDEBUG${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE" >> "$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
}
