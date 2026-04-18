#!/bin/bash

Command() {
  lock_remove
  if [ ! -f ".blueprint/lock" ]; then
    PRINT SUCCESS "Lock has been removed"
    exit 0
  else
    PRINT FATAL "Lock couldn't be removed"
    exit 1
  fi
}
