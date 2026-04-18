#!/bin/bash

Command() {
  PRINT WARNING "This is an advanced feature, only proceed if you know what you are doing."
  if [ -f "$FOLDER/.blueprint/extensions/blueprint/private/db/is_installed" ]; then
    rm "$FOLDER/.blueprint/extensions/blueprint/private/db/is_installed"
  fi
  cd "${FOLDER}" || cdhalt
  bash blueprint.sh
}
