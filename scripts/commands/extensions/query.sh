#!/bin/bash

Command() {
  if [[ $1 == "" ]]; then PRINT FATAL "Expected 1 argument but got 0.";exit 2;fi
  
  # Check if required programs and libraries are installed.
  depend

  extract_extension "$1"

  # Return to the Pterodactyl installation folder.
  cd "$FOLDER" || cdhalt

  eval "$(parse_yaml .blueprint/tmp/"${n}"/conf.yml conf_)"

  echo -e \
  "\x1b[1m$conf_info_name \033[0;2m(nebula.blueprint)"\
  "\n$conf_info_description\033[0m"

  rm -R ".blueprint/tmp/$n"
  mkdir -p .blueprint/tmp

  exit 0
}