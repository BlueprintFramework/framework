<?php

/**
 * BlueprintExtensionLibrary (Admin variation)
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintAdminLibrary
 * @author     Emma <hello@prpl.wtf>
 * @copyright  2023-2024 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      alpha
 */

namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin;

use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\BlueprintBaseLibrary;

class BlueprintAdminLibrary extends BlueprintBaseLibrary
{
  /**
   * Display a notification on the Pterodactyl admin panel (on next page load).
   * 
   * @param string $text Notification contents
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notify(string $text): void
  {
    $this->dbSet('blueprint', 'notification:text', $text);
  }

  /**
   * (Deprecated) Display a notification on the Pterodactyl admin panel and refresh the page after a certain delay.
   * 
   * @deprecated beta-2024-12
   * @param string $delay Refresh after (in seconds)
   * @param string $text Notification contents
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyAfter($delay, $text): void
  {
  }

  /**
   * (Deprecated) Display a notification on the Pterodactyl admin panel and refresh the page instantly.
   * Behaves the same as calling `notifyAfter()` with a delay of zero.
   * 
   * @deprecated beta-2024-12
   * @param string $text Notification contents
   * 
   * [BlueprintExtensionLibrary documentation](https://blueprint.zip/docs/?page=documentation/$blueprint)
   */
  public function notifyNow($text): void
  {
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
}
