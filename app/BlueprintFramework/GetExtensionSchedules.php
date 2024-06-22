<?php

namespace Pterodactyl\BlueprintFramework;

use Illuminate\Console\Scheduling\Schedule;

class GetExtensionSchedules {
  public static function schedules(Schedule $schedule) {
    foreach (app_path('BlueprintFramework/Schedules') as $file) {
      if ($file->getExtension() == 'php') {
        require $file->getPathname();
      }
    }
  }
};
