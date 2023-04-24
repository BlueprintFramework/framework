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

    /*
    | Databasing
    |
    | dbGet("table", "record");
    | dbSet("table", "record", "value");
    */
    public function dbGet($table, $record) {
        return $this->settings->get($table."::".$record);
    }

    public function dbSet($table, $record, $value) {
        return $this->settings->set($table."::".$record, $value);
    }

    /*
    | Notifications
    |
    | notify("text");
    */
    public function notify($text) {
        $this->dbSet("blueprint", "notification:text", $text);
        shell_exec("cd /var/www/pterodactyl;echo \"$text\" > .blueprint/.storage/notification;");
        return;
    }
}