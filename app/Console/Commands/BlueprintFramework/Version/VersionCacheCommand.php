<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework\Version;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class VersionCacheCommand extends Command
{
  protected $description = 'Fetches and caches the latest release name';
  protected $signature = 'bp:version:cache';

  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintExtensionLibrary $blueprint,
  ) {
    parent::__construct();
  }

  public function handle()
  {
    $res = Http::get($this->PlaceholderService->api_url() . '/api/latest');
    $body = $res->body();

    if ($body === false || empty($body)) {
      $this->blueprint->dbSet('blueprint', 'internal:version:latest', 'unknown');
      return false;
    }

    if ($body) {
      $cleaned_response = preg_replace('/[[:^print:]]/', '', $body);
      $data = json_decode($cleaned_response, true);
      if (isset($data['name'])) {
        $latest_version = $data['name'];
        $this->blueprint->dbSet('blueprint', 'internal:version:latest', $latest_version);
        return true;
      } else {
        echo 'Error: Unable to fetch the latest release version.';
        $this->blueprint->dbSet('blueprint', 'internal:version:latest', 'unknown');
        return false;
      }
    } else {
      echo 'Error: Failed to make the API request.';
      $this->blueprint->dbSet('blueprint', 'internal:version:latest', 'unknown');
      return false;
    }
  }
}
