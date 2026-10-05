<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

enum Severity: string
{
    case INFO = 'info';
    case WARNING = 'warning';
    case ERROR = 'error';
    case CRITICAL = 'critical';

    public function label(): string
    {
        return strtoupper($this->value);
    }

    public function symbol(): string
    {
        return match ($this) {
            self::INFO => '·',
            self::WARNING => '!',
            self::ERROR, self::CRITICAL => '×',
        };
    }

    public function weight(): int
    {
        return match ($this) {
            self::INFO => 0,
            self::WARNING => 1,
            self::ERROR => 2,
            self::CRITICAL => 3,
        };
    }
}