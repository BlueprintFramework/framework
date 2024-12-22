<?php

namespace Pterodactyl\Http\Controllers\Admin\Extensions\Blueprint;

use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Illuminate\Http\RedirectResponse;
use Pterodactyl\Http\Requests\Admin\AdminFormRequest;
use Database\Seeders\BlueprintSeeder;

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
    foreach ($request->validated() as $key => $value) {
      $this->settings->set('blueprint::' . $key, $value);
    }

    return redirect()->route('admin.extensions');
  }
}

class BlueprintAdminFormRequest extends AdminFormRequest
{
  public function rules(): array
  {
    // Get schema to determine types
    $seeder = app(BlueprintSeeder::class);
    $schema = $seeder->getSchema();
    
    $rules = [];
    foreach ($schema['flags'] as $key => $config) {
      $flagPath = "flags:{$key}";
      
      // Build validation rules based on type
      switch ($config['type']) {
        case 'boolean':
          $rules[$flagPath] = 'boolean';
          break;
        case 'string':
          $rules[$flagPath] = 'string|nullable';
          break;
        case 'number':
          $rules[$flagPath] = 'numeric';
          break;
        case 'integer':
          $rules[$flagPath] = 'integer';
          break;
      }
    }
    
    return $rules;
  }
}