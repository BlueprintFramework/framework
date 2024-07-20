<?php

use Illuminate\Support\Facades\Route;
use Pterodactyl\Http\Controllers\Admin;

/*
|--------------------------------------------------------------------------
| Blueprint Extensions
|--------------------------------------------------------------------------
|
| Endpoint: /admin/extensions
|
*/
Route::group(['prefix' => 'extensions'], function () {
  Route::get('/', [Admin\ExtensionsController::class, 'index'])->name('admin.extensions');
});
Route::group(['prefix' => 'extensions/blueprint'], function () {
  /* Blueprint admin page */
  Route::get('/', [Admin\Extensions\Blueprint\BlueprintExtensionController::class, 'index'])->name('admin.extensions.blueprint.index');
  Route::patch('/', [Admin\Extensions\Blueprint\BlueprintExtensionController::class, 'update']);

  /* Extension permissions endpoint */
  Route::patch('/config', [Pterodactyl\BlueprintFramework\Controllers\ExtensionConfigurationController::class, 'update']);
});