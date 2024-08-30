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
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    // TELEMETRY ID
    if ($this->settings->get('blueprint::panel:id') == "" || $this->PlaceholderService->version() != $this->settings->get('blueprint::version:cache')) {
      $this->settings->set('blueprint::panel:id', uniqid(rand())."@".$this->PlaceholderService->version());
      $this->settings->set('blueprint::version:cache', $this->PlaceholderService->version());
    }
    
    // TELEMETRY STATUS
    if ($this->settings->get('blueprint::telemetry') == "") { $this->settings->set('blueprint::telemetry', "true"); }
    if ($this->settings->get('blueprint::telemetry') == "false") { $this->ConfigService->config('TELEMETRY_ID','KEY_NOT_UPDATED');
    } else { $this->ConfigService->config('TELEMETRY_ID',$this->settings->get("blueprint::panel:id")); }

    // DEVELOPER MODE
    $this->ConfigService->config('DEVELOPER', $this->settings->get('blueprint::developer'));
  }
}
