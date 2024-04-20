<?php

namespace Pterodactyl\BlueprintFramework\Services\TelemetryService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\BlueprintFramework\Services\ConfigService\BlueprintConfigService;
use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

class BlueprintTelemetryService
{
  // Construct core
  public function __construct(
    private SettingsRepositoryInterface $settings,
    private BlueprintConfigService $ConfigService,
    private BlueprintPlaceholderService $PlaceholderService,
  ) {
  }

  public function send($event) {
    if ($this->settings->get('blueprint::telemetry') == "false") { return; };

    $curl = curl_init();
    curl_setopt_array($curl, array(
      CURLOPT_URL => $this->PlaceholderService->api_url().'/send/'.$this->settings->get('blueprint::panel:id')."/".$event."/",
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_ENCODING => '',
      CURLOPT_MAXREDIRS => 10,
      CURLOPT_TIMEOUT => 3,
      CURLOPT_FOLLOWLOCATION => true,
      CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
      CURLOPT_CUSTOMREQUEST => 'GET',
      CURLOPT_CONNECTTIMEOUT => 2,
    ));
    curl_close($curl);

    $this->ConfigService->config('TELEMETRY_ID',$this->settings->get("blueprint::panel:id"));
    return;
  }
}
