#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

PRINT() {
  DATE=$(date +"%H:%M:%S")
  DATEDEBUG=$(date +"%Y-%m-%d %H:%M:%S")
  TYPE="$1"
  MESSAGE="$2"

  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  SECONDARY="\033[2m"

  if [[ $TYPE == "INFO"    ]]; then ICON="󰋼"; READABLETYPE="Info"; PRIMARY=$(tput setaf 4); fi
  if [[ $TYPE == "WARNING" ]]; then ICON=""; READABLETYPE="Warning"; PRIMARY=$(tput setaf 3); fi
  if [[ $TYPE == "FATAL"   ]]; then ICON="󰅙"; READABLETYPE="Fatal"; PRIMARY=$(tput setaf 1); fi
  if [[ $TYPE == "SUCCESS" ]]; then ICON="󰗠"; READABLETYPE="Success"; PRIMARY=$(tput setaf 2); fi
  if [[ $TYPE == "INPUT"   ]]; then ICON="󰋗"; READABLETYPE="Input"; PRIMARY=$(tput setaf 5); fi
  if [[ $TYPE == "DEBUG"   ]]; then PRIMARY="$SECONDARY"; fi

  if [[ $TYPE != "DEBUG" ]]; then echo -e "${SECONDARY}${DATE}${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE${RESET}"; fi
  echo -e "${BOLD}${SECONDARY}$DATEDEBUG${RESET} ${PRIMARY}${TYPE}:${RESET} $MESSAGE" >> "$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
}