<?php

/**
 * BlueprintExtensionLibrary (Backwards compatibility)
 *
 * BlueprintLegacyLibrary provides backwards-compatibility for older
 * extensions. Functions are deprecated, unmaintained and slowly phased out.
 * Consider using maintained versions of BlueprintExtensionLibrary.
 *
 * Certain functions are being phased out and return "false" instead of the
 * correct value. Consider switching to maintained versions to prevent your
 * extension from breaking with future updates.
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintLegacyLibrary
 * @author     Emma <hello@prpl.wtf>
 * @copyright  2023-2024 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      indev
 * @deprecated alpha
 */

namespace Pterodactyl\Services\Helpers;

use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintExtensionLibrary
{
  public function __construct(
    private SettingsRepositoryInterface $settings,
    private BlueprintPlaceholderService $placeholder,
  ) {
  }

  public function dbGet($table, $record)
  {
    return $this->settings->get($table . "::" . $record);
  }
  public function dbSet($table, $record, $value)
  {
    return $this->settings->set($table . "::" . $record, $value);
  }

  public function notify($text)
  {
    return false;
  }
  public function notifyAfter($delay, $text)
  {
    return false;
  }
  public function notifyNow($text)
  {
    return false;
  }

  public function fileRead($path)
  {
    return false;
  }
  public function fileMake($path)
  {
    return false;
  }
  public function fileWipe($path)
  {
    return false;
  }
}
