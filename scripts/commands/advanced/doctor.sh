#!/bin/bash

Command() {
  cd "$FOLDER" || cdhalt

  php artisan bp:doctor "$@"
  exit $?
}