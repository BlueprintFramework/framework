#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.


# === DATABASE ===
FLDR=".blueprint/extensions/blueprint/private/db/database"
# dbAdd "database.record"
dbAdd() { echo "* ${1};" >> $FLDR; }
# dbValidate "database.record"
dbValidate() { grep -Fxq "* ${1};" $FLDR > /dev/null; }
# dbRemove "database.record"
dbRemove() { sed -i "s/* ${1};//g" $FLDR > /dev/null; }


# === TELEMETRY ===
sendTelemetry() {
  cd "${BLUEPRINT__FOLDER}" || return
  key=$(cat .blueprint/extensions/blueprint/private/db/telemetry_id)
  if [[ $key == "KEY_NOT_UPDATED" ]]; then 
    return 0
  fi
  curl --location --silent --connect-timeout 3 "http://api.blueprint.zip:50000/send/$key/$1" &
}


# === SHIFTARGS ===
shiftArgs() {
  shift 1
  args=""
  for arg in "$@"; do
    args+="$arg "
  done
  echo "$args"
}


# === UNSETVARS ===
unsetVariables() {
  patterns=("^conf_" "^old_" "^Console_" "^OldConsole_" "^Components_" "^OldComponents_" "^F_")
  for pattern in "${patterns[@]}"; do
    for var in $(compgen -v | grep "$pattern"); do
      unset "$var"
    done
  done
}