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

    // $bp->licenseKey()
    // $bp->version()
    public
    function version(): string {
        $v = "([(pterodactylmarket_version)])";
        return $v;
    }
    
    public function licenseKey(): string{return "([(pterodactylmarket_transactionid)])";}
}
