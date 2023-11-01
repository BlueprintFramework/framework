<?php

namespace Pterodactyl\BlueprintFramework\Services\TelemetryService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
use Pterodactyl\BlueprintFramework\Services\VariableService\BlueprintVariableService;

class BlueprintTelemetryService
{
  // Construct core
  public function __construct(
    private SettingsRepositoryInterface $settings,
    private BlueprintVariableService $bp,
  ) {
  }

  public function send($event) {
    if ($this->settings->get('blueprint::telemetry') == "false") { return; };

    $curl = curl_init();

    curl_setopt_array($curl, array(
      CURLOPT_URL => 'http://data.ptero.shop:3481/send/'.$this->settings->get('blueprint::panel:id')."/".$event."/",
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_ENCODING => '',
      CURLOPT_MAXREDIRS => 10,
      CURLOPT_TIMEOUT => 0,
      CURLOPT_FOLLOWLOCATION => true,
      CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
      CURLOPT_CUSTOMREQUEST => 'GET',
    ));

    $response = curl_exec($curl);

    curl_close($curl);
    $this->bp->config('TELEMETRY_ID',$this->settings->get("blueprint::panel:id"));
    return;
  }
}
