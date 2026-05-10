<?php

// This command fetches extension metadata on a schedule, to then provide administrators
// with stuff like latest version info, and maybe more in the future.
//
// 1. make a request to blueprint.zip/api/extensions/latest
// 2. figure out which extensions it should write metadata for
// 3. build a json object for those extensions' metadata
// 4. flush metadata table
// 5. write metadata table

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Pterodactyl\Models\ExtensionCachedMetadata;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class MetadataCacheCommand extends Command
{
  protected $description = 'Refreshes extension metadata';
  protected $signature = 'bp:meta';

  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintExtensionLibrary $blueprint,
  ) {
    parent::__construct();
  }

  public function handle()
  {
    if(! $this->blueprint->dbGet("blueprint", "flags:remote_metadata")) {
      $this->error('remote_metadata flag set to false');
      return false;
    }

    $now = now();
    $rows = [];
    $installedExtensions = $this->blueprint->extensions();

    // get version info
    $context = stream_context_create(['http' => ['method' => 'GET', 'header' => 'User-Agent: BlueprintFramework']]);
    $remoteVersions = @file_get_contents(
      $this->PlaceholderService->api_url() . '/api/extensions/latest',
      false,
      $context
    );

    if($remoteVersions) {
      $remoteVersionsData = json_decode($remoteVersions, true);
    }

    if(! isset($remoteVersionsData)) {
      $this->error('failed to fetch extension versions');
      return false;
    }

    foreach ($installedExtensions as $identifier) {
      if(! isset($remoteVersionsData[$identifier]) || ! is_scalar($remoteVersionsData[$identifier])) continue;

      $local_extension = $this->blueprint->extensionConfig($identifier);

      $rows[] = [
        'identifier' => $identifier,
        'metadata' =>  json_encode([
          'latest_version' => (string) $remoteVersionsData[$identifier],
          'local_version' => (string) $local_extension['info']['version'] | '',
        ]),
        'fetched_at' => $now,
      ];
    }

    if (empty($rows)) {
      $this->info('no relevant data available, do you have any extensions installed?');
      return false;
    }

    $table = (new ExtensionCachedMetadata())->getTable();
    $temp = $table . '_tmp_' . substr(uniqid(), -8);

    DB::statement("CREATE TABLE {$temp} LIKE {$table}");

    foreach (array_chunk($rows, 500) as $chunk) {
      DB::table($temp)->insert($chunk);
    }

    // atomic swap
    DB::statement("RENAME TABLE {$table} TO {$table}_bak, {$temp} TO {$table}");
    DB::statement("DROP TABLE {$table}_bak");

    $this->info('updated extension cached metadata');
  }
}
