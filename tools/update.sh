#!/bin/bash

# $1     Pterodactyl directory (/var/www/pterodactyl)

cd $1/tools/tmp;
git clone https://github.com/teamblueprint/main.git;
cp -R main/* $1/;
rm -R $1/.blueprint;