#!/bin/bash

Command() {
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  PRINT INPUT "You are about to wipe all of your development files, are you sure you want to continue? This cannot be undone. (y/N)"
  read -r YN
  if [[ ( ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ) || ( ( ${YN} == "" ) ) ]]; then PRINT INFO "Development files removal cancelled.";exit 1;fi

  PRINT INFO "Clearing development folder.."
  rm -R \
    .blueprint/dev/* \
    .blueprint/dev/.* \
    2>> "$BLUEPRINT__DEBUG"

  PRINT SUCCESS "Development folder has been cleared."
}