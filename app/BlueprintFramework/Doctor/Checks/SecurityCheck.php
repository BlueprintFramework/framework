<?php

namespace Pterodactyl\BlueprintFramework\Doctor\Checks;

use Pterodactyl\BlueprintFramework\Doctor\CheckInterface;
use Pterodactyl\BlueprintFramework\Doctor\CheckResult;
use Pterodactyl\BlueprintFramework\Doctor\Issue;
use Pterodactyl\BlueprintFramework\Doctor\Severity;

class SecurityCheck implements CheckInterface
{
    public function name(): string { return 'security'; }
    public function title(): string { return 'Security'; }

    public function run(): CheckResult
    {
        $r = new CheckResult($this->name(), $this->title());

        $debug = config('app.debug', false);
        if ($debug === false) {
            $r->ok('APP_DEBUG', 'false');
        } else {
            $r->err('APP_DEBUG', 'true');
            $r->issue(new Issue(
                Severity::CRITICAL,
                'APP_DEBUG is enabled',
                'Debug mode leaks sensitive data (DB credentials, API keys) in error pages.',
                'Set APP_DEBUG=false in .env and run: php artisan config:clear',
            ));
        }

        $env = (string) config('app.env', 'production');
        if ($env === 'production') {
            $r->ok('APP_ENV', $env);
        } else {
            $r->warn('APP_ENV', $env);
            $r->issue(new Issue(
                Severity::WARNING,
                'APP_ENV is not "production"',
                "Current value: {$env}",
                'Set APP_ENV=production in .env.',
            ));
        }

        $url = (string) config('app.url', '');
        if (str_starts_with($url, 'https://')) {
            $r->ok('APP_URL', 'HTTPS');
        } elseif (str_starts_with($url, 'http://')) {
            $r->warn('APP_URL', 'HTTP');
            $r->issue(new Issue(
                Severity::WARNING,
                'APP_URL does not use HTTPS',
                'Cookies and sessions may be transmitted in cleartext.',
                'Set APP_URL to an https:// URL in .env.',
            ));
        } else {
            $r->warn('APP_URL', $url ?: 'not set');
        }

        if (str_starts_with($url, 'https://')) {
            $secure = config('session.secure', false);
            if ($secure) {
                $r->ok('Secure cookies', 'enabled');
            } else {
                $r->warn('Secure cookies', 'disabled');
                $r->issue(new Issue(
                    Severity::WARNING,
                    'SESSION_SECURE_COOKIE is disabled',
                    'Cookies may be sent over HTTP.',
                    'Set SESSION_SECURE_COOKIE=true in .env.',
                ));
            }
        }

        $envFile = base_path('.env');
        if (file_exists($envFile)) {
            $perms = substr(sprintf('%o', fileperms($envFile)), -4);
            if (in_array($perms, ['0600', '0640', '0660'], true)) {
                $r->ok('.env perms', $perms);
            } else {
                $r->warn('.env perms', $perms);
                $r->issue(new Issue(
                    Severity::WARNING,
                    '.env file permissions are too permissive',
                    "Current: {$perms}, recommended: 0600 or 0640",
                    'Run: chmod 640 .env',
                    true, 
                ));
            }
        }

        return $r;
    }
}