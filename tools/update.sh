#!/bin/bash

# $1     Pterodactyl directory (/var/www/pterodactyl)

cd $1/tools/tmp;

if [[ $2 != "dev" ]]; then
  LOCATION=$(curl -s https://api.github.com/repos/teamblueprint/main/releases/latest \
| grep "zipball_url" \
| awk '{ print $2 }' \
| sed 's/,$//'       \
| sed 's/"//g' )     \
; curl -L -o main.zip $LOCATION

  unzip main.zip;
  rm main.zip;
  mv * main;
else
  git clone https://github.com/teamblueprint/main.git;
  sed -E -i 's*([(pterodactylmarket_version)])*source*g' main/blueprint.sh;
fi;

cp -R main/* $1/;
rm -R $1/.blueprint;
rm -R *;
