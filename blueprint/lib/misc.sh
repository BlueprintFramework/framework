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
  cd "${BLUEPRINT__FOLDER}" || exit
  key=$(cat .blueprint/extensions/blueprint/private/db/telemetry_id)
  if [[ $key == "KEY_NOT_UPDATED" ]]; then 
    exit 1
  fi
  curl --location --silent --connect-timeout 3 "http://api.blueprint.zip:50000/send/$key/$1" &
}


# === CACHEREMINDER ===
updateCacheReminder() {
  cd "${BLUEPRINT__FOLDER}" || exit
  # Overwrite previous adminCacheReminderHider with the default one.
  oldClassName=$(cat .blueprint/extensions/blueprint/private/db/randomclassname)
  newClassName=$RANDOM$RANDOM$RANDOM$RANDOM
  mv .blueprint/extensions/blueprint/assets/misc/cacheOverlay-"${oldClassName}".css .blueprint/extensions/blueprint/assets/misc/cacheOverlay-"${newClassName}".css
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" .blueprint/extensions/blueprint/assets/blueprint.style.css
  sed -i "s~I0TWHOPKAB-$oldClassName~I0TWHOPKAB-$newClassName~g" resources/views/blueprint/admin/admin.blade.php
  sed -i "s~I0TWHOPKAB-$oldClassName~I0TWHOPKAB-$newClassName~g" .blueprint/extensions/blueprint/assets/misc/cacheOverlay-"${newClassName}".css
  echo "$newClassName" > .blueprint/extensions/blueprint/private/db/randomclassname
}