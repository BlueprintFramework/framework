#!/bin/bash

Command() {
  if dbValidate "blueprint.developerEnabled"; then
    help_dev_status=""
    help_dev_primary="\e[34;1m"
    help_dev_secondary="\e[34m"
  else
    help_dev_status=" (disabled)"
    help_dev_primary="\x1b[2;1m"
    help_dev_secondary="\x1b[2m"
  fi

  echo -e "
\x1b[34;1mExtensions\x1b[0m\x1b[34m
  -install [name]   -add -i  install/update a blueprint extension
  -remove [name]         -r  remove a blueprint extension
  \x1b[0m

${help_dev_primary}Developer${help_dev_status}\x1b[0m${help_dev_secondary}
  -init                  -I  initialize development files
  -build                 -b  install/update your development files
  -export (expose)       -e  export/download your development files
  -wipe                  -w  remove your development files
  \x1b[0m

\x1b[34;1mMisc\x1b[0m\x1b[34m
  -version               -v  returns the blueprint version
  -help                  -h  displays this menu
  -info                  -f  show neofetch-like information about blueprint
  -debug [lines]             print given amount of debug lines
  \x1b[0m

\x1b[34;1mAdvanced\x1b[0m\x1b[34m
  -upgrade (remote <url>)    update/reset to another release
  -rerun-install             rerun the blueprint installation script
  \x1b[0m
  "
}