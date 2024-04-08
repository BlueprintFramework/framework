<?php

use Pterodactyl\BlueprintFramework\Controllers\ExtensionRouteController;

foreach (File::allFiles(__DIR__ . '/client') as $partial) {
  if ($partial->getExtension() == 'php') {
    Route::prefix('/'.basename($partial->getFilename(), '.php'))
      ->group(function () use ($partial) {require_once $partial->getPathname();}
    );
  }
}

/* Routes internally used by Blueprint. */
Route::prefix('/blueprint')->group(function () {
  Route::get('/eggs', [ExtensionRouteController::class, 'eggs']);
});
