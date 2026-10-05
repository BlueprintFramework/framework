<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

use Pterodactyl\BlueprintFramework\Doctor\Checks\BlueprintCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\CacheCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\ConfigurationCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\DatabaseCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\EnvironmentCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\ExtensionCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\IntegrityCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\LogCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\PermissionsCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\PterodactylCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\QueueCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\ResourceCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\RouteCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\SecurityCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\StorageCheck;
use Pterodactyl\BlueprintFramework\Doctor\Checks\VersionCheck;
use Illuminate\Support\Facades\Artisan;

class DoctorService
{
    /** @var CheckInterface[] */
    private array $checks;

    public function __construct(
        EnvironmentCheck $environment,
        BlueprintCheck $blueprint,
        PterodactylCheck $pterodactyl,
        ConfigurationCheck $configuration,
        DatabaseCheck $database,
        CacheCheck $cache,
        ExtensionCheck $extensions,
        IntegrityCheck $integrity,
        QueueCheck $queue,
        PermissionsCheck $permissions,
        StorageCheck $storage,
        LogCheck $logs,
        SecurityCheck $security,
        RouteCheck $routes,
        VersionCheck $version,
        ResourceCheck $resources,
    ) {
        $this->checks = [
            $environment,
            $blueprint,
            $pterodactyl,
            $configuration,
            $database,
            $cache,
            $extensions,
            $integrity,
            $queue,
            $permissions,
            $storage,
            $logs,
            $security,
            $routes,
            $version,
            $resources,
        ];
    }

    public function run(): DoctorReport
    {
        $report = new DoctorReport();
        foreach ($this->checks as $check) {
            try {
                $report->add($check->run());
            } catch (\Throwable $e) {
                $result = new CheckResult($check->name(), $check->title());
                $result->err('Check failed', $e->getMessage());
                $result->issue(new Issue(
                    Severity::ERROR,
                    "Check '{$check->name()}' crashed",
                    $e->getMessage(),
                ));
                $report->add($result);
            }
        }
        return $report;
    }

    /**
     * @return array<int,array{label:string,ok:bool,detail:?string}>
     */
    public function fix(DoctorReport $report): array
    {
        $actions = [];

        foreach ($report->autoFixableIssues() as $issue) {
            $action = $this->applyFix($issue);
            if ($action !== null) {
                $actions[] = $action;
            } else {
                $actions[] = [
                    'label' => $issue->title,
                    'ok' => false,
                    'detail' => 'Manual intervention required.',
                ];
            }
        }

        return $actions;
    }

    private function applyFix(Issue $issue): ?array
    {
        $title = $issue->title;

        if (str_contains($title, 'Configuration cache')) {
            try {
                Artisan::call('config:clear');
                Artisan::call('config:cache');
                return ['label' => 'Rebuilt configuration cache', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Rebuild configuration cache', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Blueprint cache')) {
            try {
                Artisan::call('bp:cache');
                return ['label' => 'Rebuilt Blueprint cache', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Rebuild Blueprint cache', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Pending database migrations')) {
            try {
                Artisan::call('migrate', ['--force' => true]);
                return ['label' => 'Applied pending database migrations', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Apply pending database migrations', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'installation incomplete')) {
            $path = base_path('.blueprint/extensions/blueprint/private/db/is_installed');
            $dir = dirname($path);
            if (!is_dir($dir)) {
                @mkdir($dir, 0755, true);
            }
            if (@touch($path)) {
                return ['label' => 'Recreated is_installed marker', 'ok' => true, 'detail' => null];
            }
            return ['label' => 'Recreate is_installed marker', 'ok' => false, 'detail' => 'Permission denied'];
        }

        if (str_contains($title, 'configuration not seeded')) {
            try {
                Artisan::call('db:seed', ['--class' => 'BlueprintSeeder', '--force' => true]);
                return ['label' => 'Seeded Blueprint configuration', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Seed Blueprint configuration', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'public/storage link')) {
            try {
                Artisan::call('storage:link');
                return ['label' => 'Created public/storage link', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Create public/storage link', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Admin extensions route not registered')) {
            try {
                Artisan::call('route:clear');
                return ['label' => 'Cleared route cache', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Clear route cache', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Latest version unknown')) {
            try {
                Artisan::call('bp:version:cache');
                return ['label' => 'Cached latest Blueprint version', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Cache latest Blueprint version', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Log directory is large')) {
            try {
                $logs = glob(storage_path('logs/*.log'));
                $bytes = 0;
                $count = 0;
                foreach ($logs as $log) {
                    $bytes += (int) @filesize($log);
                    if (@file_put_contents($log, '') !== false) {
                        $count++;
                    }
                }
                $mb = round($bytes / 1024 / 1024, 1);
                return [
                    'label' => "Truncated {$count} log file(s) ({$mb} MB freed)",
                    'ok' => true,
                    'detail' => null,
                ];
            } catch (\Throwable $e) {
                return ['label' => 'Truncate log files', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'directories are not writable')) {
            if (PHP_OS_FAMILY === 'Windows') {
                return ['label' => 'Fix directory permissions', 'ok' => false, 'detail' => 'Not supported on Windows'];
            }
            try {
                $paths = [
                    storage_path(),
                    storage_path('logs'),
                    storage_path('framework'),
                    storage_path('framework/cache'),
                    storage_path('framework/sessions'),
                    storage_path('framework/views'),
                    base_path('bootstrap/cache'),
                ];
                $fixed = 0;
                foreach ($paths as $p) {
                    if (is_dir($p)) {
                        if (@chmod($p, 0775)) {
                            $fixed++;
                        }
                    }
                }
                return [
                    'label' => "Applied chmod 775 to {$fixed} directory/ies",
                    'ok' => true,
                    'detail' => null,
                ];
            } catch (\Throwable $e) {
                return ['label' => 'Apply chmod 775', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Blueprint public link is missing')) {
            try {
                $source = base_path('.blueprint/extensions/blueprint/public');
                $target = public_path('extensions/blueprint');
                if (!is_dir($source)) {
                    return ['label' => 'Create Blueprint public link', 'ok' => false, 'detail' => 'Source missing: ' . $source];
                }
                if (is_link($target)) {
                    @unlink($target);
                } elseif (is_dir($target)) {
                    $items = @scandir($target);
                    if ($items !== false && count($items) > 2) {
                        return ['label' => 'Create Blueprint public link', 'ok' => false, 'detail' => 'Target directory is not empty'];
                    }
                    @rmdir($target);
                }
                @mkdir(dirname($target), 0755, true);
                if (@symlink($source, $target)) {
                    return ['label' => 'Created Blueprint public symlink', 'ok' => true, 'detail' => null];
                }
                return ['label' => 'Create Blueprint public symlink', 'ok' => false, 'detail' => 'symlink() failed'];
            } catch (\Throwable $e) {
                return ['label' => 'Create Blueprint public symlink', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, 'Schedules directory missing')) {
            try {
                $path = app_path('BlueprintFramework/Schedules');
                if (@mkdir($path, 0755, true) || is_dir($path)) {
                    return ['label' => 'Created Schedules directory', 'ok' => true, 'detail' => null];
                }
                return ['label' => 'Create Schedules directory', 'ok' => false, 'detail' => 'mkdir() failed'];
            } catch (\Throwable $e) {
                return ['label' => 'Create Schedules directory', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        if (str_contains($title, '.env file permissions are too permissive')) {
            if (PHP_OS_FAMILY === 'Windows') {
                return ['label' => 'Fix .env permissions', 'ok' => false, 'detail' => 'Not supported on Windows'];
            }
            $envFile = base_path('.env');
            if (!file_exists($envFile)) {
                return ['label' => 'Fix .env permissions', 'ok' => false, 'detail' => '.env not found'];
            }
            if (@chmod($envFile, 0640)) {
                return ['label' => 'Set .env permissions to 0640', 'ok' => true, 'detail' => null];
            }
            return ['label' => 'Set .env permissions', 'ok' => false, 'detail' => 'chmod() failed'];
        }

        if (str_contains($title, 'Low disk space') || str_contains($title, 'Very low disk space')) {
            try {
                Artisan::call('cache:clear');
                Artisan::call('view:clear');
                Artisan::call('route:clear');
                return ['label' => 'Cleared caches to free disk space', 'ok' => true, 'detail' => null];
            } catch (\Throwable $e) {
                return ['label' => 'Clear caches', 'ok' => false, 'detail' => $e->getMessage()];
            }
        }

        return null;
    }
}