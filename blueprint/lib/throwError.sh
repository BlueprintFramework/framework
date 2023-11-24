#!/bin/bash

source $BLUEPRINT__FOLDER/.blueprint/lib/bash_colors.sh

function throwError {
  if [[ $1 == "cdMissingDirectory" ]]; then err="Tried to navigate to a directory that does not exist, halting process."; fi
  if [[ $1 == "confymlNotFound"    ]]; then err="Could not find a conf.yml file.";                                        fi

  if [[ $err == "" ]]; then err="$1"; fi
  log_red "[FATAL] $err"
  return 1
}