<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Artisan;
use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;
use Pterodactyl\BlueprintFramework\Services\ConfigService\BlueprintConfigService;
use Pterodactyl\BlueprintFramework\Services\TelemetryService\BlueprintTelemetryService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Pterodactyl\Http\Requests\Admin\AdminFormRequest;

class BlueprintExtensionController extends Controller
{

  /**
   * BlueprintExtensionController constructor.
   */
  public function __construct(
    private BlueprintTelemetryService $TelemetryService,
    private BlueprintExtensionLibrary $ExtensionLibrary,
    private BlueprintPlaceholderService $PlaceholderService,
    private BlueprintConfigService $ConfigService,

    private ViewFactory $view,
    private SettingsRepositoryInterface $settings,
    ) {
  }

  /**
   * Return the admin index view.
   */
  public function index(): View
  {
    $LatestVersion = $this->ConfigService->latest();
    return $this->view->make(
      'admin.extensions.blueprint.index', [
        'ExtensionLibrary' => $this->ExtensionLibrary,
        'TelemetryService' => $this->TelemetryService,
        'PlaceholderService' => $this->PlaceholderService,
        'ConfigService' => $this->ConfigService,
        'LatestVersion' => $LatestVersion,
        
        'root' => "/admin/extensions/blueprint",
      ]
    );
  }

  /**
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
   */
  public function update(BlueprintAdminFormRequest $request): RedirectResponse
  {
    foreach ($request->normalize() as $key => $value) {
      $this->settings->set('blueprint::' . $key, $value);
    }

    // Confirm that the database value changes have been applied.
    $this->ExtensionLibrary->notify("Your changes have been saved.");
    // Sync database values with the bash side of Blueprint.
    Artisan::call("bp:sync");
    // Redirect back to the page the user was on.
    return redirect()->route('admin.extensions.blueprint.index');
  }
}

class BlueprintAdminFormRequest extends AdminFormRequest
{
  // Form validation for settings on the Blueprint admin page.
  // This is included in the controller directly as that
  // simplifies my work.
  public function rules(): array {
    return [
      'placeholder' => 'string',
      'developer' => 'string|in:true,false',
      'telemetry' => 'string|in:true,false',
    ];
  }

  public function attributes(): array {
    return [
      'placeholder' => 'Placeholder Value',
      'developer' => 'Developer Mode',
      'telemetry' => 'Telemetry',
    ];
  }
}
