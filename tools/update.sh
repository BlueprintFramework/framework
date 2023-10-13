#!/bin/bash

# $1     Pterodactyl directory (pterodactyl)
# $2     Dev release (dev)

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
fi;

cp -R main/* $1/;
rm -R main;
rm -R $1/.blueprint;