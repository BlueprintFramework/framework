<?php

// THIS IS FOR BACKWARDS COMPATABILITY ONLY!
// 
// This file will be removed in later versions of Blueprint to
// give developers the time to move to the new location of the
// extension library.





namespace Pterodactyl\Services\Helpers;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintExtensionLibrary
{
  // Construct BlueprintExtensionLibrary
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
  | Notifications
  |
  | notify("text");
  | notifyAfter(delay, "text");
  | notifyNow("text");
  */
  public function notify($text) {
    $this->dbSet("blueprint", "notification:text", $text);
    shell_exec("cd ".escapeshellarg($this->placeholder->folder()).";echo ".escapeshellarg($text)." > .blueprint/extensions/blueprint/private/db/notification;");
    return;
  }

  public function notifyAfter($delay, $text) {
    $this->dbSet("blueprint", "notification:text", $text);
    shell_exec("cd ".escapeshellarg($this->placeholder->folder()).";echo ".escapeshellarg($text)." > .blueprint/extensions/blueprint/private/db/notification;");
    header("Refresh:$delay");
    return;
  }

  public function notifyNow($text) {
    $this->dbSet("blueprint", "notification:text", $text);
    shell_exec("cd ".escapeshellarg($this->placeholder->folder()).";echo ".escapeshellarg($text)." > .blueprint/extensions/blueprint/private/db/notification;");
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
