#!/bin/bash

updateCacheReminder() {
  cd &bp.folder&
  # Overwrite previous adminCacheReminderHider with the default one.
  oldClassName=$(cat .blueprint/data/internal/db/randomclassname);
  newClassName=$RANDOM;
  sed -i "s~$oldClassName~$newClassName~g" public/assets/extensions/blueprint/adminCacheReminderHider.css;
  sed -i "s~$oldClassName~$newClassName~g" resources/layouts/admin.blade.php;
  echo "$newClassName" > .blueprint/data/internal/db/randomclassname;
}