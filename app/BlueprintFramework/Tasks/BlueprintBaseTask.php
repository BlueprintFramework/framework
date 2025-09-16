<?php

namespace Pterodactyl\BlueprintFramework\Tasks;

use Pterodactyl\Models\Task;
use Pterodactyl\Services\Backups\InitiateBackupService;
use Pterodactyl\Repositories\Wings\DaemonPowerRepository;
use Pterodactyl\Repositories\Wings\DaemonCommandRepository;

abstract class BlueprintBaseTask {

    abstract public function getKey(): string;
    abstract public function handle(Task $task, DaemonCommandRepository $commandRepository, InitiateBackupService $backupService, DaemonPowerRepository $powerRepository);

}