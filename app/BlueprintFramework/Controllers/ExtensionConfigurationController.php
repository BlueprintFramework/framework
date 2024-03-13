<?php

namespace Pterodactyl\BlueprintFramework\Controllers;

use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Pterodactyl\Http\Requests\Admin\AdminFormRequest;

class ExtensionConfigurationController extends Controller
{
  /**
   * BlueprintExtensionController constructor.
   */
  public function __construct() {}

  /**
   * @throws \Pterodactyl\Exceptions\Model\DataValidationException
   * @throws \Pterodactyl\Exceptions\Repository\RecordNotFoundException
   */
  public function update(ExtensionConfigurationRequest $request): RedirectResponse
  {
    //foreach ($request->normalize() as $key => $value) { $this->settings->set('blueprint::' . $key, $value); }
    return redirect()->route('admin.extensions.'.$request->input('_identifier', 'blueprint').'.index');
  }
}

class ExtensionConfigurationRequest extends AdminFormRequest
{
  public function rules(): array {
    return [
      '*' => 'nullable',
    ];
  }

  public function attributes(): array {
    return [
      '*' => 'test',
    ];
  }
}
