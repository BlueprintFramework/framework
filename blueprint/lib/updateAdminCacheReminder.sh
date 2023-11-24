#!/bin/bash

updateCacheReminder() {
  cd $BLUEPRINT__FOLDER
  # Overwrite previous adminCacheReminderHider with the default one.
  oldClassName=$(cat .blueprint/extensions/blueprint/private/db/randomclassname)
  newClassName=$RANDOM
  mv .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$oldClassName.css .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$newClassName.css
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" .blueprint/extensions/blueprint/assets/blueprint.style.css
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" resources/views/layouts/admin.blade.php
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" .blueprint/extensions/blueprint/assets/misc/cacheOverlay-$newClassName.css
  echo "$newClassName" > .blueprint/extensions/blueprint/private/db/randomclassname
}

forceDisableCacheReminder() {
  cd $BLUEPRINT__FOLDER
  sed -i 's~ style="z-index:9998;~ style="display:none;z-index:9998;~g' resources/views/layouts/admin.blade.php
}
