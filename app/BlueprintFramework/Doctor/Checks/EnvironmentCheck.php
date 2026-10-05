<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class EnvironmentCheck implements CheckInterface
{
    public function name(): string { return 'environment'; }
    public function title(): string { return 'Environment'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $php = PHP_VERSION;
        if (version_compare($php, '8.1.0', '>=')) {
            $r->ok('PHP', $php);
        } else {
            $r->err('PHP', $php);
            $r->issue(new Issue(
                Severity::ERROR,
                'Unsupported PHP version',
                "Blueprint requires PHP >= 8.1, found {$php}.",
                'Upgrade PHP to 8.1 or newer.',
            ));
        }

        $node = $this->capture('node -v');
        if ($node) {
            $major = (int) ltrim(explode('.', trim($node))[0], 'v');
            if ($major >= 22) {
                $r->ok('Node', trim($node));
            } else {
                $r->warn('Node', trim($node));
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Outdated Node.js',
                    "Blueprint requires Node >= 22, found {$node}.",
                    'Upgrade Node.js.',
                ));
            }
        } else {
            $r->warn('Node', 'not found');
            $r->issue(new Issue(
                Severity::WARNING,
                'Node.js not found',
                'Node.js is required for building panel assets.',
                'Install Node.js >= 22.',
            ));
        }

        $yarn = $this->capture('yarn -v');
        $r->row('Yarn', $yarn ?: 'not found', $yarn ? Severity::INFO : Severity::WARNING);

        return $r;
    }

    private function capture(string $cmd): string
    {
        $out = @shell_exec($cmd . ' 2>/dev/null');
        return $out ? trim((string) $out) : '';
    }
}