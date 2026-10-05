<?php

namespace Pterodactyl\BlueprintFramework\Doctor;

interface CheckInterface
{
    public function name(): string;
    public function title(): string;
    public function run(): CheckResult;
}