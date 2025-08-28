<?php

namespace Pterodactyl\Console\Commands\Storage;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class ListCommand extends Command
{
  protected $description = 'Lists all filesystems configured by the application.';
  protected $signature = 'storage:list';

  public function __construct()
  {
    parent::__construct();
  }

  public function handle()
  {
    echo Storage::disks();
  }
}
