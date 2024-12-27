#!/bin/bash

Command() {
  if [[ $1 == "" ]]; then PRINT FATAL "Expected 1 argument but got 0.";exit 2;fi
  
  # Check if required programs and libraries are installed.
  depend

  n="$1"

  if [[ $n == *".blueprint" ]]; then n="${n::-10}";fi
  FILE="${n}.blueprint"

  if [[ ! -f "$FILE" ]]; then PRINT FATAL "$FILE could not be found or detected.";return 2;fi

  ZIP="${n}.zip"
  cp "$FILE" ".blueprint/tmp/$ZIP"
  cd ".blueprint/tmp" || cdhalt
  unzip -o -qq "$ZIP"
  rm "$ZIP"
  if [[ ! -f "$n/*" ]]; then
    cd ".." || cdhalt
    rm -R "tmp"
    mkdir -p "tmp"
    cd "tmp" || cdhalt

    mkdir -p "./$n"
    cp "../../$FILE" "./$n/$ZIP"
    cd "$n" || cdhalt
    unzip -o -qq "$ZIP"
    rm "$ZIP"
    cd ".." || cdhalt
  fi

  # Return to the Pterodactyl installation folder.
  cd "$FOLDER" || cdhalt

  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/tmp/$n/conf.yml" ]]; then
    # Quit if the extension doesn't have a conf.yml file.
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension configuration file not found or detected."
    return 1
  fi

  eval "$(parse_yaml .blueprint/tmp/"${n}"/conf.yml conf_)"

  echo -e \
  "\x1b[1m$conf_info_name \033[0;2m(nebula.blueprint)"\
  "\n$conf_info_description\033[0m"

  rm -R ".blueprint/tmp/$n"

  exit 0
}