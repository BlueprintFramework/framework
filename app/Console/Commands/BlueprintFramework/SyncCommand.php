<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\ConfigService\BlueprintConfigService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class SyncCommand extends Command
{
  protected $description = 'Sync Blueprint configuration settings with Blueprint\'s command line utility.';
  protected $signature = 'bp:sync';

  /**
   * SyncCommand constructor.
   */
  public function __construct(
    private BlueprintExtensionLibrary $blueprint,
    private BlueprintConfigService $ConfigService,
    private BlueprintPlaceholderService $PlaceholderService,
    private SettingsRepositoryInterface $settings,
  ) {
    parent::__construct();
  }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    // DEVELOPER MODE
    $this->ConfigService->config('DEVELOPER', $this->settings->get('blueprint::developer'));
  }
}
