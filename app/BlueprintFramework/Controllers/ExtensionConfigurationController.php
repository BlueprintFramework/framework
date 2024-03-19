<?php

namespace Pterodactyl\BlueprintFramework\Controllers;

use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Pterodactyl\Http\Requests\Admin\AdminFormRequest;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class ExtensionConfigurationController extends Controller
{
  /**
   * BlueprintExtensionController constructor.
   */
  public function __construct(private SettingsRepositoryInterface $settings,) {}

  /**
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
   */
  public function update(ExtensionConfigurationRequest $request): RedirectResponse
  {
    foreach ($request->normalize() as $key => $value) { $this->settings->set('extensionconfig_blueprint::' . $key, $value); }
    return redirect()->route('admin.extensions.'.$request->input('_identifier', 'blueprint').'.index');
  }
}

class ExtensionConfigurationRequest extends AdminFormRequest
{
  public function rules(): array {
    return [
      $this->input('_identifier', 'blueprint').'_adminlayouts' => 'boolean',
      $this->input('_identifier', 'blueprint').'_dashboardwrapper' => 'boolean',
    ];
  }

  public function attributes(): array {
    return [
      $this->input('_identifier', 'blueprint').'_adminlayouts' => 'admin layouts permission',
      $this->input('_identifier', 'blueprint').'_dashboardwrapper' => 'dashboard wrapper permission',
    ];
  }
}
