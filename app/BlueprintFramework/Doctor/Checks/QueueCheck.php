<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Illuminate\Support\Facades\DB;
use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class QueueCheck implements CheckInterface
{
    public function name(): string { return 'queue'; }
    public function title(): string { return 'Queue'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $driver = (string) config('queue.default', 'sync');
        if ($driver !== 'sync') {
            $r->ok('Driver', $driver);
        } else {
            $r->warn('Driver', $driver);
            $r->issue(new Issue(
                Severity::WARNING,
                'Queue driver is "sync"',
                'Jobs run immediately instead of being queued. Long jobs (backups, installs) can timeout.',
                'Set QUEUE_CONNECTION=redis in .env.',
            ));
        }

        try {
            $failed = DB::table('failed_jobs')->count();
            if ($failed === 0) {
                $r->ok('Failed jobs', '0');
            } else {
                $r->warn('Failed jobs', (string) $failed);
                $r->issue(new Issue(
                    Severity::WARNING,
                    "{$failed} failed jobs",
                    'Failed jobs usually mean the queue worker is not running or a job crashed.',
                    'Run: php artisan queue:failed',
                ));
            }
        } catch (\Throwable $e) {
            $r->warn('Failed jobs', 'unable to check');
        }

        try {
            $hasWorker = false;
            if (function_exists('shell_exec')) {
                $out = @shell_exec('ps aux 2>/dev/null | grep -E "queue:(work|listen)" | grep -v grep');
                $hasWorker = !empty(trim((string) $out));
            }
            if ($hasWorker) {
                $r->ok('Worker', 'running');
            } else {
                $r->warn('Worker', 'not detected');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Queue worker not detected',
                    'No `queue:work` or `queue:listen` process was found.',
                    'Start the worker: php artisan queue:work --daemon',
                ));
            }
        } catch (\Throwable $e) {
            $r->row('Worker', 'unable to check', Severity::WARNING);
        }

        return $r;
    }
}