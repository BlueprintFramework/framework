<?php

/*
| Welcome to the Blueprint Extension Library.
|
| This allows you and developers to interact with
| Blueprint easely and without hassle.
*/

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Http\RedirectResponse;

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