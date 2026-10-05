<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class StorageCheck implements CheckInterface
{
    public function name(): string { return 'storage'; }
    public function title(): string { return 'Storage'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $publicStorage = public_path('storage');
        if (is_link($publicStorage) || is_dir($publicStorage)) {
            $r->ok('public/storage', 'linked');
        } else {
            $r->warn('public/storage', 'missing');
            $r->issue(new Issue(
                Severity::WARNING,
                'public/storage link is missing',
                'The Laravel storage link has not been created.',
                'Run: php artisan storage:link',
                true, 
            ));
        }

        $bpPublic = public_path('extensions/blueprint');
        if (is_link($bpPublic) || is_dir($bpPublic)) {
            $r->ok('Blueprint public', 'linked');
        } else {
            $r->warn('Blueprint public', 'missing');
            $r->issue(new Issue(
                Severity::WARNING,
                'Blueprint public link is missing',
                'The Blueprint extension public directory is not linked.',
                'Rerun the installer: blueprint -rerun-install',
                true,  
            ));
        }

        $schedules = app_path('BlueprintFramework/Schedules');
        if (is_dir($schedules)) {
            $r->ok('Schedules dir', 'exists');
        } else {
            $r->warn('Schedules dir', 'missing');
            $r->issue(new Issue(
                Severity::WARNING,
                'Schedules directory missing',
                'Extension schedules cannot be registered.',
                'Create the directory: mkdir -p app/BlueprintFramework/Schedules',
                true,  
            ));
        }

        try {
            $disks = config('filesystems.disks', []);
            $hasBlueprintDisk = false;
            foreach (array_keys($disks) as $name) {
                if (str_starts_with((string) $name, 'blueprint')) {
                    $hasBlueprintDisk = true;
                    break;
                }
            }
            if ($hasBlueprintDisk) {
                $r->ok('ExtensionFS disks', 'configured');
            } else {
                $r->warn('ExtensionFS disks', 'none');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'No Blueprint filesystem disks configured',
                    'ExtensionFS disks start with "blueprint".',
                    'Check .blueprint/extensions/blueprint/private/extensionfs.php',
                ));
            }
        } catch (\Throwable $e) {
            $r->row('ExtensionFS disks', 'unable to check', Severity::WARNING);
        }

        return $r;
    }
}