#!/bin/bash

Command() {
  if ! [[ $1 =~ [0-9] ]] && [[ $1 != "" ]]; then PRINT FATAL "Amount of debug lines must be a number."; exit 2; fi
  if [[ $1 -lt 1 ]]; then PRINT FATAL "Provide the amount of debug lines to print as an argument, which must be greater than one (1)."; exit 2; fi
  echo -e "\x1b[30;47;1m  --- DEBUG START ---  \x1b[0m"
  echo -e "$(v="$(<.blueprint/extensions/blueprint/private/debug/logs.txt)";printf -- "%s" "$v"|tail -"$1")"
  echo -e "\x1b[30;47;1m  ---  DEBUG END  ---  \x1b[0m"
}