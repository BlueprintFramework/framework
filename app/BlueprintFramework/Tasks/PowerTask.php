<?php

namespace Pterodactyl\BlueprintFramework\Tasks;

use Pterodactyl\Models\Task;
use Pterodactyl\Services\Backups\InitiateBackupService;
use Pterodactyl\Repositories\Wings\DaemonPowerRepository;
use Pterodactyl\Repositories\Wings\DaemonCommandRepository;

class PowerTask extends BlueprintBaseTask {

    public function getKey(): string {
        return 'power';
    }

    public function handle(Task $task, DaemonCommandRepository $commandRepository, InitiateBackupService $backupService, DaemonPowerRepository $powerRepository) {
        if (!in_array($task->payload, ['start', 'stop', 'restart', 'kill'])) {
            throw new \InvalidArgumentException("Invalid power action: {$task->payload}");
        }
        $powerRepository->setServer($task->$server)->send($task->payload);
    }

}