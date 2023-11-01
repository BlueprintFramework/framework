<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\VariableService\BlueprintVariableService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class SyncCommand extends Command
{
  protected $description = 'Forward some database values to Blueprint.';
  protected $signature = 'bp:sync';

  /**
   * TelemetryCommand constructor.
   */
  public function __construct(
    private BlueprintVariableService $bp,
    private BlueprintExtensionLibrary $blueprint,
    private SettingsRepositoryInterface $settings,
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    // The following code rerolls the panel identifier used for telemetry
    // when the version name changes.
    if ($this->settings->get('blueprint::panel:id') == "" || $this->bp->version() != $this->settings->get('blueprint::version:cache')) {
      if ($this->settings->get('blueprint::telemetry') == "") {$this->settings->set('blueprint::telemetry', "true");}
      if ($this->settings->get('blueprint::telemetry') == "false") { 
        $this->bp->config('TELEMETRY_ID','KEY_NOT_UPDATED');
      } else {
        $this->settings->set('blueprint::panel:id', uniqid(rand())."@".$this->bp->version());
        $this->settings->set('blueprint::version:cache', $this->bp->version());
        $this->bp->config('TELEMETRY_ID',$this->settings->get("blueprint::panel:id"));
      }
    };
    // Sync developer mode option with the core of Blueprint.
    $this->bp->config('DEVELOPER', $this->settings->get('blueprint::developer'));
  }
}
