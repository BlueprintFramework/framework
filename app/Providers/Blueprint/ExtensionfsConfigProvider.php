<?php

namespace Pterodactyl\Providers\Blueprint;

use Illuminate\Support\ServiceProvider;

class ExtensionfsConfigProvider extends ServiceProvider
{
  public function register()
  {
    $this->merge();
  }

  protected function merge()
  {
    $extensionConfig = require base_path('.blueprint/extensions/blueprint/private/extensionfs.php');
    $currentConfig = config('filesystems', []);
    $mergedConfig = array_merge_recursive($currentConfig, $extensionConfig);

    config(['filesystems' => $mergedConfig]);
  }
}
