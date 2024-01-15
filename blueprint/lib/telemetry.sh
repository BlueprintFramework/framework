#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

sendTelemetry() {
  cd "${BLUEPRINT__FOLDER}" || exit
  key=$(cat .blueprint/extensions/blueprint/private/db/telemetry_id)
  if [[ $key == "KEY_NOT_UPDATED" ]]; then 
    exit 1
  fi
  curl --location --silent "http://api.blueprint.zip:50000/send/$key/$1" > /dev/null
}
