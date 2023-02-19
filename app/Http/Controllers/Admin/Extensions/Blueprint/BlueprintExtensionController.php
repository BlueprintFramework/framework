<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Services\Helpers\BlueprintVariableService;

class BlueprintExtensionController extends Controller
{

    /**
     * BlueprintExtensionController constructor.
     */
    public function __construct(private SoftwareVersionService $version, private ViewFactory $view, private BlueprintVariableService $bp)
    {
    }

    /**
     * Return the admin index view.
     */
    public function index(): View
    {
        $rootPath = "/admin/extensions/blueprint";
        return $this->view->make('admin.extensions.blueprint.index', ['version' => $this->version, 'bp' => $this->bp, 'root' => $rootPath]);
    }
}
