<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;

class CacheCommand extends Command
{
  protected $description = 'Flush Blueprint stylesheet and scripts cache';
  protected $signature = 'bp:cache';

  /**
   * SyncCommand constructor.
   */
  public function __construct(
    private BlueprintExtensionLibrary $blueprint,
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    $cache = time();
    $this->blueprint->dbSet("blueprint", "cache", "$cache");
    echo "Flushed Blueprint stylesheet and scripts cache.";
  }
}
