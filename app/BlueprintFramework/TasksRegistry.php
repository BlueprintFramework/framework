<?php

namespace Pterodactyl\BlueprintFramework;

use Pterodactyl\BlueprintFramework\Tasks\BackupTask;
use Pterodactyl\BlueprintFramework\Tasks\CommandTask;
use Pterodactyl\BlueprintFramework\Tasks\PowerTask;
use File;

class TasksRegistry
{
    protected array $tasks = [];

    public function __construct() {
        //Default tasks
        $this->register('power', PowerTask::class);
        $this->register('command', CommandTask::class);
        $this->register('backup', BackupTask::class);
        
        // Register all extension tasks
        $this->registerExtensionTasks();
    }

    protected function registerExtensionTasks(): void
    {
        //This can probably be done with a constructor like GetExtensionServices but idk how that works
        $extensions_path = app_path('BlueprintFramework/Tasks/Extensions/');
        if (File::isDirectory($extensions_path)) {
            foreach (File::directories($extensions_path) as $dirPath) {
                $extensionId = basename($dirPath);
                foreach (File::files($dirPath) as $file) {
                    if ($file->getExtension() === 'php') {
                        require_once $file->getPathname();
                        $className = $file->getBasename('.php');
                        $fullClassName = "Pterodactyl\\BlueprintFramework\\Tasks\\Extensions\\{$extensionId}\\{$className}";
                        if (class_exists($fullClassName)) {
                            $taskInstance = new $fullClassName();
                            if (method_exists($taskInstance, 'getActionKey')) {
                                $actionKey = $taskInstance->getActionKey();
                                $this->register($actionKey, $fullClassName);
                            }
                        }
                    }
                }
            }
        }
    }

    public function register(string $key, string $class): void
    {
        $this->tasks[$key] = $class;
    }

    public function get(string $key): ?string
    {
        return $this->tasks[$key] ?? null;
    }

    public function all(): array
    {
        return $this->tasks;
    }
}