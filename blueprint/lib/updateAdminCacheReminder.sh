#!/bin/bash

updateCacheReminder() {
  cd &bp.folder&
  # Overwrite previous adminCacheReminderHider with the default one.
  oldClassName=$(cat .blueprint/data/internal/db/randomclassname);
  newClassName=$RANDOM;
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" public/assets/extensions/blueprint/blueprint.style.css;
  sed -i "s~cacheOverlay-$oldClassName~cacheOverlay-$newClassName~g" resources/views/layouts/admin.blade.php;
  echo "$newClassName" > .blueprint/data/internal/db/randomclassname;
}