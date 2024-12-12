#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

ConfigUtility() {
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