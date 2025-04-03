<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Artisan;
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
  public function index(string $extension)
  {
    $ext = $this->blueprint->extensionConfig($extension);
    if ($ext === null || $ext === []) {
      abort(404, 'Extension not found.');
    }
    
    if(!isset($ext['icon'])) {
        // send this file: '/assets/extensions/' . $extension . '/icon.jpg', embed the image

        return response()->file(public_path('assets/extensions/' . $extension . '/icon.jpg'), [
            'Content-Type' => 'image/jpeg',
            'Content-Disposition' => 'inline; filename="icon.jpg"'
        ]);
    }

    if (!\str_starts_with($ext['icon'], 'http')) {
        return response()->file('public/assets/extensions/' . $extension . '/icon.' . pathinfo($ext['icon'], PATHINFO_EXTENSION), [
            'Content-Type' => 'image/image',
            'Content-Disposition' => 'inline'
        ]);
    }

    // image proxy the image. embed it in the page. There is not a view for this yet.
    if (!Cache::has($ext['icon'])) {
        $iconContent = @file_get_contents($ext['icon']);
        if ($iconContent === false) {
            abort(404, 'Failed to fetch the icon from the provided URL.');
        }
        Cache::put($ext['icon'], $iconContent);
    }
    $icon = Cache::get($ext['icon']);
    if (empty($icon)) {
        abort(404, 'Icon not found.');
    }

    $tempFile = tempnam(sys_get_temp_dir(), 'icon_') . '.jpg';
    file_put_contents($tempFile, $icon);

    return response()->file($tempFile, [
        'Content-Type' => 'image/jpeg',
        'Content-Disposition' => 'inline; filename="icon.jpg"'
    ])->deleteFileAfterSend(true);
  }
}
