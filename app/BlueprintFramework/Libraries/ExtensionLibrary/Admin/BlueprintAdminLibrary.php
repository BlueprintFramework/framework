<?php

// Core file for the admin-side library for Blueprint Extensions


namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintAdminLibrary
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
  | Notifications
  |
  | notify("text");
  | notifyAfter(delay, "text");
  | notifyNow("text");
  */
  public function notify($text) {
    $this->dbSet("blueprint", "notification:text", $text);
    return;
  }

  public function notifyAfter($delay, $text) {
    $this->dbSet("blueprint", "notification:text", $text);
    header("Refresh:$delay");
    return;
  }

  public function notifyNow($text) {
    $this->dbSet("blueprint", "notification:text", $text);
    header("Refresh:0");
    return;
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
