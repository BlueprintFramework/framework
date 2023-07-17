<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Illuminate\View\View;
use Illuminate\View\Factory as ViewFactory;
use Prologue\Alerts\AlertsMessageBag;
use Illuminate\Contracts\Console\Kernel;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Services\Helpers\SoftwareVersionService;
use Pterodactyl\Services\Helpers\BlueprintVariableService;
use Pterodactyl\Services\Helpers\BlueprintTelemetryService;
use Pterodactyl\Services\Helpers\BlueprintExtensionLibrary;
use Pterodactyl\Services\Helpers\BlueprintPlaceholderService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Contracts\Config\Repository as ConfigRepository;
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
    private BlueprintExtensionLibrary $bplib,
    private BlueprintPlaceholderService $placeholderservice,

    private SoftwareVersionService $version,
    private ViewFactory $view,
    private Kernel $kernel,
    private AlertsMessageBag $alert,
    private ConfigRepository $config,
    private SettingsRepositoryInterface $settings,
    ) {
  }

  /**
   * Return the admin index view.
   */
  public function index(): View
  {
    if ($this->settings->get('blueprint::panel:id') == "" || $this->bp->version() != $this->settings->get('blueprint::version:cache')) {
      $this->settings->set('blueprint::panel:id', uniqid(rand())."@".$this->bp->version());
      $this->settings->set('blueprint::version:cache', $this->bp->version());
      $this->bp->config('TELEMETRY_ID',$this->settings->get("blueprint::panel:id"));
    };
    return $this->view->make(
      'admin.extensions.blueprint.index', [
        'version' => $this->version,

        'bp' => $this->bp,
        'bplib' => $this->bplib,
        'telemetry' => $this->telemetry,

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

    $this->bplib->notify("Your changes have been saved.");
    return redirect()->route('admin.extensions.blueprint.index');
  }
}

class BlueprintAdminFormRequest extends AdminFormRequest
{
  public function rules(): array {
    return [
      'placeholder' => 'string',
      'developer' => 'string',
      'developer:cmd' => 'string',
      'telemetry' => 'string',
    ];
  }

  public function attributes(): array {
    return [
      'placeholder' => 'Placeholder Value',
      'developer' => 'Developer Mode',
      'developer:cmd' => 'Blueprint Execute Command',
      'telemetry' => 'Telemetry',
    ];
  }
}
