<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintLibrary;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Symfony\Component\Yaml\Yaml;

class ExtensionCheck implements CheckInterface
{
    public function __construct(
        private BlueprintLibrary $blueprint,
        private BlueprintPlaceholderService $placeholder,
    ) {
    }

    public function name(): string { return 'extensions'; }
    public function title(): string { return 'Extensions'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $current = $this->placeholder->version();
        $installed = array_filter($this->blueprint->extensions());

        if (empty($installed)) {
            $r->row('Installed', 'None', Severity::INFO);
            return $r;
        }

        foreach ($installed as $id) {
            $base = base_path(".blueprint/extensions/{$id}");
            $manifest = "{$base}/private/.store/conf.yml";

            if (!is_dir($base)) {
                $r->err($id, 'Directory missing');
                $r->issue(new Issue(
                    Severity::ERROR,
                    "Extension '{$id}' directory missing",
                    "Registered in installed_extensions but no folder at {$base}.",
                    "Reinstall the extension or remove its entry.",
                ));
                continue;
            }

            if (!file_exists($manifest)) {
                $r->err($id, 'Invalid manifest');
                $r->issue(new Issue(
                    Severity::ERROR,
                    "Extension '{$id}' has no manifest",
                    "Expected manifest at {$manifest}.",
                    "Reinstall the extension.",
                ));
                continue;
            }

            try {
                $conf = Yaml::parseFile($manifest);
            } catch (\Throwable $e) {
                $r->err($id, 'Unreadable manifest');
                $r->issue(new Issue(
                    Severity::ERROR,
                    "Extension '{$id}' manifest unreadable",
                    $e->getMessage(),
                ));
                continue;
            }

            $info = $conf['info'] ?? [];
            $version = $info['version'] ?? 'unknown';
            $target = $info['target'] ?? '';

            $compatible = true;
            $reason = '';
            if ($target !== '' && $current !== 'rolling' && $target !== $current) {
                if (version_compare($target, $current, '<')) {
                    $compatible = false;
                    $reason = "targets {$target}, running {$current}";
                }
            }

            if ($compatible) {
                $r->ok($id, $version);
            } else {
                $r->warn($id, $version);
                $r->issue(new Issue(
                    Severity::WARNING,
                    "Extension '{$id}' may be incompatible",
                    $reason,
                    "Update '{$id}' or run with --force.",
                    false,
                    $id,
                ));
            }

            $requires = $conf['requires'] ?? [];
            foreach ((array) $requires as $dep => $constraint) {
                if (!is_string($dep)) {
                    continue;
                }
                if (str_starts_with($dep, 'blueprint/')) {
                    $satisfied = $this->satisfiesBlueprintConstraint((string) $constraint, $current);
                    if (!$satisfied) {
                        $r->issue(new Issue(
                            Severity::ERROR,
                            "Extension '{$id}' requires {$dep} {$constraint}",
                            "Current Blueprint version is {$current}.",
                            "Update Blueprint or the extension.",
                            false,
                            $id,
                        ));
                    }
                } else {
                    
                    $depId = str_replace('extension/', '', $dep);
                    if (!$this->blueprint->extension($depId)) {
                        $r->issue(new Issue(
                            Severity::ERROR,
                            "Extension '{$id}' is missing a dependency",
                            "Requires {$dep} {$constraint} which is not installed.",
                            "Install '{$depId}'.",
                            false,
                            $id,
                        ));
                    }
                }
            }
        }

        return $r;
    }

    private function satisfiesBlueprintConstraint(string $constraint, string $version): bool
    {
        if ($version === 'rolling') {
            return true;
        }

        if (preg_match('/^(>=|<=|>|<|=)?\s*(.+)$/', $constraint, $m)) {
            $op = $m[1] ?: '>=';
            return version_compare($version, trim($m[2]), $op);
        }
        return true;
    }
}