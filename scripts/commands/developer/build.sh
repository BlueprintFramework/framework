#!/bin/bash

Command() {
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi
  PRINT INFO "Starting developer extension installation.."
  blueprint -add "[developer-build]"
}