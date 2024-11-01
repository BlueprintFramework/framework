<?php

/**
 * BlueprintExtensionLibrary (Console variation)
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintConsoleLibrary
 * @author     Emma <hello@prpl.wtf>
 * @copyright  2023-2024 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      beta
 */

namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintConsoleLibrary
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
   * @param mixed $default Optional. Returns this value when value is null.
   * @return mixed Database value
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbGet($table, $record, $default = null): mixed {
    $value = $this->settings->get($table."::".$record);
    if($value) {
      return $value;
    } else {
      return $default;
    }
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
   * Read and returns the content of a given file.
   * 
   * @param string $path Path to file
   * @return string File contents
   * @throws string File cannot be read or found
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileRead($path) {
    if (!file_exists(filename: $path)) {
      return "File not found: " . $path;
    }
    if (!is_readable(filename: $path)) {
      return "File is not readable: " . $path;
    }

    return file_get_contents(filename: $path);
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
    $file = fopen(filename: $path, mode: "w");
    fclose(stream: $file);
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
  public function fileWipe($path): void {
    if(is_dir(filename: $path)) {
      $files = array_diff(array: scandir(directory: $path), arrays: ['.', '..']);
      foreach ($files as $file) {
        $this->fileWipe(path: $path . DIRECTORY_SEPARATOR . $file);
      }
      rmdir(directory: $path);
    } elseif (is_file(filename: $path)) {
      unlink(filename: $path);
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
    if(str_contains(haystack: $this->fileRead(path: base_path(".blueprint/extensions/blueprint/private/db/installed_extensions")), needle: $identifier.',')) {
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
    $array = explode(separator: ',', string: $this->fileRead(path: base_path(".blueprint/extensions/blueprint/private/db/installed_extensions")));
    $extensions = array_filter(array: $array, callback: function($value): bool {
      return !empty($value);
    });
    return $extensions;
  }
}
