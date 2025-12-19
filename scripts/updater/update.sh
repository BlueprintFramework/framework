#!/bin/bash

UpdaterInstall() {
  # Copy release files to Pterodactyl directory
  PRINT INFO "Copying release files to Pterodactyl directory.."
  cp -r .update/repo/* .
  cp .update/repo/.eslintrc.js .
  cp .update/repo/.prettierignore .
  cp .update/repo/.prettierrc.json .
  cp .update/repo/.shellcheckrc .
}
