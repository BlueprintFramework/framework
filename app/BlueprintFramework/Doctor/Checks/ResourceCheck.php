<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class ResourceCheck implements CheckInterface
{
    public function name(): string { return 'resources'; }
    public function title(): string { return 'Resources'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $free = @disk_free_space(base_path());
        $total = @disk_total_space(base_path());
        if ($free !== false && $total !== false && $total > 0) {
            $freeGb = round($free / 1024 / 1024 / 1024, 2);
            $totalGb = round($total / 1024 / 1024 / 1024, 2);

            $status = Severity::INFO;
            if ($freeGb < 1) {
                $status = Severity::ERROR;
            } elseif ($freeGb < 5) {
                $status = Severity::WARNING;
            }

            $r->row('Disk free', "{$freeGb} GB / {$totalGb} GB", $status);

            if ($freeGb < 1) {
                $r->issue(new Issue(
                    Severity::ERROR,
                    'Very low disk space',
                    "Only {$freeGb} GB free. Panels typically need at least 1 GB free.",
                    'Free disk space before continuing.',
                    true,  
                ));
            } elseif ($freeGb < 5) {
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Low disk space',
                    "Only {$freeGb} GB free.",
                    'Consider freeing disk space.',
                    true,  
                ));
            }
        } else {
            $r->row('Disk free', 'unable to determine', Severity::INFO);
        }

        $memoryLimit = ini_get('memory_limit');
        $r->row('PHP memory', $memoryLimit ?: 'unknown', Severity::INFO);

        $maxExec = ini_get('max_execution_time');
        $r->row('PHP max exec', $maxExec ?: 'unknown', Severity::INFO);
        if ((int) $maxExec > 0 && (int) $maxExec < 60) {
            $r->issue(new Issue(
                Severity::WARNING,
                'Low max_execution_time',
                "Current value is {$maxExec}s. Long operations may be killed.",
                'Set max_execution_time=300 or higher in php.ini.',
            ));
        }

        return $r;
    }
}