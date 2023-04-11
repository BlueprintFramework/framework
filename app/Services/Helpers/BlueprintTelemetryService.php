<?php

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Services\Helpers\BlueprintVariableService;
use Pterodactyl\Services\Helpers\BlueprintExtensionLibrary;
use Pterodactyl\Services\Helpers\BlueprintPlaceholderService;

class BlueprintTelemetryService
{
    // Construct BlueprintTelemetryService
    public function __construct(
        private SettingsRepositoryInterface $settings,
        private BlueprintVariableService $bp,
        private BlueprintExtensionLibrary $lib,
        private BlueprintPlaceholderService $placeholder,
    ) {
    }

    public function db($type, $table, $key, $value) {
        if ($type === "get") {
            return $this->settings->get($table."::".$key);
        };
        if ($type === "set") {
            return $this->settings->set($table."::".$key, $value);
        };
        return true;
    }
}