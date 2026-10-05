<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

final class Issue
{
    public function __construct(
        public readonly Severity $severity,
        public readonly string $title,
        public readonly string $detail,
        public readonly ?string $fix = null,
        public readonly bool $autoFixable = false,
        public readonly ?string $context = null,
    ) {
    }

    public function toArray(): array
    {
        return [
            'severity' => $this->severity->value,
            'title' => $this->title,
            'detail' => $this->detail,
            'fix' => $this->fix,
            'auto_fixable' => $this->autoFixable,
            'context' => $this->context,
        ];
    }
}