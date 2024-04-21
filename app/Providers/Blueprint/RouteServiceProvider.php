<?php

namespace Pterodactyl\Providers\Blueprint;

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Middleware\AdminAuthenticate;
use Pterodactyl\Http\Middleware\RequireTwoFactorAuthentication;
use Illuminate\Foundation\Support\Providers\RouteServiceProvider as ServiceProvider;

class RouteServiceProvider extends ServiceProvider
{
    protected const FILE_PATH_REGEX = '/^\/api\/client\/servers\/([a-z0-9-]{36})\/files(\/?$|\/(.)*$)/i';

    /**
     * Define your route model bindings, pattern filters, etc.
     */
    public function boot(): void
    {
        $this->routes(function () {
            /* Blueprint web routes */
            Route::middleware('blueprint')
                ->prefix('/extensions')
                ->group(base_path('routes/blueprint/web.php'));

            /* Blueprint API routes */
            Route::middleware(['blueprint/api', RequireTwoFactorAuthentication::class])->group(function () {
                /* Application API */
                Route::middleware(['blueprint/application-api', 'throttle:api.application'])
                    ->prefix('/api/application/extensions')
                    ->scopeBindings()
                    ->group(base_path('routes/blueprint/application.php'));
                /* Client API */
                Route::middleware(['blueprint/client-api', 'throttle:api.client'])
                    ->prefix('/api/client/extensions')
                    ->scopeBindings()
                    ->group(base_path('routes/blueprint/client.php'));
            });

            /* Blueprint admin routes */
            Route::middleware(['web', 'auth.session', RequireTwoFactorAuthentication::class, AdminAuthenticate::class])
                ->prefix('/admin')
                ->group(base_path('routes/blueprint.php'));
        });
    }
}
