<?php

namespace Pterodactyl\BlueprintFramework\Services\PlaceholderService;

class BlueprintPlaceholderService
{
  public function version(): string { return "::v"; }
  public function folder(): string { return base_path(); }
  public function installed(): string { return "NOTINSTALLED"; }
  public function api_url(): string { return "http://api.blueprint.zip:50000"; }
}
