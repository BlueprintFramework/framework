#!/bin/bash

# byte.sh
# ╭         ╮   Hello traveler,
# │   o   o │   nice to meet you.
# ╰         ╯   

source .blueprint/lib/bash_colors.sh;
source .blueprint/lib/db.sh;

byte() {
  echo -e "
  ╭         ╮   $2
  │ $1 │   $3
  ╰         ╯   $4
  "
}