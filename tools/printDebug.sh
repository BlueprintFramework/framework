#!/bin/bash

# $1     Pterodactyl directory (pterodactyl)

cd "$1/.blueprint" || exit;

cat extensions/blueprint/private/debug/logs.txt