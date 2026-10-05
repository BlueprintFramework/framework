<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintLibrary;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class VersionCheck implements CheckInterface
{
    public function __construct(
        private BlueprintPlaceholderService $placeholder,
        private BlueprintLibrary $blueprint,
    ) {
    }

    public function name(): string { return 'version'; }
    public function title(): string { return 'Version'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $current = $this->placeholder->version();
        $r->row('Current', $current ?: 'unknown', Severity::INFO);

        if ($current === 'rolling') {
            $r->issue(new Issue(
                Severity::INFO,
                'Running rolling version',
                'This is a development build. Do not use in production.',
            ));
            return $r;
        }

        $latest = $this->blueprint->dbGet('blueprint', 'internal:version:latest', null);
        if ($latest === null || $latest === 'unknown' || $latest === '') {
            $r->warn('Latest', 'unknown');
            $r->issue(new Issue(
                Severity::INFO,
                'Latest version unknown',
                'Could not determine the latest available version.',
                'Run: php artisan bp:version:cache',
                true,
            ));
            return $r;
        }

        $r->row('Latest', (string) $latest, Severity::INFO);

        if ($current === $latest) {
            $r->ok('Up to date', 'yes');
        } else {
            $r->warn('Up to date', 'no');
            $r->issue(new Issue(
                Severity::WARNING,
                'Blueprint is out of date',
                "Running {$current}, latest is {$latest}.",
                'Run: blueprint -upgrade',
            ));
        }

        return $r;
    }
}