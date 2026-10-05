<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

final class CheckResult
{
    /** @var array<int,array{label:string,value:string,status:?Severity}> */
    private array $rows = [];

    /** @var Issue[] */
    private array $issues = [];

    public function __construct(
        public readonly string $name,
        public readonly string $title,
    ) {
    }

    public function row(string $label, string $value, ?Severity $status = null): self
    {
        $this->rows[] = ['label' => $label, 'value' => $value, 'status' => $status];
        return $this;
    }

    public function issue(Issue $issue): self
    {
        $this->issues[] = $issue;
        return $this;
    }

    public function ok(string $label, string $value): self
    {
        return $this->row($label, $value, Severity::INFO);
    }

    public function warn(string $label, string $value): self
    {
        return $this->row($label, $value, Severity::WARNING);
    }

    public function err(string $label, string $value): self
    {
        return $this->row($label, $value, Severity::ERROR);
    }

    public function rows(): array
    {
        return $this->rows;
    }

    /** @return Issue[] */
    public function issues(): array
    {
        return $this->issues;
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'title' => $this->title,
            'rows' => array_map(fn ($r) => [
                'label' => $r['label'],
                'value' => $r['value'],
                'status' => $r['status']?->value,
            ], $this->rows),
            'issues' => array_map(fn (Issue $i) => $i->toArray(), $this->issues),
        ];
    }
}