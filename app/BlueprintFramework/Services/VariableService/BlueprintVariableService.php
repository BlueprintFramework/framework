<?php

namespace Pterodactyl\BlueprintFramework\Services\VariableService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintVariableService
{
  // Construct core
  public function __construct(
    private SettingsRepositoryInterface $settings,
    private BlueprintPlaceholderService $blueprintplaceholderservice,
  ) {
  }


  // $bp->serve()
  // $bp->latestVersion()
  // $bp->isInstalled()
  // $bp->version()
  // $bp->dbGet('db::record')
  // $bp->dbSet('db::record', 'value')
  // $bp->config('item', value);
  
  public function serve(): void {
    return;
  }

  public function latestVersion(): string {
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
        return "$latest_version";
      } else {
        return "Error: Unable to fetch the latest release version.";
      }
    } else {
      return "Error: Failed to make the API request.";
    }
  }

  public function version(): string {
    return $this->blueprintplaceholderservice->version();
  }

  public function isInstalled(): string {
    return $this->blueprintplaceholderservice->installed();
  }

  public function dbGet($key): string {
    // BlueprintExtensionLibrary is preferred where possible.
    $a = $this->settings->get("blueprint::".$key);
    if (!$a) {
      return "";
    } else {
      return $a;
    };
  }

  public function dbSet($key, $value): void {
    // BlueprintExtensionLibrary is preferred where possible.
    $this->settings->set('blueprint::' . $key, $value);
    return;
  }

  public function config($item, $value): string|null {
    return shell_exec("cd ".escapeshellarg($this->blueprintplaceholderservice->folder()).";c$item=$value bash blueprint.sh -config");
  }
}
