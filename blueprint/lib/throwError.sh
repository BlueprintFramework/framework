#!/bin/bash

source $BLUEPRINT__FOLDER/.blueprint/lib/bash_colors.sh

function throwFatal {
  if [[ $1 == "cdMissingDirectory" ]]; then err="Tried to navigate to a directory that does not exist, halting process."; fi

  log_red "[FATAL] $err"
  return 1
}