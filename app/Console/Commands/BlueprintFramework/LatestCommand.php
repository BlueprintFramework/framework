<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;

class LatestCommand extends Command
{
  protected $description = 'Fetch the latest version name of Blueprint.';
  protected $signature = 'bp:latest';

  /**
   * LatestCommand constructor.
   */
  public function __construct(
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    $api_url = "http://api.blueprint.zip:50000/api/latest";
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
