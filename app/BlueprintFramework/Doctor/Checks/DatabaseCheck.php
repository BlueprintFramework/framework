<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class DatabaseCheck implements CheckInterface
{
    public function name(): string { return 'database'; }
    public function title(): string { return 'Database'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        try {
            DB::connection()->getPdo();
            $r->ok('Connection', 'OK');
        } catch (\Throwable $e) {
            $r->err('Connection', 'Failed');
            $r->issue(new Issue(
                Severity::CRITICAL,
                'Database connection failed',
                $e->getMessage(),
                'Check your .env database credentials.',
            ));
            return $r;
        }

        $required = ['settings', 'extension_cached_metadata'];
        $missing = [];
        foreach ($required as $table) {
            if (!Schema::hasTable($table)) {
                $missing[] = $table;
            }
        }

        if (empty($missing)) {
            $r->ok('Schema', 'OK');
        } else {
            $r->err('Schema', 'Missing: ' . implode(', ', $missing));
            $r->issue(new Issue(
                Severity::ERROR,
                'Required database tables missing',
                'Missing: ' . implode(', ', $missing),
                'Run: php artisan migrate --force',
                true,
            ));
        }

        try {
            $pending = $this->pendingMigrationCount();
            if ($pending === 0) {
                $r->ok('Migrations', 'Up to date');
            } else {
                $r->warn('Migrations', "{$pending} pending");
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Pending database migrations',
                    "{$pending} Laravel migrations have not been run.",
                    'Run: php artisan migrate --force',
                    true,
                ));
            }
        } catch (\Throwable $e) {
            $r->warn('Migrations', 'unable to determine');
        }

        return $r;
    }

    private function pendingMigrationCount(): int
    {
        try {
            $migrator = app('migrator');
            $ran = $migrator->getRepository()->getRan();
            $files = array_map(
                fn ($f) => basename($f),
                array_keys($migrator->getMigrationFiles([database_path('migrations')]))
            );
            return count(array_diff($files, $ran));
        } catch (\Throwable $e) {
            return 0;
        }
    }
}