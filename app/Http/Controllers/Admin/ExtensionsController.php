<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;

class ExtensionsController extends Controller
{
  /**
   * ExtensionsController constructor.
   */
  public function __construct(
    private SoftwareVersionService $version,
    private ViewFactory $view,
    private BlueprintExtensionLibrary $ExtensionLibrary,
    private BlueprintPlaceholderService $PlaceholderService)
  {
  }

  /**
   * Return the admin index view.
   */
  public function index(): View
  {
    return $this->view->make('admin.extensions', [
      'ExtensionLibrary' => $this->ExtensionLibrary,
      'PlaceholderService' => $this->PlaceholderService,
      
      'version' => $this->version,
      'root' => "/admin/extensions",
    ]);
  }
}
