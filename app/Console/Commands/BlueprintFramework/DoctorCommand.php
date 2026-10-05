<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Doctor\DoctorReport;
use Pterodactyl\BlueprintFramework\Doctor\DoctorService;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class DoctorCommand extends Command
{
    protected $description = 'Run Blueprint diagnostics (doctor)';
    protected $signature = 'bp:doctor
        {--fix : Apply safe, deterministic fixes}
        {--json : Output machine-readable JSON}';

    public function __construct(private DoctorService $doctor)
    {
        parent::__construct();
    }

    public function handle(): int
    {
        $report = $this->doctor->run();

        if ($this->option('json')) {
            $this->line(json_encode($report->toArray(), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
            return $report->hasErrors() ? 1 : 0;
        }

        $this->renderReport($report);

        if ($this->option('fix')) {
            $this->newLine();
            $this->line('<options=bold>Fixing issues...</>');
            $this->newLine();

            $actions = $this->doctor->fix($report);

            if (empty($actions)) {
                $this->line('  <fg=gray>No automatically fixable issues found.</>');
            }
            foreach ($actions as $action) {
                $prefix = $action['ok'] ? '<fg=green>✓</>' : '<fg=red>✗</>';
                $line = "  {$prefix} {$action['label']}";
                if (!empty($action['detail'])) {
                    $line .= " <fg=gray>({$action['detail']})</>";
                }
                $this->line($line);
            }
        }

        return $report->hasErrors() ? 1 : 0;
    }

    private function renderReport(DoctorReport $report): void
    {
        $this->newLine();
        $this->line('<options=bold>Blueprint Doctor</>');
        $this->line('<fg=gray>────────────────────────────────</>');
        $this->newLine();

        foreach ($report->results() as $result) {
            $this->line('<options=bold>' . $result->title . '</>');
            foreach ($result->rows() as $row) {
                $marker = '  ';
                $markerColor = 'gray';
                if ($row['status'] === Severity::INFO) { $marker = '✓'; $markerColor = 'green'; }
                elseif ($row['status'] === Severity::WARNING) { $marker = '⚠'; $markerColor = 'yellow'; }
                elseif ($row['status'] === Severity::ERROR || $row['status'] === Severity::CRITICAL) { $marker = '✗'; $markerColor = 'red'; }

                $this->line(sprintf(
                    '  %-18s %-30s <fg=%s>%s</>',
                    $row['label'],
                    $row['value'],
                    $markerColor,
                    $marker,
                ));
            }

            foreach ($result->issues() as $issue) {
                $color = match ($issue->severity) {
                    Severity::INFO => 'gray',
                    Severity::WARNING => 'yellow',
                    Severity::ERROR, Severity::CRITICAL => 'red',
                };
                $this->newLine();
                $this->line("  <fg={$color}>[{$issue->severity->label()}]</> {$issue->title}");
                $this->line("  <fg=gray>{$issue->detail}</>");
                if ($issue->fix) {
                    $this->line('  <fg=gray>Suggested fix:</> ' . $issue->fix);
                }
            }

            $this->newLine();
        }

        $this->line('<fg=gray>────────────────────────────────</>');
        $this->line('Result:');
        $warnings = $report->countBySeverity(Severity::WARNING);
        $errors = $report->countBySeverity(Severity::ERROR) + $report->countBySeverity(Severity::CRITICAL);
        $this->line("  {$warnings} warning" . ($warnings === 1 ? '' : 's'));
        $this->line("  {$errors} error" . ($errors === 1 ? '' : 's'));
        $this->newLine();
    }
}