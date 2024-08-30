<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class LatestCommand extends Command
{
  protected $description = 'Get the version name of the newest release of Blueprint.';
  protected $signature = 'bp:latest';

  /**
   * LatestCommand constructor.
   */
  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    $api_url = $this->PlaceholderService->api_url()."/api/latest";
    $context = stream_context_create([
      'http' => [
        'method' => 'GET',
        'header' => 'User-Agent: BlueprintFramework',
      ],
    ]);
    $response = file_get_contents($api_url, false, $context);
    if ($response) {
      $cleaned_response = preg_replace('/[[:^print:]]/', '', $response);
      $data = json_decode($cleaned_response, true);
      if (isset($data['name'])) {
        $latest_version = $data['name'];
        echo "$latest_version";
        return "$latest_version";
      } else {
        echo "Error: Unable to fetch the latest release version.";
        return "Error";
      }
    } else {
      echo "Error: Failed to make the API request.";
      return "Error";
    }
  }
}
