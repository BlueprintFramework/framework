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

  export PROGRESS_TOTAL=5
  export PROGRESS_NOW=0

  PRINT INFO "Setting environment variables.."
  export IgnoreRebuild=true
  export DeveloperWatch=true

  ((PROGRESS_NOW++))

  PRINT INFO "Searching and validating framework dependencies.."
  # Check if required programs and libraries are installed.
  depend

  ((PROGRESS_NOW++))

  PRINT INFO "Reading extension configuration.."
  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/dev/conf.yml" ]]; then
    # Quit if the extension doesn't have a conf.yml file.
    PRINT FATAL "Extension configuration file not found or detected."
    hide_progress
    return 1
  fi
  eval "$(parse_yaml .blueprint/dev/conf.yml conf_)"

  ((PROGRESS_NOW++))

  PRINT INFO "Flushing view, config and route cache.."
  {
    php artisan view:clear
    php artisan config:clear
    php artisan route:clear
    php artisan cache:clear
    php artisan bp:cache
  } &>> "$BLUEPRINT__DEBUG"

  ((PROGRESS_NOW++))

  # Make sure all files have correct permissions.
  PRINT INFO "Changing Pterodactyl file ownership to '$OWNERSHIP'.."
  find "$FOLDER/" \
    -path "$FOLDER/node_modules" -prune \
    -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"
  
  ((PROGRESS_NOW++))

  PRINT INFO "Finishing up.."
  hide_progress
  export PROGRESS_TOTAL=''
  export PROGRESS_NOW=''

  # Start yarn watch in background
  if [[ $conf_dashboard_components != "" ]] \
  || [[ $conf_dashboard_css != "" ]]; then
    yarn watch &
    YARN_PID=$!
  fi

  # shellcheck disable=SC2317
  cleanup() {
    PRINT FATAL "Process has been exited.. cleaning up"
    if [[ $YARN_PID != "" ]]; then
      kill "$YARN_PID" 2> /dev/null
    fi
    exit
  }
  trap cleanup SIGINT SIGTERM

  PRINT INFO "Watching extension files.."

  last_hash=$(get_hash)
  while inotifywait -q -r -e modify,create,delete,move .blueprint/dev; do
    current_hash=$(get_hash)
    if [ "$last_hash" == "$current_hash" ]; then continue; fi
    blueprint -add "[developer-build]"

    last_hash=$current_hash
  done
}