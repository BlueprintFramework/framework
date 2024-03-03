<?php

foreach (File::allFiles(__DIR__ . '/application') as $partial) {
  if ($partial->getExtension() == 'php') {
    Route::prefix('/'.basename($partial->getFilename(), '.php'))
      ->group(function () use ($partial) {require_once $partial->getPathname();}
    );
  }
}