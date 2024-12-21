<?php

namespace Pterodactyl\Services\Telemetry;

use Ramsey\Uuid\Uuid;
use Illuminate\Console\Scheduling\Schedule;
use Pterodactyl\Services\Telemetry\BlueprintTelemetryCollectionService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class RegisterBlueprintTelemetry
{
  /**
   * ¯\_(ツ)_/¯
   *
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   * @throws \Illuminate\Contracts\Container\BindingResolutionException
   */
  public function register(Schedule $schedule): void
  {
    $blueprint = app()->make(BlueprintExtensionLibrary::class);

    $uuid = $blueprint->dbGet('blueprint', 'internal:uuid');
    if (is_null($uuid)) {
      $uuid = Uuid::uuid4()->toString();
      $blueprint->dbSet('blueprint', 'internal:uuid', $uuid);
    }

    // Calculate a fixed time to run the data push at, this will be the same time every day.
    $time = hexdec(str_replace('-', '', substr($uuid, 27))) % 1440;
    $hour = floor($time / 60);
    $minute = $time % 60;

    // Run the telemetry collector.
    $schedule->call(app()->make(BlueprintTelemetryCollectionService::class))->description('Collect Blueprint Telemetry')->dailyAt("$hour:$minute");
  }
}