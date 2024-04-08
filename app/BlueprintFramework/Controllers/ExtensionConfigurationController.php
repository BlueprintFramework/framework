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
    // set extension eggs to be -1 (Show all), then overwrite if needed
    $this->settings->set('blueprint::extensionconfig_' . $request->input('_identifier', 'blueprint') . '_eggs', '["-1"]');

    foreach ($request->normalize() as $key => $value) {
      if (str_ends_with($key, '_eggs')) {
        // if there are other eggs set, remove the -1 'egg'
        $eggs = (array)$value['*'];
        if (count($eggs) > 1 && in_array('-1', $eggs)) {
          $eggs = array_diff($eggs, ['-1']);
        }

        $value = json_encode(array_values($eggs));
      }

      $this->settings->set('blueprint::extensionconfig_' . $key, $value);
    }
  
    return redirect()->route('admin.extensions.'.$request->input('_identifier', 'blueprint').'.index');
  }
}

class ExtensionConfigurationRequest extends AdminFormRequest
{
  public function rules(): array {
    return [
      $this->input('_identifier', 'blueprint').'_adminlayouts' => 'boolean',
      $this->input('_identifier', 'blueprint').'_dashboardwrapper' => 'boolean',
      $this->input('_identifier', 'blueprint').'_eggs' => 'array',
      $this->input('_identifier', 'blueprint').'_eggs.*' => 'numeric',
    ];
  }

  public function attributes(): array {
    return [
      $this->input('_identifier', 'blueprint').'_adminlayouts' => 'admin layouts permission',
      $this->input('_identifier', 'blueprint').'_dashboardwrapper' => 'dashboard wrapper permission',
    ];
  }
}
