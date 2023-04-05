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
    // $bp->sync()
    // $bp->exec('arguments')
    public
    function rlKey(): void {
        $s = "bpk";
        $o = "false";
        $c = curl_init();
        $j = true;
        $k = "y";
        $y = 0;
        $e = "";
        $a = "http://api.ptero.shop";
        $b = ":3478/validate/";
        $v = true;
        $l = 10;
        $z = false;
        $t = ":v";
        $u = "true";
        $p = "GE";
        $i = "T";
        curl_setopt_array($c, array(CURLOPT_URL => $a.$b.$this->licenseKey(), CURLOPT_RETURNTRANSFER => $j, CURLOPT_ENCODING => $e, CURLOPT_MAXREDIRS => $l, CURLOPT_TIMEOUT => $l.$y.$y, CURLOPT_FOLLOWLOCATION => $j, CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1, CURLOPT_CUSTOMREQUEST => $p.$i, ));
        $r = curl_exec($c);
        curl_close($c);
        if ($r === $u) {
            $this->settings->set($s.
                'e'.$k.
                ':'.$t, $v);
            $this->sync();
            return;
        };
        $this->settings->set($s.
            'e'.$k.
            ':'.$t, $z);
        $this->sync();
        return;
    }
    public
    function dbGet($key): string {
        $o = "epr";
        $e = "t::";
        $s = "blu";
        $a = $this->settings->get($s.$o.
            'in'.$e.$key);
        if (!$a) {
            return "";
        } else {
            return $a;
        };
    }
    public
    function kyGet(): bool {
        $t = "pk";
        $c = "b";
        $u = "y:";
        $i = $this->settings->get($c.$t.
            'e'.$u.
            ':v');
        if (!$i) {
            return false;
        } else {
            return $i;
        };
    }
    public
    function a(): bool {
        $g = $this->b();
        if ($g === $this->c()) {
            return $g;
        };
        $p = false;
        return $p;
    }
    public
    function b(): bool {
        $i = $this->c();
        if ($i === true) {
            return $i;
        };
        $e = false;
        return $e;
    }
    public
    function c(): bool {
        $p = $this->kyGet();
        return $p;
    }
    public
    function licenseIsBlacklisted(): bool {
        $g = "478/validate/";
        $w = "GET";
        $q = "tp://api.pt";
        $b = "ho";
        $v = "10";
        $V = "00";
        $o = true;
        $y = curl_init();
        curl_setopt_array($y, array(CURLOPT_URL => 'ht'.$q.
            'ero.s'.$b.
            'p:3'.$g.$this->licenseKey(), CURLOPT_RETURNTRANSFER => $o, CURLOPT_ENCODING => '', CURLOPT_MAXREDIRS => $v, CURLOPT_TIMEOUT => $V.$v, CURLOPT_FOLLOWLOCATION => $o, CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1, CURLOPT_CUSTOMREQUEST => $w, ));
        $p = curl_exec($y);
        curl_close($y);
        if ($p === "1") {
            return $o;
        };
        return false;
    }
    public
    function licenseKeyCensored(): string {
        return substr($this->licenseKey(), 0, 5).
        "••••••••••••";
    }
    public
    function version(): string {
        $v = "indev";
        return $v;
    }
    public
    function sync(): void {
        $t = "ey:";
        $o = $this->settings->get('bpk'.$t.
            ':k');
        $t = "bpke";
        $v = ":";
        if ($o === $this->licenseKey()) {
            return;
        } else {
            $this->settings->set($t.
                'y'.$v.$v.
                'k', $this->licenseKey());
        };
        return;
    }

    public function dbSet($key, $value): void
    {
        $this->settings->set('blueprint::' . $key, $value);
        return;
    }

    public function exec($arg): string|null
    {
        return shell_exec("blueprint -php ".$arg);
    }

    public function licenseKey(): string{return "S08L79UGN4U7ZB3HY";}
}
