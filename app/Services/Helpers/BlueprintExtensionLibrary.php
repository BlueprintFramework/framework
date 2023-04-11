<?php

/*
| Welcome to the Blueprint Extension Library.
|
| This allows developers to interact with
| Pterodactyl easely and without hassle.
*/

namespace Pterodactyl\Services\Helpers;

class BlueprintExtensionLibrary
{
    // Construct BlueprintExtensionLibrary
    public function __construct(
        private SettingsRepositoryInterface $settings,
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