#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future.

cd "${BLUEPRINT__FOLDER}"

grabPanelUrl() {
  source ${BLUEPRINT__FOLDER}/.env
  echo $APP_URL
}