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

  PRINT INFO "Setting up development environment.."
  export IgnoreRebuild=true
  export DeveloperWatch=true

  # Check if required programs and libraries are installed.
  depend

  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/dev/conf.yml" ]]; then
    # Quit if the extension doesn't have a conf.yml file.
    PRINT FATAL "Extension configuration file not found or detected."
    hide_progress
    return 1
  fi
  eval "$(parse_yaml .blueprint/dev/conf.yml conf_)"

  {
    php artisan view:clear
    php artisan config:clear
    php artisan route:clear
    php artisan cache:clear
    php artisan bp:cache
  } &>> "$BLUEPRINT__DEBUG"

  # Make sure all files have correct permissions.
  find "$FOLDER/" \
    -path "$FOLDER/node_modules" -prune \
    -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"

  # Start yarn watch in background
  if [[ $conf_dashboard_components != "" ]] \
  || [[ $conf_dashboard_css != "" ]]; then
    echo "**/*" > "$FOLDER/.prettierignore"
    yarn watch &
    YARN_PID=$!
  fi

  # shellcheck disable=SC2329
  cleanup() {
    PRINT FATAL "Process has been exited.. cleaning up"

    echo "#" > "$FOLDER/.prettierignore"

    if [[ $conf_dashboard_components != "" ]]; then
      # Remove types
      rm "$FOLDER/.blueprint/dev/.dist"
    fi

    if [[ $YARN_PID != "" ]]; then
      kill "$YARN_PID" 2> /dev/null
    fi
    exit
  }
  trap cleanup SIGINT SIGTERM

  PRINT INFO "Watching extension files.."

  last_hash=$(get_hash)
  should_rebuild=false
  rebuild_timer=0

  while true; do
    if inotifywait -q -t 1 -r -e modify,create,delete,move .blueprint/dev; then
      current_time=$(date +%s)
      should_rebuild=true
      rebuild_timer=$((current_time + 1)) # Add 1-second debounce timer.
    fi

    current_time=$(date +%s)
    if [[ ( $should_rebuild == true ) && ( $current_time -ge $rebuild_timer ) ]]; then
      current_hash=$(get_hash)
      if [ "$last_hash" != "$current_hash" ]; then
        blueprint -add "[developer-build]"
        last_hash=$current_hash
      fi
      should_rebuild=false
    fi
  done
}
