<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class PterodactylCheck implements CheckInterface
{
    public function name(): string { return 'pterodactyl'; }
    public function title(): string { return 'Pterodactyl'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $version = config('app.version', 'unknown');
        $r->row('Version', (string) $version, Severity::INFO);

        if ($version === 'unknown' || $version === '') {
            $r->issue(new Issue(
                Severity::WARNING,
                'Pterodactyl version unknown',
                'APP_VERSION is not set in the environment.',
                'Set APP_VERSION in your .env file.',
            ));
        } elseif (version_compare($version, '1.10.0', '<')) {
            $r->issue(new Issue(
                Severity::WARNING,
                'Old Pterodactyl version',
                "Blueprint is designed for Pterodactyl 1.10+. Detected {$version}.",
                'Upgrade Pterodactyl.',
            ));
        }

        if (!file_exists(base_path('artisan'))) {
            $r->issue(new Issue(
                Severity::CRITICAL,
                'Not a Laravel/Pterodactyl installation',
                'The artisan file is missing from the base path.',
            ));
        }

        return $r;
    }
}