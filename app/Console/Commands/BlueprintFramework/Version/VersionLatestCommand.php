<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework\Version;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class VersionLatestCommand extends Command
{
  protected $description = 'Returns the latest release name';
  protected $signature = 'bp:version:latest';

  /**
   * VersionLatestCommand constructor.
   */
  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintExtensionLibrary $blueprint,
  ) {
    parent::__construct();
  }

  /**
   * Handle execution of command.
   *
   * @return string The latest version
   */
  public function handle()
  {
    $latest = $this->blueprint->dbGet('blueprint', 'internal:version:latest');
    if ($latest == "") {
      $this->call('bp:version:cache');
      $latest = $this->blueprint->dbGet('blueprint', 'internal:version:latest');
    }

    echo ($latest);
    return $latest;
  }

}
