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

    // $bp->version()
    public
    function version(): string {
        $v = "&bp.version&";
        return $v;
    }
}
