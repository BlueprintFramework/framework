<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary;

class BaseController extends Controller
{
    /**
     * BaseController constructor.
     */
    public function __construct(
        private SoftwareVersionService $version,
        private ViewFactory $view,
        private BlueprintExtensionLibrary $blueprint
    )
    {
    }

    /**
     * Return the admin index view.
     */
    public function index(): View
    {
        return $this->view->make('admin.index', [
            'version' => $this->version,
            'blueprint' => $this->blueprint
        ]);
    }
}
