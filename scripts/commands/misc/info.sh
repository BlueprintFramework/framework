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

  local C0="\x1b[0m"
  local C1="\x1b[31;43;1m"
  local C2="\x1b[32;44;1m"
  local C3="\x1b[34;45;1m"
  local C3="\x1b[0;37;1m"

  echo    " "
  echo -e "${C0}  ${C4}██${C0}    Version: $(fetchversion)"
  echo -e "${C0}${C4}██  ██${C0}  Folder: $(fetchfolder)"
  echo -e "${C0}${C1}▀▀${C0}${C4}████${C0}  URL: $(fetchurl)"
  echo -e "${C0}${C2}▀▀${C0}${C1}▀▀▀▀${C0}  Locale: $(fetchlocale)"
  echo -e "${C0}${C3}▀▀${C0}${C2}▀▀▀▀${C0}  Timezone: $(fetchtimezone)"
  echo -e "${C0}  ${C3}▀▀▀▀${C0}  Extensions: $(fetchextensions)"
  echo -e "        ${C0}Developer: $(fetchdeveloper)"
  echo -e "        ${C0}Telemetry: $(fetchtelemetry)"
  echo -e "        ${C0}Node: $(fetchnode)"
  echo -e "        ${C0}Yarn: $(fetchyarn)"
  echo -e "\x1b[0m"
}