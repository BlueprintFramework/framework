<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework\Test;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class StorageCommand extends Command
{
  protected $description = 'Perform a test operation on a Laravel storage filesystem';
  protected $signature = 'bp:test:storage {--disk=}';

  public function __construct()
  {
    parent::__construct();
  }

  public function handle()
  {
    $this->info('This command will perform a test operation on a filesystem disk');

    $disk = $this->option('disk') ?? $this->ask('Which disk to test?');

    Storage::disk($disk)->put('bp_fs_test.txt', 'hi :)');
    Storage::disk($disk)->delete('bp_fs_test.txt');
  }
}
