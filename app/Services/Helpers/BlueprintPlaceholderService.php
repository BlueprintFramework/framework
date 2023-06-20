<?php

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintPlaceholderService
{
  // Construct BlueprintPlaceholderService
  public function __construct(
    private SettingsRepositoryInterface $settings,
  ) {
  }

  // version()
  public function version(): string {
    $v = "&bp.version&";
    return $v;
  }

  // folder()
  public function folder(): string {
    $v = "&bp.folder&";
    return $v;
  }

  // installed()
  public function installed(): string {
    $v = "NOTINSTALLED";
    return $v;
  }
}
