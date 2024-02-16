<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Artisan;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\BlueprintFramework\Services\VariableService\BlueprintVariableService;
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
    private BlueprintVariableService $bp,
    private BlueprintTelemetryService $telemetry,
    private BlueprintExtensionLibrary $blueprint,

    private ViewFactory $view,
    private SettingsRepositoryInterface $settings,
    ) {
  }

  /**
   * Return the admin index view.
   */
  public function index(): View
  {
    return $this->view->make(
      'admin.extensions.blueprint.index', [
        'bp' => $this->bp,
        'blueprint' => $this->blueprint,
        'telemetry' => $this->telemetry,
        'latest' => $this->bp->latest(),
        
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
    $this->blueprint->notify("Your changes have been saved.");
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
      'developer' => 'string',
      'telemetry' => 'string',
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
