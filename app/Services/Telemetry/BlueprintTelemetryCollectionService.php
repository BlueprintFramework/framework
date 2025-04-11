<?php

namespace Pterodactyl\Services\Telemetry;

use Ramsey\Uuid\Uuid;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;
use Database\Seeders\BlueprintSeeder;

class BlueprintTelemetryCollectionService
{
  /**
   * BlueprintTelemetryCollectionService constructor.
   */
  public function __construct(
    private BlueprintExtensionLibrary $blueprint,
    private BlueprintPlaceholderService $placeholderService,
    private BlueprintSeeder $seeder,
  ) {
  }

  /**
   * Collects telemetry data and sends it to the Blueprint Telemetry Service.
   */
  public function __invoke(): void
  {
    try {
      $data = $this->collect();
    } catch (\Exception) {
      return;
    }

    Http::post($this->placeholderService->api_url() . '/api/telemetry', $data);
  }

  /**
   * Collects telemetry data and returns it as an array.
   *
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   */
  public function collect(): array
  {
    $uuid = $this->blueprint->dbGet('blueprint', 'internal:uuid');
    if (is_null($uuid)) {
      $uuid = Uuid::uuid4()->toString();
      $this->blueprint->dbSet('blueprint', 'internal:uuid', $uuid);
    }

    $schema = $this->seeder->getSchema();
    $flags = [];
    
    if (isset($schema['flags'])) {
      foreach ($schema['flags'] as $flagName => $config) {
        $path = "flags:{$flagName}";
        $value = $this->blueprint->dbGet('blueprint', $path);
        
        if (is_null($value)) {
          $value = $this->seeder->getDefaultsForFlag($path);
        }

        // Force booleans
        if ($value == "1") {
          $value = true;
        } elseif ($value == "0") {
          $value = false;
        }
        
        $flags[$flagName] = $value;
      }
    }

    return [
      'id' => $uuid,
      'telemetry_version' => 1,

      'blueprint' => [
        'version' => $this->placeholderService->version(),
        'extensions' => array_map(function ($config) {
            return $config['info'] ?? null;
        }, $this->blueprint->extensionsConfigs()->toArray()),
        'flags' => $flags,
        'docker' => file_exists('/.dockerenv'),
      ],

      'panel' => [
        'version' => config('app.version'),
        'phpVersion' => phpversion(),

        'drivers' => [
          'backup' => [
            'type' => config('backups.default'),
          ],

          'cache' => [
            'type' => config('cache.default'),
          ],

          'database' => [
            'type' => config('database.default'),
            'version' => DB::getPdo()->getAttribute(\PDO::ATTR_SERVER_VERSION),
          ],
        ],
      ],
    ];
  }
}