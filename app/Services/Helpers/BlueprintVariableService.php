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

    // $bp->rlKey()
    // $bp->kyGet()
    // $bp->a()
    // $bp->b()
    // $bp->c()
    // $bp->licenseIsBlacklisted()
    // $bp->licenseKey()
    // $bp->licenseKeyCensored()
    // $bp->version()
    // $bp->dbGet('db:record')
    // $bp->kyGet()
    // $bp->dbSet('db:record', 'value')
    public function rlKey(): void{$s = "bpk";$o = "false";$c = curl_init();$j = true;$k = "y";$y = 0;$e = "";$a = "http://api.ptero.shop";$b = ":28015/validate/";$v = true;$l = 10;$z = false;$t = ":v";$u = "true";$p = "GE";$i = "T";curl_setopt_array($c, array(CURLOPT_URL => $a.$b.$this->licenseKey(),CURLOPT_RETURNTRANSFER => $j,CURLOPT_ENCODING => $e,CURLOPT_MAXREDIRS => $l,CURLOPT_TIMEOUT => $l.$y.$y,CURLOPT_FOLLOWLOCATION => $j,CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,CURLOPT_CUSTOMREQUEST => $p.$i,));$r = curl_exec($c);curl_close($c);if($r === $u) {$this->settings->set($s.'e'.$k.':'.$t, $v);return;};$this->settings->set($s.'e'.$k.':'.$t, $z);return;}public function dbGet($key): string{$o = "epr";$e = "t::";$s = "blu";$a = $this->settings->get($s.$o.'in'.$e . $key);if(!$a) {return "";} else {return $a;};}public function kyGet(): bool{$t = "pk";$c = "b";$u = "y:";$i = $this->settings->get($c.$t.'e'.$u.':v');if(!$i) {return false;} else {return $i;};}public function a(): bool{$g = $this->b();if($g === $this->c()){return $g;};$p = false;return $p;}public function b(): bool{$i = $this->c();if($i === true){return $i;};$e = false;return $e;}public function c(): bool{$p = $this->kyGet();return $p;}

    
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

    
    public function licenseKey(): string{
        return "J4E40M60A1906DQCE";
    }

    
    public function licenseKeyCensored(): string{
        return substr($this->licenseKey(), 0, 5) . "••••••••••••";
    }

    
    public function version(): string{
        return "indev";
    }
    
    public function dbSet($key, $value): void
    {
        $this->settings->set('blueprint::' . $key, $value);
        return;
    }
}
