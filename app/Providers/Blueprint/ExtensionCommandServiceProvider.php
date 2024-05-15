<?php

namespace Pterodactyl\Providers\Blueprint;

use Illuminate\Support\ServiceProvider;
use Illuminate\Console\Application as Artisan;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ReflectionClass;
use Log;

class ExtensionCommandServiceProvider extends ServiceProvider
{
  /**
   * Register any application services.
   */
  public function register()
  {
      // This method is intentionally left blank
  }

  /**
   * Bootstrap any application services.
   */
  public function boot()
  {
    // Log the base path for debugging
    Log::info('Base path: ' . base_path());

    $this->loadCommandsFrom(base_path('app/Console/Commands/BlueprintFramework/Extensions'));
  }

  /**
   * Load commands from the given directory.
   *
   * @param string $directory
   */
  protected function loadCommandsFrom($directory)
  {
    Log::info('Loading commands from: ' . $directory);

    $namespace = 'Pterodactyl\\Console\\Commands\\BlueprintFramework\\Extensions';

    // Iterate through the directory to find command files
    $iterator = new RecursiveIteratorIterator(
      new RecursiveDirectoryIterator($directory, RecursiveDirectoryIterator::FOLLOW_SYMLINKS),
      RecursiveIteratorIterator::LEAVES_ONLY
    );

    foreach ($iterator as $file) {
      if ($file->isFile() && $file->getExtension() === 'php') {
        // Get the real path of the file
        $realPath = $file->getRealPath();
        $relativePath = str_replace([$directory . DIRECTORY_SEPARATOR, '.php'], '', $realPath);

        // Convert file path to class name
        $className = $namespace . '\\' . str_replace(DIRECTORY_SEPARATOR, '\\', $relativePath);

        // Use Reflection to check if the class exists and is a command
        if (class_exists($className)) {
          $reflection = new ReflectionClass($className);
          if ($reflection->isSubclassOf('Illuminate\Console\Command') && !$reflection->isAbstract()) {
            // Extract prefix from the parent folder
            $prefix = basename(dirname($file->getPath()));

            // Register the command with the prefix
            Artisan::starting(function ($artisan) use ($className, $prefix) {
              $command = $artisan->resolve($className);
              $command->setName('ext:' . $prefix . ':' . $command->getName());
              $artisan->add($command);
            });

            Log::info("Registered command: {$prefix}:{$className}");
          } else {
            Log::warning("Class {$className} is not a valid command.");
          }
        } else {
          Log::warning("Class {$className} does not exist.");
        }
      }
    }
  }
}
