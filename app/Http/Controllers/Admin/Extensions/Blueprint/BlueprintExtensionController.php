<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Pterodactyl\Http\Requests\Admin\AdminFormRequest;

class BlueprintExtensionController extends Controller
{

  /**
   * BlueprintExtensionController constructor.
   */
  public function __construct(
    private SettingsRepositoryInterface $settings,
  ) {
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

    return redirect()->route('admin.extensions');
  }
}

class BlueprintAdminFormRequest extends AdminFormRequest
{
  public function rules(): array
  {
    return [
      'flags:is_developer' => 'boolean',
      'flags:telemetry_enabled' => 'boolean',
    ];
  }
}
