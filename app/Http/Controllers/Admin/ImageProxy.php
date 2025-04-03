<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Support\Facades\Artisan;
use Illuminate\Http\Response;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
use Database\Seeders\BlueprintSeeder;

class ImageProxy extends Controller
{
  /**
   * ExtensionsController constructor.
   */
  public function __construct(
    private BlueprintExtensionLibrary $blueprint,
  )
  {}

  /**
   * Return the admin index view.
   */
  public function index(string $extension): Response
  {
    $ext = $this->blueprint->extensionConfig($extension);
    if ($ext === null || $ext === []) {
      abort(404, 'Extension not found.');
    }

    if (!\str_starts_with($ext['icon'], 'http')) {
        abort(412, 'Extension icon must be remote');
    }

    // image proxy the image. embed it in the page. There is not a view for this yet.
    $icon = file_get_contents($ext['icon']);
    if ($icon === false) {
        abort(404, 'Icon not found.');
    }
    $icon = base64_encode($icon);
    $icon = 'data:image/png;base64,' . $icon;
    // json return the icon data
    return response()->json([
        'icon' => $icon,
    ]);
  }
}
