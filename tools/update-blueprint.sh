#!/bin/bash

# $1     Pterodactyl directory (/var/www/pterodactyl)

cd $1/tools/tmp;
git clone https://github.com/teamblueprint/main.git;
cp -R main/blueprint.sh $1/blueprint.sh;
rm -R *;