<?php

namespace Pterodactyl\BlueprintFramework\Tasks;

use Pterodactyl\Models\Task;
use Pterodactyl\Services\Backups\InitiateBackupService;
use Pterodactyl\Repositories\Wings\DaemonPowerRepository;
use Pterodactyl\Repositories\Wings\DaemonCommandRepository;

class BackupTask extends BlueprintBaseTask {

    public function getKey(): string {
        return 'backup';
    }

    public function handle(Task $task, DaemonCommandRepository $commandRepository, InitiateBackupService $backupService, DaemonPowerRepository $powerRepository) {
        $backupService->setIgnoredFiles(explode(PHP_EOL, $task->payload))->handle($task->$server, null, true);
    }

}