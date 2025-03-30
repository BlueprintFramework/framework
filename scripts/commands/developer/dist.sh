#!/bin/bash

Command() {
  if ! is_developer; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  PRINT INFO "Cleaning up .dist files.."
  rm -f -r \
    .blueprint/dev/.dist/* \
    .blueprint/dist/types/*

  # Initialize dist directory.
  PRINT INFO "Initializing .dist directory.."
  mkdir -p .blueprint/dev/.dist
  ln -s -r .blueprint/dist/types .blueprint/dev/.dist/types

  # Initialize types.
  PRINT INFO "Generating types.."
  node scripts/helpers/generate-types.js 2> /dev/null

  
  PRINT SUCCESS "Finished regenerating dist files."
}