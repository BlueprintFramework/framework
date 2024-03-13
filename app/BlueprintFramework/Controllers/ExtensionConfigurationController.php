<?php

namespace Pterodactyl\BlueprintFramework\Controllers;

use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;

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
  public function update(): RedirectResponse
  {
    //foreach ($request->normalize() as $key => $value) { $this->settings->set('blueprint::' . $key, $value); }
    return redirect()->route('admin.extensions.'.$request->input('_identifier', 'blueprint').'.index');
  }
}