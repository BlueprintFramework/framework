#!/bin/bash

Command() {
  if [[ $1 == "" ]]; then PRINT FATAL "Expected 1 argument but got 0.";exit 2;fi
  
  # Check if required programs and libraries are installed.
  depend

  extract_extension "$1"

  # Return to the Pterodactyl installation folder.
  cd "$FOLDER" || cdhalt

  eval "$(parse_yaml .blueprint/tmp/"${n}"/conf.yml conf_)"

  # Basic extension information
  echo -e \
  "\n\x1b[1m$conf_info_name $conf_info_version \033[0;2m(${conf_info_identifier})"\
  "\n$conf_info_description\033[0m\n"

  # Made for version
  if [[ "$VERSION" == "$conf_info_target" ]]; then
    echo -e \
    "\x1b[32;1m  Made for $VERSION\033[0m"
  else
    echo -e \
    "\x1b[33;1m  Made for $conf_info_target\033[0m"
  fi

  # Check for scripts
  # NOTE: Export scripts are excluded from this warning, as they serve a developer-only purpose.
  if [[ -f ".blueprint/tmp/${n}/$conf_data_directory/install.sh" ]] ||
     [[ -f ".blueprint/tmp/${n}/$conf_data_directory/update.sh"  ]] ||
     [[ -f ".blueprint/tmp/${n}/$conf_data_directory/remove.sh"  ]]; then
    echo -e \
    "\x1b[31;1m  Utilizes extension scripts, which can be a safety risk. Extensions with installation scripts can cause conflicts and break other extensions. Learn more at \033[0;2mblueprint.zip/docs/?page=documentation/scripts\x1b[0;31;1m.\033[0m"
  fi

  rm -R ".blueprint/tmp/$n"
  mkdir -p .blueprint/tmp

  echo;

  exit 0
}