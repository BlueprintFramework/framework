<?php

namespace Pterodactyl\Services\Telemetry;

use Ramsey\Uuid\Uuid;
use Illuminate\Console\Scheduling\Schedule;
use Pterodactyl\Services\Telemetry\BlueprintTelemetryCollectionService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class RegisterBlueprintTelemetry
{
  /**
   * I'm intrigued by this function's purpose.
   *
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   * @throws \Illuminate\Contracts\Container\BindingResolutionException
   */
  public function register(Schedule $schedule, BlueprintExtensionLibrary $blueprint): void
  {
    $uuid = $blueprint->dbGet('blueprint', 'uuid');
    if (is_null($uuid)) {
      $uuid = Uuid::uuid4()->toString();
      $blueprint->dbSet('blueprint', 'uuid', $uuid);
    }

    // Calculate a fixed time to run the data push at, this will be the same time every day.
    $time = hexdec(str_replace('-', '', substr($uuid, 27))) % 1440;
    $hour = floor($time / 60);
    $minute = $time % 60;

    // Run the telemetry collector.
    $schedule->call(app()->make(BlueprintTelemetryCollectionService::class))->description('Collect Blueprint Telemetry')->dailyAt("$hour:$minute");
  }
}