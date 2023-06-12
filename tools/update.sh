#!/bin/bash

# $1     Pterodactyl directory (/var/www/pterodactyl)

cd $1/tools/tmp;
if [[ $2 == "dev" ]]; then
  git clone https://github.com/teamblueprint/main.git;
else
  git clone -b $(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/teamblueprint/main/releases/latest)) https://github.com/teamblueprint/main.git
fi;
cp -R main/* $1/;
rm -R $1/.blueprint;
rm -R *;
