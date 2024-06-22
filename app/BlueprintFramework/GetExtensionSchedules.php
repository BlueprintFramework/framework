<?php

namespace Pterodactyl\BlueprintFramework;

use Illuminate\Console\Scheduling\Schedule;
use File;

class GetExtensionSchedules {
  public static function schedules(Schedule $schedule) {
    foreach (File::allFiles(app_path('BlueprintFramework/Schedules/')) as $file) {
      if ($file->getExtension() == 'php') {
        require $file->getPathname();
      }
    }
  }
};
