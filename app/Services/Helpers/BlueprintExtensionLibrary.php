<?php

/*
| Welcome to the Blueprint Extension Library.
|
| This allows developers to interact with
| Pterodactyl easely and without hassle.
*/

namespace Pterodactyl\Services\Helpers;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintExtensionLibrary
{
    // Construct BlueprintExtensionLibrary
    public function __construct(
        private SettingsRepositoryInterface $settings,
    ) {
    }

    public function db($type, $one, $two) {
        if ($type === "get") {
            return $this->settings->get($one."::".$two);
        };
        if ($type === "set") {
            return $this->settings->set($one, $two);
        };
        return true;
    }
}