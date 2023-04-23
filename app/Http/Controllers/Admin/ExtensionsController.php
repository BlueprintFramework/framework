<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Services\Helpers\BlueprintVariableService;

class ExtensionsController extends Controller
{
    /**
     * ExtensionsController constructor.
     */
    public function __construct(private SoftwareVersionService $version, private ViewFactory $view, private BlueprintVariableService $bp)
    {
    }

    /**
     * Return the admin index view.
     */
    public function index(): View
    {
        // Onboarding check.
        if(shell_exec("cd /var/www/pterodactyl; cat .blueprint/.flags/onboarding.md" == "*blueprint*")) {
            $onboarding = true;
        }
        return $this->view->make('admin.extensions', [
            'version' => $this->version,
            'bp' => $this->bp,
            'root' => "/admin/extensions",

            'onboarding' => $onboarding
        ]);
    }
}
