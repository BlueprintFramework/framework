<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class PermissionsCheck implements CheckInterface
{
    public function name(): string { return 'permissions'; }
    public function title(): string { return 'Permissions'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $writable = [
            'storage' => storage_path(),
            'storage/logs' => storage_path('logs'),
            'storage/framework' => storage_path('framework'),
            'storage/framework/cache' => storage_path('framework/cache'),
            'storage/framework/sessions' => storage_path('framework/sessions'),
            'storage/framework/views' => storage_path('framework/views'),
            'bootstrap/cache' => base_path('bootstrap/cache'),
        ];

        $notWritable = [];
        foreach ($writable as $label => $path) {
            if (!is_dir($path)) {
                @mkdir($path, 0755, true);
            }
            if (!is_writable($path)) {
                $notWritable[] = $label;
            }
        }

        if (empty($notWritable)) {
            $r->ok('Writable dirs', 'OK');
        } else {
            $r->err('Writable dirs', count($notWritable) . ' not writable');
            $r->issue(new Issue(
                Severity::ERROR,
                'Some directories are not writable',
                'Not writable: ' . implode(', ', $notWritable),
                'Fix with: chown -R www-data:www-data storage bootstrap/cache && chmod -R 775 storage bootstrap/cache',
                true, 
            ));
        }

        $readable = [
            '.env' => base_path('.env'),
        ];
        $notReadable = [];
        foreach ($readable as $label => $path) {
            if (!is_readable($path)) {
                $notReadable[] = $label;
            }
        }
        if (empty($notReadable)) {
            $r->ok('Readable files', 'OK');
        } else {
            $r->err('Readable files', implode(', ', $notReadable));
            $r->issue(new Issue(
                Severity::ERROR,
                'Some files are not readable',
                'Not readable: ' . implode(', ', $notReadable),
                'Fix file ownership and permissions.',
            ));
        }

        $logDir = storage_path('logs');
        if (is_dir($logDir)) {
            $size = 0;
            foreach (glob($logDir . '/*.log') as $file) {
                $size += (int) @filesize($file);
            }
            $mb = round($size / 1024 / 1024, 1);
            $r->row('Log size', "{$mb} MB", $mb > 200 ? Severity::WARNING : Severity::INFO);
            if ($mb > 200) {
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Log directory is large',
                    "The logs directory is {$mb} MB. This can fill up the disk.",
                    'Truncate the log files: truncate -s 0 storage/logs/*.log',
                    true,  
                ));
            }
        }

        return $r;
    }
}