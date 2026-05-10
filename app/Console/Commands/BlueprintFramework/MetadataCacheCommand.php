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
    // figure out which extensions are currently installed
    $installed_extensions = $this->blueprint->extensions();

    // get version info
    $context = stream_context_create(['http' => ['method' => 'GET', 'header' => 'User-Agent: BlueprintFramework']]);
    $remote_versions = @file_get_contents(
      $this->PlaceholderService->api_url() . '/api/extensions/latest',
      false,
      $context
    );

    if($remote_versions) {

    }
  }
}
