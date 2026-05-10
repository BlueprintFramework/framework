<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\View\View;
use Database\Seeders\BlueprintSeeder;
use Illuminate\Support\Facades\Artisan;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Models\ExtensionCachedMetadata;
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

    $metadata = ExtensionCachedMetadata::whereIn('identifier', $this->blueprint->extensions())
      ->get()
      ->keyBy('identifier')
      ->map(fn($m) => $m->metadata)
      ->toArray();

    return $this->view->make('admin.extensions', [
      'blueprint' => $this->blueprint,
      'PlaceholderService' => $this->PlaceholderService,
      'configuration' => $configuration,
      'latestBlueprintVersion' => $latestBlueprintVersion,
      'defaults' => $defaults,
      'seeder' => $this->seeder,
      'metadata' => $metadata,

      'version' => $this->version,
      'root' => "/admin/extensions",
    ]);
  }
}
