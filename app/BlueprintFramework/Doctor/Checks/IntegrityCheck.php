<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class IntegrityCheck implements CheckInterface
{
    public function name(): string { return 'integrity'; }
    public function title(): string { return 'Integrity'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $required = [
            'blueprint.sh',
            'app/BlueprintFramework/GetExtensionSchedules.php',
            'app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php',
            'app/BlueprintFramework/Libraries/ExtensionLibrary/BlueprintBaseLibrary.php',
            '.blueprint/extensions/blueprint/private/db/installed_extensions',
            '.blueprint/extensions/blueprint/private/db/version',
            'scripts/libraries/lock.sh',
            'scripts/libraries/logFormat.sh',
        ];

        $missing = [];
        foreach ($required as $path) {
            if (!file_exists(base_path($path))) {
                $missing[] = $path;
            }
        }

        if (empty($missing)) {
            $r->ok('Files', 'OK');
        } else {
            $r->err('Files', count($missing) . ' missing');
            $r->issue(new Issue(
                Severity::ERROR,
                'Required Blueprint files missing',
                'Missing: ' . implode(', ', $missing),
                'Rerun the installer: blueprint -rerun-install',
            ));
        }

        $protected = [
            'app/Console/Kernel.php',
            'app/Providers/AppServiceProvider.php',
            'resources/views/layouts/admin.blade.php',
            'resources/views/templates/wrapper.blade.php',
        ];
        $modified = [];
        foreach ($protected as $path) {
            $full = base_path($path);
            if (!file_exists($full)) {
                $modified[] = $path;
                continue;
            }
            $content = (string) file_get_contents($full);
            if (!str_contains($content, 'Blueprint') && !str_contains($content, 'blueprint')) {
                $modified[] = $path;
            }
        }
        if (empty($modified)) {
            $r->ok('Protected files', 'OK');
        } else {
            $r->warn('Protected files', count($modified) . ' suspicious');
            $r->issue(new Issue(
                Severity::WARNING,
                'Blueprint hook removal detected',
                'Files: ' . implode(', ', $modified),
                'Rerun: blueprint -upgrade',
            ));
        }

        $metadataOk = true;
        foreach (['internal:seed', 'internal:cache'] as $key) {
            // I hate this :,D
        }

        return $r;
    }
}