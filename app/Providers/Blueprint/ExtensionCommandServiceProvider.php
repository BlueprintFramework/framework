<?php

namespace Pterodactyl\Providers\Blueprint;

use Illuminate\Support\ServiceProvider;
use Illuminate\Console\Application as Artisan;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ReflectionClass;

class ExtensionCommandServiceProvider extends ServiceProvider
{
  /**
   * Register the service provider.
   */
  public function register()
  {
    // Register the commands when the application is booted.
    $this->app->booted(function () {
      $this->loadCommandsFrom(base_path('app/Console/Commands/BlueprintFramework/Extensions'));
    });
  }

  /**
   * Load commands from the given directory.
   *
   * @param string $directory
   */
  protected function loadCommandsFrom($directory)
  {
    $namespace = 'App\\Console\\Commands\\BlueprintFramework\\Extensions';

    // Iterate through the directory to find command files
    $iterator = new RecursiveIteratorIterator(
      new RecursiveDirectoryIterator($directory),
      RecursiveIteratorIterator::LEAVES_ONLY
    );

    foreach ($iterator as $file) {
      if ($file->isFile() && $file->getExtension() === 'php') {
        // Get the relative path
        $relativePath = str_replace([$directory . DIRECTORY_SEPARATOR, '.php'], '', $file->getPathname());

        // Convert file path to class name
        $className = $namespace . '\\' . str_replace(DIRECTORY_SEPARATOR, '\\', $relativePath);

        // Use Reflection to check if the class exists and is a command
        if (class_exists($className)) {
          $reflection = new ReflectionClass($className);
          if ($reflection->isSubclassOf('Illuminate\Console\Command') && !$reflection->isAbstract()) {
            // Extract prefix from the parent folder
            $prefix = $file->getPathInfo()->getPathInfo()->getFilename();

            // Register the command with the prefix
            Artisan::starting(function ($artisan) use ($className, $prefix) {
              $command = $artisan->resolve($className);
              $command->setName($prefix . ':' . $command->getName());
              $artisan->add($command);
            });
          }
        }
      }
    }
  }
}
