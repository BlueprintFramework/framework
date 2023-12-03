#!/bin/bash

updateCacheReminder() {
  cd $BLUEPRINT__FOLDER
  # Overwrite previous adminCacheReminderHider with the default one.
  oldClassName=$(cat .blueprint/extensions/blueprint/private/db/randomclassname)
  newClassName=$RANDOM
  mv .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$oldClassName.css .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$newClassName.css
  sed -i "s~I0TWHOPKAB-$oldClassName~I0TWHOPKAB-$newClassName~g" .blueprint/extensions/blueprint/assets/blueprint.style.css
  sed -i "s~I0TWHOPKAB-$oldClassName~I0TWHOPKAB-$newClassName~g" resources/views/layouts/admin.blade.php
  sed -i "s~I0TWHOPKAB-$oldClassName~I0TWHOPKAB-$newClassName~g" .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$newClassName.css
  echo "$newClassName" > .blueprint/extensions/blueprint/private/db/randomclassname
}