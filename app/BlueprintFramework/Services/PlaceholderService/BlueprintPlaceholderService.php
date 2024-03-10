<?php

namespace Pterodactyl\BlueprintFramework\Services\PlaceholderService;

class BlueprintPlaceholderService
{
  public function version(): string { return "::v"; }
  public function folder(): string { return "::f"; }
  public function installed(): string { return "NOTINSTALLED"; }
}
