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
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Contracts\Config\Repository as ConfigRepository;
use Pterodactyl\Http\Requests\Admin\Extensions\Blueprint\BlueprintSettingsFormRequest;
use Illuminate\Http\RedirectResponse;

class BlueprintExtensionController extends Controller
{

    /**
     * BlueprintExtensionController constructor.
     */
    public function __construct(
        private BlueprintVariableService $bp,
        private BlueprintTelemetryService $telemetry,
        private BlueprintExtensionLibrary $bplib,

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
        if($this->bp->dbGet('developer:cmd') != "") {
            $this->bp->dbSet('developer:log', shell_exec("cd /var/www/pterodactyl;".$this->bp->dbGet('developer:cmd')));
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
    public function update(BlueprintSettingsFormRequest $request): RedirectResponse
    {
        foreach ($request->normalize() as $key => $value) {
            $this->settings->set('blueprint::' . $key, $value);
        }

        shell_exec("cd /var/www/pterodactyl;echo \"Your changes have been saved.\" > .blueprint/.storage/notification.txt;");
        return redirect()->route('admin.extensions.blueprint.index');
    }
}
