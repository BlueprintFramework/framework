<?php

/**
 * BlueprintExtensionLibrary (Admin variation)
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintAdminLibrary
 * @author     Blueprint Framework <byte@blueprint.zip>
 * @copyright  2023-2025 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      alpha
 */

namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin;

use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\BlueprintBaseLibrary;
use Prologue\Alerts\Facades\Alert;

class BlueprintAdminLibrary extends BlueprintBaseLibrary
{
  /**
   * Displays an alert message at the top of the page.
   *
   * @param 'info'|'warning'|'danger'|'success' $type The type of alert.
   * @param string $message Alert message.
   * @since beta-2025-09
   *
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function alert(string $type, string $message): void
  {
    switch ($type) {
      case 'success':
        Alert::success($message)->flash();
        break;
      case 'warning':
        Alert::warning($message)->flash();
        break;
      case 'danger':
        Alert::danger($message)->flash();
        break;
      case 'info':
      default:
        Alert::info($message)->flash();
        break;
    }
  }

  /**
   * Returns a HTML link tag importing the specified stylesheet with additional URL params to avoid issues with stylesheet cache.
   *
   * @param string $url Stylesheet URL
   * @return string HTML <link> tag
   *
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function importStylesheet(string $url): string
  {
    $cache = $this->dbGet('blueprint', 'internal:cache', 0);

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
  public function importScript(string $url): string
  {
    $cache = $this->dbGet('blueprint', 'internal:cache', 0);

    return "<script src=\"$url?v=$cache\"></script>";
  }

  /**
   * (Deprecated) Display a notification on the Pterodactyl admin panel (on next page load).
   * Available for backwards compatibility, do not use this function, use alert() instead.
   *
   * @deprecated beta-2025-09
   * @param string $text Notification contents
   *
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notify(string $text): void
  {
    $this->alert('info', $text);
  }

  /**
   * (Deprecated) Display a notification on the Pterodactyl admin panel and refresh the page after a certain delay.
   * This function will return void. Do not use this function.
   *
   * @deprecated beta-2024-12
   * @param string $delay Refresh after (in seconds)
   * @param string $text Notification contents
   *
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyAfter($delay, $text): void {}

  /**
   * (Deprecated) Display a notification on the Pterodactyl admin panel and refresh the page instantly.
   * Behaves the same as calling `notifyAfter()` with a delay of zero.
   * This function will return void. Do not use this function.
   *
   * @deprecated beta-2024-12
   * @param string $text Notification contents
   *
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyNow($text): void {}
}
