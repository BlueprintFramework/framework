#!/bin/bash

UpdaterInstall() {
  # Copy release files to Pterodactyl directory
  PRINT INFO "Copying release files to Pterodactyl directory.."
  cp -r .update/repo/* .
  cp .eslintrc.js .
  cp .prettierignore .
  cp .prettierrc.json .
  cp .shellcheckrc .

  exit 0
}
