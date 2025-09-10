#!/bin/bash

Command() {
  fetchengine()     { printf "\x1b[0m\x1b[37;2m"; if [[ $BLUEPRINT_ENGINE != "" ]]; then echo "$BLUEPRINT_ENGINE"; else echo "unknown"; fi }
  fetchversion()    { printf "\x1b[0m\x1b[37;2m"; if [[ $VERSION != "" ]]; then echo "$VERSION"; else echo "none"; fi }
  fetchfolder()     { printf "\x1b[0m\x1b[37;2m"; if [[ $FOLDER != "" ]]; then echo "$FOLDER"; else echo "none"; fi }
  fetchurl()        { printf "\x1b[0m\x1b[37;2m"; if [[ $(grabAppUrl) != "" ]]; then grabAppUrl; else echo "none"; fi }
  fetchlocale()     { printf "\x1b[0m\x1b[37;2m"; if [[ $(grabAppLocale) != "" ]]; then grabAppLocale; else echo "none"; fi }
  fetchtimezone()   { printf "\x1b[0m\x1b[37;2m"; if [[ $(grabAppTimezone) != "" ]]; then grabAppTimezone; else echo "none"; fi }
  fetchextensions() { printf "\x1b[0m\x1b[37;2m"; tr -cd ',' <.blueprint/extensions/blueprint/private/db/installed_extensions | sed 's~|~~g' | wc -c | tr -d ' '; }
  fetchdeveloper()  { printf "\x1b[0m\x1b[37;2m"; if is_developer; then echo "true"; else echo "false"; fi }
  fetchnode()       { printf "\x1b[0m\x1b[37;2m"; if [[ $(node -v) != "" ]]; then node -v; else echo "none"; fi }
  fetchyarn()       { printf "\x1b[0m\x1b[37;2m"; if [[ $(yarn -v) != "" ]]; then yarn -v; else echo "none"; fi }

  local C0="\x1b[0m"
  local C1="\x1b[31;43;1m"
  local C2="\x1b[32;44;1m"
  local C3="\x1b[34;45;1m"
  local C4="\x1b[0;37;1m"

  echo    " "
  echo -e "${C0}  ██${C0}    \x1b[1mBlueprint Framework${C0}"
  echo -e "${C0}██  ██${C0}  Engine: $(fetchengine)${C0}"
  echo -e "${C0}${C1}▀▀${C0}████${C0}  Version: $(fetchversion)${C0}"
  echo -e "${C0}${C2}▀▀${C0}${C1}▀▀▀▀${C0}  Folder: $(fetchfolder)${C0}"
  echo -e "${C0}${C3}▀▀${C0}${C2}▀▀▀▀${C0}  URL: $(fetchurl)${C0}"
  echo -e "${C0}  ${C3}▀▀▀▀${C0}  Locale: $(fetchlocale)${C0}"
  echo -e "        ${C0}Timezone: $(fetchtimezone)${C0}"
  echo -e "        ${C0}Extensions: $(fetchextensions)${C0}"
  echo -e "        ${C0}Developer: $(fetchdeveloper)${C0}"
  echo -e "        ${C0}Node: $(fetchnode)${C0}"
  echo -e "        ${C0}Yarn: $(fetchyarn)${C0}"
  echo -e "\x1b[0m"
}
