<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintLibrary;

class CacheCheck implements CheckInterface
{
    public function __construct(private BlueprintLibrary $blueprint) {}

    public function name(): string { return 'cache'; }
    public function title(): string { return 'Cache'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $cache = $this->blueprint->dbGet('blueprint', 'internal:cache', null);
        if ($cache !== null) {
            $r->ok('Blueprint cache', "v={$cache}");
        } else {
            $r->warn('Blueprint cache', 'Missing');
            $r->issue(new Issue(
                Severity::WARNING,
                'Blueprint cache not initialised',
                'Extensions use the cache value to bust stylesheet/script cache.',
                'Run: php artisan bp:cache',
                true,
            ));
        }

        $configCache = base_path('bootstrap/cache/config.php');
        $envFile = base_path('.env');
        if (file_exists($configCache) && file_exists($envFile)) {
            if (filemtime($configCache) < filemtime($envFile)) {
                $r->warn('Config cache', 'Stale');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Configuration cache is stale',
                    '.env was modified after the config cache was built.',
                    'Run: php artisan config:clear && php artisan config:cache',
                    true,
                ));
            } else {
                $r->ok('Config cache', 'Fresh');
            }
        } else {
            $r->ok('Config cache', 'Not cached');
        }

        return $r;
    }
}