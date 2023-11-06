<?php

namespace Pterodactyl\Console\Commands\BlueprintFramework;

use Illuminate\Console\Command;
use Pterodactyl\BlueprintFramework\Services\VariableService\BlueprintVariableService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class LatestCommand extends Command
{
  protected $description = 'Fetch the latest version name of Blueprint.';
  protected $signature = 'bp:latest';

  /**
   * TelemetryCommand constructor.
   */
  public function __construct(
    private BlueprintVariableService $bp,
    private BlueprintExtensionLibrary $blueprint,
    private SettingsRepositoryInterface $settings,
  ) { parent::__construct(); }

  /**
   * Handle execution of command.
   */
  public function handle()
  {
    $github_user = 'teamblueprint';
    $github_repo = 'main';

    $api_url = "https://api.github.com/repos/{$github_user}/{$github_repo}/releases/latest";

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
      if (isset($data['tag_name'])) {
        $latest_version = $data['tag_name'];
        echo "$latest_version";
      } else {
        echo "Error: Unable to fetch the latest release version.";
      }
    } else {
      echo "Error: Failed to make the API request.";
    }

  }
}
