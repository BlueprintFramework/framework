<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class DeveloperCommand extends Command
{
  protected $description = 'Check if Blueprint developer mode is enabled';
  protected $signature = 'bp:developer';

  public function __construct(private BlueprintExtensionLibrary $blueprint)
  {
    parent::__construct();
  }

  public function handle()
  {
    if ($this->blueprint->dbGet('blueprint', 'flags:is_developer', 0)) {
      echo 'true';
      return;
    }
    echo 'false';
  }
}
