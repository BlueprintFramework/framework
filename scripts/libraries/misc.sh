#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.


dbAdd() {
  echo "* ${1};" >> .blueprint/extensions/blueprint/private/db/database;
}
dbValidate() {
  grep -Fxq "* ${1};" .blueprint/extensions/blueprint/private/db/database > /dev/null;
}
dbRemove() {
  sed -i "s/* ${1};//g" .blueprint/extensions/blueprint/private/db/database > /dev/null;
}


shiftArgs() {
  shift 1
  args=""
  for arg in "$@"; do
    args+="$arg "
  done
  echo "$args"
}


unsetVariables() {
  patterns=("^conf_" "^old_" "^Console_" "^OldConsole_" "^Components_" "^OldComponents_" "^F_")
  for pattern in "${patterns[@]}"; do
    for var in $(compgen -v | grep "$pattern"); do
      unset "$var"
    done
  done
}


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


php_escape_string() {
  local string="$1"

  # Escape ampersands.
  string="${string//&/\\\\&}"

  # Escape double quotes.
  string="${string//\"/\\\\\\\\\\\"}"

  echo "$string"
}