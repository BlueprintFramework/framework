#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

ConfigUtility() {
  # cTELEMETRY_ID
  # Update the telemetry id.
  if [[ "$cTELEMETRY_ID" != "" ]]; then
    echo "$cTELEMETRY_ID" > .blueprint/extensions/blueprint/private/db/telemetry_id
  fi

  # cDEVELOPER
  # Enable/Disable developer mode.
  if [[ "$cDEVELOPER" != "" ]]; then
    if [[ "$cDEVELOPER" == "true" ]]; then
      dbAdd "blueprint.developerEnabled"
    else
      dbRemove "blueprint.developerEnabled"
    fi
  fi

  echo .
  exit 0
}