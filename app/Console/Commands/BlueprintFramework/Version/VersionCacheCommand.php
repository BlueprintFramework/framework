<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework\Version;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class VersionCacheCommand extends Command
{
  protected $description = 'Fetches and caches the latest release name';
  protected $signature = 'bp:version:cache';

  /**
   * VersionCacheCommand constructor.
   */
  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintExtensionLibrary $blueprint,
  ) {
    parent::__construct();
  }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    $api_url = $this->PlaceholderService->api_url() . "/api/latest";
    $context = stream_context_create([
      'http' => [
        'method' => 'GET',
        'header' => 'User-Agent: BlueprintFramework',
      ],
    ]);
    $response = file_get_contents($api_url, false, $context);
    if ($response) {
      $cleaned_response = preg_replace('/[[:^print:]]/', '', $response);
      $data = json_decode($cleaned_response, true);
      if (isset($data['name'])) {
        $latest_version = $data['name'];
        $this->blueprint->dbSet('blueprint', 'internal:version:latest', $latest_version);
        return true;
      } else {
        echo "Error: Unable to fetch the latest release version.";
        return false;
      }
    } else {
      echo "Error: Failed to make the API request.";
      return false;
    }
  }
}
