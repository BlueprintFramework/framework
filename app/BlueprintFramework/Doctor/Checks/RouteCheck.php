<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class RouteCheck implements CheckInterface
{
    public function name(): string { return 'routes'; }
    public function title(): string { return 'Routes'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $routeFiles = [
            'routes/blueprint.php',
            'routes/blueprint/web.php',
            'routes/blueprint/client.php',
            'routes/blueprint/application.php',
        ];
        $missing = [];
        foreach ($routeFiles as $file) {
            if (!file_exists(base_path($file))) {
                $missing[] = $file;
            }
        }
        if (empty($missing)) {
            $r->ok('Route files', 'present');
        } else {
            $r->err('Route files', count($missing) . ' missing');
            $r->issue(new Issue(
                Severity::ERROR,
                'Blueprint route files missing',
                'Missing: ' . implode(', ', $missing),
                'Rerun the installer: blueprint -rerun-install',
            ));
        }

        try {
            $kernel = app(\Pterodactyl\Http\Kernel::class);
            $reflection = new \ReflectionClass($kernel);
            $prop = $reflection->getProperty('middlewareGroups');
            $prop->setAccessible(true);
            $groups = (array) $prop->getValue($kernel);

            $requiredGroups = ['blueprint', 'blueprint/api', 'blueprint/application-api', 'blueprint/client-api'];
            $missingGroups = [];
            foreach ($requiredGroups as $group) {
                if (!isset($groups[$group])) {
                    $missingGroups[] = $group;
                }
            }
            if (empty($missingGroups)) {
                $r->ok('Middleware', 'OK');
            } else {
                $r->warn('Middleware', count($missingGroups) . ' missing');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Blueprint middleware groups missing',
                    'Missing: ' . implode(', ', $missingGroups),
                    'Check app/Http/Kernel.php',
                ));
            }
        } catch (\Throwable $e) {
            $r->row('Middleware', 'unable to check', Severity::WARNING);
        }

        try {
            $routes = app('router')->getRoutes();
            $hasAdminExtensions = false;
            foreach ($routes as $route) {
                if (str_contains($route->uri(), 'admin/extensions')) {
                    $hasAdminExtensions = true;
                    break;
                }
            }
            if ($hasAdminExtensions) {
                $r->ok('Admin route', 'registered');
            } else {
                $r->warn('Admin route', 'missing');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'Admin extensions route not registered',
                    '/admin/extensions is not in the route list.',
                    'Clear route cache: php artisan route:clear',
                    true,
                ));
            }
        } catch (\Throwable $e) {
            $r->row('Admin route', 'unable to check', Severity::WARNING);
        }

        return $r;
    }
}