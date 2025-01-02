#!/bin/bash

get_hash() {
  find ".blueprint/dev" -type f -exec md5sum {} \; | sort | md5sum
}

Command() {
  if ! is_developer; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi
  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  if [[ -f ".blueprint/dev/.gitkeep" ]]; then
    rm .blueprint/dev/.gitkeep 2>> "$BLUEPRINT__DEBUG"
  fi

  # Start yarn watch in background, TODO: Check if rebuilding is necessary
  export NODE_OPTIONS=--openssl-legacy-provider
  yarn watch &
  YARN_PID=$!

  cleanup() {
    kill $YARN_PID 2>/dev/null
    exit
  }

  trap cleanup SIGINT SIGTERM

  export IgnoreRebuild=true
  last_hash=$(get_hash)
  PRINT INFO "Watching for changes.."
  while true; do
    sleep 1
    current_hash=$(get_hash)
    if [ "$last_hash" == "$current_hash" ]; then continue; fi
    PRINT INFO "Change detected, rebuilding.."
    sleep 1
    blueprint -add "[developer-build]" > /dev/null
    PRINT INFO "Rebuild complete."

    last_hash=$current_hash
  done
}