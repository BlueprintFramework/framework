#!/bin/bash

Command() {
  if [ -f "$FOLDER/.blueprint/extensions/blueprint/private/db/is_installed" ]; then
    rm "$FOLDER/.blueprint/extensions/blueprint/private/db/is_installed"
  fi
  cd "${FOLDER}" || cdhalt
  bash blueprint.sh
}
