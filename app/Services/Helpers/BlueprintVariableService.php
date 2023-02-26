<?php

namespace Pterodactyl\Services\Helpers;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class BlueprintVariableService
{
    // Construct BlueprintVariableService
    public function __construct(
        private SettingsRepositoryInterface $settings,
    ) {
    }


    // $bp->licenseIsValid()
    public function licenseIsValid(): bool{
        $curl = curl_init();

        curl_setopt_array($curl, array(
            CURLOPT_URL => 'http://api.ptero.shop:28015/validate/'.$this->licenseKey(),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 1000,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
        ));

        $response = curl_exec($curl);

        curl_close($curl);

        if($response === "true") {
            return true;
        };
        return false;
    }

    // $bp->licenseIsBlacklisted()
    public function licenseIsBlacklisted(): bool{
        $curl = curl_init();

        curl_setopt_array($curl, array(
            CURLOPT_URL => 'http://api.ptero.shop:28015/validate/'.$this->licenseKey(),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_ENCODING => '',
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_TIMEOUT => 1000,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
        ));

        $response = curl_exec($curl);

        curl_close($curl);

        if($response === "1") {
            return true;
        };
        return false;
    }

    // $bp->licenseKey()
    public function licenseKey(): string{
        return "J4E40M60A1906DQCE";
    }

    // $bp->licenseKeyCensored()
    public function licenseKeyCensored(): string{
        return substr($this->licenseKey(), 0, 5) . "••••••••••••";
    }

    // $bp->version()
    public function version(): string{
        return "indev";
    }

    // $bp->dbGet('db:record')
    public function dbGet($key): string
    {
        $a = $this->settings->get('blueprint::' . $key);
        if(!$a) {
            return "";
        } else {
            return $a;
        };
    }

    // $bp->dbSet('db:record', 'value')
    public function dbSet($key, $value): void
    {
        $this->settings->set('blueprint::' . $key, $value);
        return;
    }
}
