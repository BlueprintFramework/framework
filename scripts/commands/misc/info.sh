#!/bin/bash

Command() {
  fetchversion()    { printf "\x1b[0m\x1b[37m"; if [[ $VERSION != "" ]]; then echo "$VERSION"; else echo "none"; fi }
  fetchfolder()     { printf "\x1b[0m\x1b[37m"; if [[ $FOLDER != "" ]]; then echo "$FOLDER"; else echo "none"; fi }
  fetchurl()        { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppUrl) != "" ]]; then grabAppUrl; else echo "none"; fi }
  fetchlocale()     { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppLocale) != "" ]]; then grabAppLocale; else echo "none"; fi }
  fetchtimezone()   { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppTimezone) != "" ]]; then grabAppTimezone; else echo "none"; fi }
  fetchextensions() { printf "\x1b[0m\x1b[37m"; tr -cd ',' <.blueprint/extensions/blueprint/private/db/installed_extensions | wc -c | tr -d ' '; }
  fetchdeveloper()  { printf "\x1b[0m\x1b[37m"; if dbValidate "blueprint.developerEnabled"; then echo "true"; else echo "false"; fi }
  fetchtelemetry()  { printf "\x1b[0m\x1b[37m"; if [[ $(cat .blueprint/extensions/blueprint/private/db/telemetry_id) == "KEY_NOT_UPDATED" ]]; then echo "false"; else echo "true"; fi }
  fetchnode()       { printf "\x1b[0m\x1b[37m"; if [[ $(node -v) != "" ]]; then node -v; else echo "none"; fi }
  fetchyarn()       { printf "\x1b[0m\x1b[37m"; if [[ $(yarn -v) != "" ]]; then yarn -v; else echo "none"; fi }

  echo    " "
  echo -e "\x1b[34;1m    ⣿⣿    Version: $(fetchversion)"
  echo -e "\x1b[34;1m  ⣿⣿  ⣿⣿  Folder: $(fetchfolder)"
  echo -e "\x1b[34;1m    ⣿⣿⣿⣿  URL: $(fetchurl)"
  echo -e "\x1b[34;1m          Locale: $(fetchlocale)"
  echo -e "\x1b[34;1m          Timezone: $(fetchtimezone)"
  echo -e "\x1b[34;1m          Extensions: $(fetchextensions)"
  echo -e "\x1b[34;1m          Developer: $(fetchdeveloper)"
  echo -e "\x1b[34;1m          Telemetry: $(fetchtelemetry)"
  echo -e "\x1b[34;1m          Node: $(fetchnode)"
  echo -e "\x1b[34;1m          Yarn: $(fetchyarn)"
  echo -e "\x1b[0m"
}