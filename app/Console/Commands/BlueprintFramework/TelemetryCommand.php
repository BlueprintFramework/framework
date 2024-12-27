<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Symfony\Component\VarDumper\VarDumper;
use Pterodactyl\Services\Telemetry\BlueprintTelemetryCollectionService;


class TelemetryCommand extends Command
{
  protected $description = 'Displays all the data that would be sent to the Blueprint Telemetry Service if telemetry collection is enabled';
  protected $signature = 'bp:telemetry';

  /**
   * TelemetryCommand constructor.
   */
  public function __construct(
    private BlueprintTelemetryCollectionService $blueprintTelemetryCollectionService,
  ) {
    parent::__construct();
  }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    VarDumper::dump($this->blueprintTelemetryCollectionService->collect());
  }
}