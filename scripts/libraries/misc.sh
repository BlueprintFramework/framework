#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.


# (will remove these in the future) Functions to have a 'database' in bash
FLDR=".blueprint/extensions/blueprint/private/db/database"
# dbAdd "database.record"
dbAdd() { echo "* ${1};" >> $FLDR; }
# dbValidate "database.record"
dbValidate() { grep -Fxq "* ${1};" $FLDR > /dev/null; }
# dbRemove "database.record"
dbRemove() { sed -i "s/* ${1};//g" $FLDR > /dev/null; }


# Function to shift arguments
shiftArgs() {
  shift 1
  args=""
  for arg in "$@"; do
    args+="$arg "
  done
  echo "$args"
}


# Function to unset a bunch of variables
unsetVariables() {
  patterns=("^conf_" "^old_" "^Console_" "^OldConsole_" "^Components_" "^OldComponents_" "^F_")
  for pattern in "${patterns[@]}"; do
    for var in $(compgen -v | grep "$pattern"); do
      unset "$var"
    done
  done
}


# Function to fetch developer status
is_developer() {
  if [[ $is_developer != "" ]]; then
    return "$is_developer"
  fi
  if [[ $(php artisan bp:developer) == "true"* ]]; then
    export is_developer=0
    return 0
  else
    export is_developer=1
    return 1
  fi
}