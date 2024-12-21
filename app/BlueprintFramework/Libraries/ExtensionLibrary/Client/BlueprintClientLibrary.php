<?php

/**
 * BlueprintExtensionLibrary (Client variation)
 *
 * @category   BlueprintExtensionLibrary
 * @package    BlueprintClientLibrary
 * @author     Emma <hello@prpl.wtf>
 * @copyright  2023-2024 Emma (prpl.wtf)
 * @license    https://blueprint.zip/docs/?page=about/License MIT License
 * @link       https://blueprint.zip/docs/?page=documentation/$blueprint
 * @since      alpha
 */

namespace Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Client;

use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\BlueprintBaseLibrary;

class BlueprintClientLibrary extends BlueprintBaseLibrary
{
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
