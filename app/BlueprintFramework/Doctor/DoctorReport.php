<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

final class DoctorReport
{
    /** @var CheckResult[] */
    private array $results = [];

    public function add(CheckResult $result): void
    {
        $this->results[] = $result;
    }

    /** @return CheckResult[] */
    public function results(): array
    {
        return $this->results;
    }

    /** @return Issue[] */
    public function allIssues(): array
    {
        $all = [];
        foreach ($this->results as $result) {
            foreach ($result->issues() as $issue) {
                $all[] = $issue;
            }
        }
        return $all;
    }

    public function countBySeverity(Severity $severity): int
    {
        return count(array_filter($this->allIssues(), fn (Issue $i) => $i->severity === $severity));
    }

    public function hasErrors(): bool
    {
        foreach ($this->allIssues() as $issue) {
            if ($issue->severity->weight() >= Severity::ERROR->weight()) {
                return true;
            }
        }
        return false;
    }

    public function autoFixableIssues(): array
    {
        return array_values(array_filter($this->allIssues(), fn (Issue $i) => $i->autoFixable));
    }

    public function toArray(): array
    {
        return [
            'generated_at' => now()->toIso8601String(),
            'results' => array_map(fn (CheckResult $r) => $r->toArray(), $this->results),
            'summary' => [
                'info' => $this->countBySeverity(Severity::INFO),
                'warning' => $this->countBySeverity(Severity::WARNING),
                'error' => $this->countBySeverity(Severity::ERROR),
                'critical' => $this->countBySeverity(Severity::CRITICAL),
            ],
        ];
    }
}