<?php

namespace Pterodactyl\BlueprintFramework\Tasks;

use Pterodactyl\Models\Task;
use Pterodactyl\Services\Backups\InitiateBackupService;
use Pterodactyl\Repositories\Wings\DaemonPowerRepository;
use Pterodactyl\Repositories\Wings\DaemonCommandRepository;

class CommandTask extends BlueprintBaseTask {

    public function getKey(): string {
        return 'command';
    }

    public function handle(Task $task, DaemonCommandRepository $commandRepository, InitiateBackupService $backupService, DaemonPowerRepository $powerRepository) {
        if (empty($task->payload)) {
            throw new \Exception("Payload is empty");
        }
        $commandRepository->setServer($task->$server)->send($task->payload);
    }

}