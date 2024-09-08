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

  /**
   * Fetch a record from the database.
   * 
   * @param string $table Database table
   * @param string $record Database record
   * @return mixed Database value
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbGet($table, $record): mixed {
    return $this->settings->get($table."::".$record);
  }

  /**
   * Set a database record.
   * 
   * @param string $table Database table
   * @param string $record Database record
   * @param string $value Value to store
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbSet($table, $record, $value) {
    return $this->settings->set($table."::".$record, $value);
  }

  /**
   * Delete/forget a database record.
   * 
   * @param string $table Database table
   * @param string $record Database record
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbForget($table, $record) {
    return $this->settings->forget($table."::".$record);
  }

  /**
   * Display a notification on the Pterodactyl admin panel (on next page load).
   * 
   * @param string $text Notification contents
   * @return void Nothing is returned
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notify($text): void {
    $this->dbSet("blueprint", "notification:text", $text);
    return;
  }

  /**
   * Display a notification on the Pterodactyl admin panel and refresh the page after a certain delay.
   * 
   * @param string $delay Refresh after (in seconds)
   * @param string $text Notification contents
   * @return void Nothing is returned
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyAfter($delay, $text): void {
    $this->dbSet("blueprint", "notification:text", $text);
    header("Refresh:$delay");
    return;
  }

  /**
   * Display a notification on the Pterodactyl admin panel and refresh the page instantly.
   * Behaves the same as calling `notifyAfter()` with a delay of zero.
   * 
   * @param string $text Notification contents
   * @return void Nothing is returned
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyNow($text): void {
    $this->dbSet("blueprint", "notification:text", $text);
    header("Refresh:0");
    return;
  }

  /**
   * Read and returns the content of a given file.
   * 
   * @param string $path Path to file
   * @return string File contents
   * @throws string Errors encountered by `cat` shell utility
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileRead($path) {
    return shell_exec("cat ".escapeshellarg($path).";");
  }

  /**
   * Attempts to create a file.
   * 
   * @param string $path File name/path
   * @return void
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileMake($path): void {
    $file = fopen($path, "w");
    fclose($file);
    return;
  }

  /**
   * Attempts to remove a file or directory.
   * 
   * @param string $path Path to file/directory
   * @return void
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileWipe($path) {
    if(is_dir($path)) {
      $files = array_diff(scandir($path), ['.', '..']);
      foreach ($files as $file) {
        $this->fileWipe($path . DIRECTORY_SEPARATOR . $file);
      }
      rmdir($path);
    } elseif (is_file($path)) {
      unlink($path);
    }
  }

  /**
   * Check if an extension is installed based on it's identifier.
   * 
   * @param string $identifier Extension identifier
   * @return bool Boolean
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function extension($identifier): bool {
    if(str_contains($this->fileRead(base_path(".blueprint/extensions/blueprint/private/db/installed_extensions")), $identifier.',')) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * Returns an array containing all installed extensions's identifiers.
   * 
   * @return array Array
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function extensionList(): array {
    $array = explode(',', $this->fileRead(base_path(".blueprint/extensions/blueprint/private/db/installed_extensions")));
    $extensions = array_filter($array, function($value) {
      return !empty($value);
    });
    return $extensions;
  }

  /**
   * Returns a HTML link tag importing the specified stylesheet with additional URL params to avoid issues with stylesheet cache.
   * 
   * @param string $url Stylesheet URL
   * @return string HTML <link> tag
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function importStylesheet($url): string {
    $cache = $this->dbGet("blueprint", "cache");
    return "<link rel=\"stylesheet\" href=\"$url?v=$cache\">";
  }

  /**
   * Returns a HTML script tag importing the specified script with additional URL params to avoid issues with script cache.
   * 
   * @param string $url Script URL
   * @return string HTML <script> tag
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function importScript($url): string {
    $cache = $this->dbGet("blueprint", "cache");
    return "<script src=\"$url?v=$cache\"></script>";
  }
}
