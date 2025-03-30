#!/bin/bash

Command() {
  if ! is_developer; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT WARNING "Development directory is empty."
  fi

  PRINT INPUT "This command will wipe your extension and dist files. This cannot be undone. Continue? (y/N)"
  read -r YN
  if [[ ( ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ) || ( ( ${YN} == "" ) ) ]]; then PRINT INFO "Development files removal cancelled.";exit 1;fi

  PRINT INFO "Clearing development files.."
  rm -f -r \
    .blueprint/dev \
    .blueprint/dist/types/*
  mkdir -p .blueprint/dev

  PRINT SUCCESS "Development files have been cleared."
}