<?php

/**
 * BlueprintExtensionLibrary (Base code, do not use directly)
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintBaseLibrary
 * @author     Emma <hello@prpl.wtf>
 * @copyright  2023-2024 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      alpha
 */

namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;
use Symfony\Component\Yaml\Yaml;

class BlueprintBaseLibrary
{
  private function getRecordName(string $table, string $record)
  {
    return "$table::$record";
  }

  /**
   * Fetch a record from the database. (Data will be unserialized)
   * 
   * @param string $table Database table
   * @param string $record Database record
   * @param mixed $default Optional. Returns this value when value is null.
   * @return mixed Database value
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbGet(string $table, string $record, mixed $default = null): mixed
  {
    $value = DB::table('settings')->where('key', $this->getRecordName($table, $record))->first();

    if (!$value) return $default;

    try {
      return unserialize($value->value);
    } catch (\Exception $e) {
      return $value->value;
    }
  }

  /**
   * Fetch many records from the database. (Data will be unserialized)
   * 
   * @param string $table Database table
   * @param array $records Database records
   * @param mixed $default Optional. Returns this value when value is null.
   * @return array Database values as an associative array
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbGetMany(string $table, array $records = [], mixed $default = null): array
  {
    if (empty($records)) {
      $values = DB::table('settings')->where('key', 'like', "$table::%")->get();
    } else {
      $values = DB::table('settings')->whereIn('key', array_map(fn($record) => $this->getRecordName($table, $record), $records))->get();
    }

    if (empty($records)) {
      $records = $values->map(fn($value) => substr($value->key, strlen($table) + 2))->toArray();
    }

    $output = [];
    foreach ($records as $record) {
      $value = $values->firstWhere('key', $this->getRecordName($table, $record));

      if (!$value) {
        $output[$record] = $default;
        continue;
      }

      try {
        $output[$record] = unserialize($value->value);
      } catch (\Exception $e) {
        $output[$record] = $value->value;
      }
    }

    return $output;
  }

  /**
   * Set a database record. (Data will be serialized)
   * 
   * @param string $table Database table
   * @param string $record Database record
   * @param string $value Value to store
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbSet(string $table, string $record, mixed $value): void
  {
    DB::table('settings')->updateOrInsert(
      ['key' => $this->getRecordName($table, $record)],
      ['value' => serialize($value)]
    );
  }

  /**
   * Set many database records. (Data will be serialized)
   * 
   * @param string $table Database table
   * @param array $records Database records as an associative array
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbSetMany(string $table, array $records): void
  {
    $data = [];
    foreach ($records as $record => $value) {
      $data[] = [
        'key' => $this->getRecordName($table, $record),
        'value' => serialize($value),
      ];
    }

    DB::table('settings')->upsert($data, ['key'], ['value']);
  }

  /**
   * Delete/forget a database record.
   * 
   * @param string $table Database table
   * @param string $record Database record
   * @return bool Whether there was a record to delete
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbForget(string $table, string $record): bool
  {
    return (bool) DB::table('settings')->where('key', $this->getRecordName($table, $record))->delete();
  }

  /**
   * Delete/forget many database records.
   * 
   * @param string $table Database table
   * @param array $records Database records
   * @return bool Whether there was a record to delete
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function dbForgetMany(string $table, array $records): bool
  {
    return (bool) DB::table('settings')->whereIn('key', array_map(fn($record) => $this->getRecordName($table, $record), $records))->delete();
  }

  /**
   * Read and returns the content of a given file.
   * 
   * @param string $path Path to file
   * @return string File contents or empty string if file does not exist or is not readable
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileRead(string $path): string
  {
    if (!file_exists($path))
      return '';
    if (!is_readable($path))
      return '';

    return file_get_contents($path);
  }

  /**
   * Attempts to create a file.
   * 
   * @param string $path File name/path
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileMake(string $path): void
  {
    $file = fopen($path, 'w');
    fclose($file);
  }

  /**
   * Attempts to remove a file or directory.
   * 
   * @param string $path Path to file/directory
   * @return bool Whether the file/directory was removed
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function fileWipe(string $path): bool
  {
    if (is_dir($path)) {
      $files = array_diff(scandir($path), ['.', '..']);

      foreach ($files as $file) {
        $this->fileWipe($path . DIRECTORY_SEPARATOR . $file);
      }

      rmdir($path);

      return true;
    } elseif (is_file($path)) {
      unlink($path);

      return true;
    } else {
      return false;
    }
  }

  /**
   * Check if an extension is installed based on it's identifier.
   * 
   * @param string $identifier Extension identifier
   * @return bool Whether the extension is installed
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function extension(string $identifier): bool
  {
    return str_contains($this->fileRead(base_path('.blueprint/extensions/blueprint/private/db/installed_extensions')), $identifier);
  }

  /**
   * Returns an array containing all installed extensions's identifiers.
   * 
   * @return array An array of installed extensions
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function extensions(): Collection
  {
    $array = explode(',', $this->fileRead(base_path('.blueprint/extensions/blueprint/private/db/installed_extensions')));
    $collection = new Collection();

    foreach ($array as $extension) {
      if (!$extension)
        continue;

      try {
        $conf = Yaml::parse($this->fileRead(base_path(".blueprint/extensions/$extension/private/.store/conf.yml")));

        $collection->push(array_filter($conf['info'], fn ($k) => !!$k));
      } catch (\Exception $e) {
      }
    }

    return $collection;
  }
}
