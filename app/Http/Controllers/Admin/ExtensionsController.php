<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Support\Facades\Artisan;
use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
use Database\Seeders\BlueprintSeeder;

class ExtensionsController extends Controller
{
  /**
   * ExtensionsController constructor.
   */
  public function __construct(
    private SoftwareVersionService $version,
    private ViewFactory $view,
    private BlueprintExtensionLibrary $blueprint,
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintSeeder $seeder,
  )
  {}

  /**
   * Return the admin index view.
   */
  public function index(): View
  {
    $configuration = $this->blueprint->dbGetMany('blueprint');
    $defaults = [];
    
    if (($configuration['internal:version:latest'] ?? false) === false) {
      Artisan::call('bp:version:cache');
      $latestBlueprintVersion = $this->blueprint->dbGet('blueprint', 'internal:version:latest');
    } else {
      $latestBlueprintVersion = $configuration['internal:version:latest'];
    }

    // Get defaults for each flag
    foreach ($configuration as $key => $value) {
      if (strpos($key, 'flags:') === 0) {
        $defaults[$key] = $this->seeder->getDefaultsForFlag($key);
      }
    }

    return $this->view->make('admin.extensions', [
      'blueprint' => $this->blueprint,
      'PlaceholderService' => $this->PlaceholderService,
      'configuration' => $configuration,
      'latestBlueprintVersion' => $latestBlueprintVersion,
      'defaults' => $defaults,
      'seeder' => $this->seeder,
      
      'version' => $this->version,
      'root' => "/admin/extensions",
    ]);
  }
}
