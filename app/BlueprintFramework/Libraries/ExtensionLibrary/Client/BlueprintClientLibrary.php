<?php

// Core file for the client-side library for Blueprint Extensions


namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Client;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintClientLibrary
{
  // Construct core
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
  | Files
  | 
  | fileRead("path");
  | fileMake("path");
  | fileWipe("path");
  */
  public function fileRead($path) {
    return shell_exec("cat ".escapeshellarg($path).";");
  }

  public function fileMake($path) {
    return shell_exec("touch ".escapeshellarg($path).";");
  }

  public function fileWipe($path) {
    return shell_exec("rm ".escapeshellarg($path).";");
  }
}
