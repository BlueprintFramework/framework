<?php

/*
| Welcome to the Blueprint Extension Library.
|
| This allows developers to interact with
| Pterodactyl easely and without hassle.
*/

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Services\Helpers\BlueprintVariableService;
use Pterodactyl\Services\Helpers\BlueprintTelemetryService;
use Pterodactyl\Services\Helpers\BlueprintPlaceholderService;

class BlueprintExtensionLibrary
{
    // Construct BlueprintExtensionLibrary
    public function __construct(
        private SettingsRepositoryInterface $settings,
        private BlueprintVariableService $bp,
        private BlueprintTelemetryService $telemetry,
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