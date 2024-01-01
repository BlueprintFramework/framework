<?php

namespace Pterodactyl\BlueprintFramework\Services\PlaceholderService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintPlaceholderService
{
  // Construct core
  public function __construct(
    private SettingsRepositoryInterface $settings,
  ) {
  }

  // version()
  public function version(): string {
    $v = "::v";
    return $v;
  }

  // folder()
  public function folder(): string {
    $v = "::f";
    return $v;
  }

  // installed()
  public function installed(): string {
    $v = "NOTINSTALLED";
    return $v;
  }
}
