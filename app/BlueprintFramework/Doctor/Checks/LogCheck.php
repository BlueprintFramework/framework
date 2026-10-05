<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class LogCheck implements CheckInterface
{
    public function name(): string { return 'logs'; }
    public function title(): string { return 'Logs'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $logFile = storage_path('logs/laravel.log');
        if (!file_exists($logFile)) {
            $r->row('Laravel log', 'not present', Severity::INFO);
            return $r;
        }

        $size = (int) @filesize($logFile);
        $r->row('Laravel log', round($size / 1024, 1) . ' KB', Severity::INFO);

        $lines = @file($logFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        if ($lines === false) {
            $r->warn('Recent errors', 'unable to read');
            return $r;
        }
        $tail = array_slice($lines, -500);

        $errorCount = 0;
        $criticalCount = 0;
        $lastError = null;
        foreach ($tail as $line) {
            if (str_contains($line, '.ERROR')) {
                $errorCount++;
                $lastError = $line;
            }
            if (str_contains($line, '.CRITICAL') || str_contains($line, '.EMERGENCY')) {
                $criticalCount++;
                $lastError = $line;
            }
        }

        if ($criticalCount > 0) {
            $r->err('Recent errors', "{$criticalCount} critical");
            $r->issue(new Issue(
                Severity::ERROR,
                'Critical errors in recent logs',
                'Last: ' . mb_substr((string) $lastError, 0, 200),
                'Review storage/logs/laravel.log',
            ));
        } elseif ($errorCount > 0) {
            $r->warn('Recent errors', "{$errorCount} errors");
            $r->issue(new Issue(
                Severity::WARNING,
                'Errors in recent logs',
                'Last: ' . mb_substr((string) $lastError, 0, 200),
                'Review storage/logs/laravel.log',
            ));
        } else {
            $r->ok('Recent errors', 'none');
        }

        $bpLog = base_path('.blueprint/extensions/blueprint/private/debug/logs.txt');
        if (file_exists($bpLog)) {
            $bpSize = (int) @filesize($bpLog);
            $r->row('Blueprint log', round($bpSize / 1024, 1) . ' KB', Severity::INFO);
        }

        return $r;
    }
}