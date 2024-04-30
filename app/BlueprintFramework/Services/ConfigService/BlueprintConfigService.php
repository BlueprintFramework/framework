<?php

namespace Pterodactyl\BlueprintFramework\Services\ConfigService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintConfigService
{
  // Construct core
  public function __construct(
    private BlueprintPlaceholderService $PlaceholderService,
  ) {
  }

  public function config($item, $value): string|null {
    return shell_exec("cd ".escapeshellarg($this->PlaceholderService->folder()).";c$item=$value bash blueprint.sh -config");
  }

  public function latest(): string {
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
        return "$latest_version";
      } else {
        return "Error";
      }
    } else {
      return "Error";
    }
  }
}
