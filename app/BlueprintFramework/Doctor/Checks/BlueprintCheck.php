<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintLibrary;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintCheck implements CheckInterface
{
    public function __construct(
        private BlueprintPlaceholderService $placeholder,
        private BlueprintLibrary $blueprint,
    ) {
    }

    public function name(): string { return 'blueprint'; }
    public function title(): string { return 'Blueprint'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $version = $this->placeholder->version();
        if ($version === 'unknown' || $version === '') {
            $r->err('Version', 'unknown');
            $r->issue(new Issue(
                Severity::CRITICAL,
                'Blueprint version could not be determined',
                'The BlueprintPlaceholderService did not return a version.',
                'Rerun the installer: blueprint -rerun-install',
            ));
        } else {
            $r->ok('Version', $version);
        }

        $isInstalled = file_exists(base_path('.blueprint/extensions/blueprint/private/db/is_installed'));
        if ($isInstalled) {
            $r->ok('Installation', 'Valid');
        } else {
            $r->err('Installation', 'Incomplete');
            $r->issue(new Issue(
                Severity::ERROR,
                'Blueprint installation incomplete',
                'The is_installed marker file is missing.',
                'Run: blueprint -rerun-install',
                true,
            ));
        }

        $seeded = $this->blueprint->dbGet('blueprint', 'internal:seed', false);
        if ($seeded) {
            $r->ok('Configuration', 'Valid');
        } else {
            $r->warn('Configuration', 'Not seeded');
            $r->issue(new Issue(
                Severity::WARNING,
                'Blueprint configuration not seeded',
                'Database seed records are missing.',
                'Run: php artisan db:seed --class=BlueprintSeeder --force',
                true,
            ));
        }

        return $r;
    }
}