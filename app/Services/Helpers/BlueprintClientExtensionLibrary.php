<?php

/*
| Welcome to the Blueprint (Client) Extension Library.
|
| This allows extensions to easily communicate with
| Blueprint and Pterodactyl.
*/

namespace Pterodactyl\Services\Helpers;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\Services\Helpers\BlueprintPlaceholderService;

class BlueprintClientExtensionLibrary
{
  // Construct BlueprintClientExtensionLibrary
  public function __construct(
    private SettingsRepositoryInterface $settings,
    private BlueprintPlaceholderService $placeholder,
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
  | Files
  | 
  | fileRead("path");
  */
  public function fileRead($path) {
    return shell_exec("cat ".escapeshellarg($path).";");
  }
}
