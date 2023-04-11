<?php

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Services\Helpers\BlueprintVariableService;
use Pterodactyl\Services\Helpers\BlueprintExtensionLibrary;
use Pterodactyl\Services\Helpers\BlueprintTelemetryService;

class BlueprintPlaceholderService
{
    // Construct BlueprintPlaceholderService
    public function __construct(
        private SettingsRepositoryInterface $settings,
        private BlueprintVariableService $bp,
        private BlueprintExtensionLibrary $lib,
        private BlueprintTelemetryService $telemetry,
    ) {
    }

    // $bp->licenseKey()
    // $bp->version()
    public
    function version(): string {
        $v = "([(pterodactylmarket_version)])";
        return $v;
    }
    
    public function licenseKey(): string{return "([(pterodactylmarket_transactionid)])";}
}
