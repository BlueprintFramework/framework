#!/bin/bash

Command() {
  PRINT WARNING "This is an advanced feature, only proceed if you know what you are doing."

  # Confirmation question for developer upgrade.
  if [[ $1 == "remote" ]]; then
    PRINT INPUT "Upgrading to the latest development build will update Blueprint to a remote version which might differ from the latest release. Continue? (y/N)"
    read -r YN
    if [[ ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ]]; then PRINT INFO "Upgrade cancelled.";exit 1;fi
    YN=""
  fi

  # Confirmation question for both developer and stable upgrade.
  PRINT INPUT "Upgrading will wipe your .blueprint folder and will deactivate all active extensions. Continue? (y/N)"
  read -r YN
  if [[ ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ]]; then PRINT INFO "Upgrade cancelled.";exit 1;fi
  YN=""

  # Last confirmation question for both developer and stable upgrade.
  PRINT INPUT "This is the last warning before upgrading/wiping Blueprint. Type 'continue' to continue, all other input will be taken as 'no'."
  read -r YN
  if [[ ${YN} != "continue" ]]; then PRINT INFO "Upgrade cancelled.";exit 1;fi
  YN=""

  INSTALL_STEPS=14
  export PROGRESS_TOTAL="$((10 + "$INSTALL_STEPS"))"
  export PROGRESS_NOW=0

  if [[ $1 == "remote" ]]; then PRINT INFO "Fetching and pulling latest commit.."
  else                          PRINT INFO "Fetching and pulling latest release.."; fi

  ((PROGRESS_NOW++))

  mkdir "$FOLDER/.tmp"
  cp blueprint.sh .blueprint.sh.bak

  ((PROGRESS_NOW++))

  HAS_DEV=false
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT INFO "Backing up extension development files.."
    mkdir -p "$FOLDER/.tmp/dev"
    cp .blueprint/dev/* "$FOLDER/.tmp/dev/" -Rf
    HAS_DEV=true
  fi

  ((PROGRESS_NOW++))

  mkdir -p "$FOLDER/.tmp/files"
  cd "$FOLDER/.tmp/files" || cdhalt
  if [[ $1 == "remote" ]]; then
    if [[ $2 == "" ]]; then
      REMOTE_REPOSITORY="https://github.com/$REPOSITORY.git"
    else
      if [[ $2 != "http://"* ]] && [[ $2 != "https://"* ]]; then
        REMOTE_REPOSITORY="https://github.com/$2.git"
      else
        REMOTE_REPOSITORY="$2"
      fi
    fi
    # download release
    hide_progress
    if [[ $3 == "" ]]; then
      git clone "$REMOTE_REPOSITORY" main
    else
      git clone "$REMOTE_REPOSITORY" main --branch "$3"
    fi
  else
    # download latest release
    hide_progress
    LOCATION=$(curl -s https://api.github.com/repos/"$REPOSITORY"/releases/latest \
  | grep "zipball_url" \
  | awk '{ print $2 }' \
  | sed 's/,$//'       \
  | sed 's/"//g' )     \
  ; curl -L -o main.zip "$LOCATION"

    unzip main.zip
    rm main.zip
    mv ./* main
  fi

  ((PROGRESS_NOW++))

  if [[ ! -d "main" ]]; then
    cd "$FOLDER" || cdhalt
    rm -r "$FOLDER/.tmp" &>> "$BLUEPRINT__DEBUG"
    rm "$FOLDER/.blueprint.sh.bak" &>> "$BLUEPRINT__DEBUG"
    PRINT FATAL "Remote does not exist or encountered an error, try again later."
    hide_progress
    exit 1
  fi

  ((PROGRESS_NOW++))

  # Remove some files/directories that don't have to be moved to the Pterodactyl folder.
  PRINT INFO "Cleaning up fetched release.."
  rm -r \
    "main/.github" \
    "main/.git" \
    "main/.gitignore" \
    "main/README.md" \
    &>> "$BLUEPRINT__DEBUG"

  ((PROGRESS_NOW++))

  # Copy fetched release files to the Pterodactyl directory and remove temp files.
  PRINT INFO "Moving release files to Pterodactyl directory.."
  cp -r main/* "$FOLDER"/
  rm -r \
    "main" \
    "$FOLDER"/.blueprint \
    "$FOLDER"/.tmp/files
  cd "$FOLDER" || cdhalt

  ((PROGRESS_NOW++))

  # Clean up folders with potentially broken symlinks.
  rm \
    "resources/views/blueprint/admin/wrappers/"* \
    "resources/views/blueprint/dashboard/wrappers/"* \
    "routes/blueprint/application/"* \
    "routes/blueprint/client/"* \
    "routes/blueprint/web/"* \
    &>> /dev/null # cannot forward to debug dir because it does not exist
  
  ((PROGRESS_NOW++))

  # Deprecated, kept in for backwards compatibility
  sed -i -E \
    -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$OWNERSHIP\" #;|g" \
    -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
    -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
    "$FOLDER/blueprint.sh"

  chmod +x blueprint.sh
  mv "$FOLDER/blueprint" "$FOLDER/.blueprint"
  hide_progress
  BLUEPRINT_ENVIRONMENT="upgrade" PROGRESS_NOW="$PROGRESS_NOW" PROGRESS_TOTAL="$PROGRESS_TOTAL" bash blueprint.sh

  ((PROGRESS_NOW++))

  if [[ ${HAS_DEV} == true ]]; then
    PRINT INFO "Restoring extension development files.."
    mkdir -p .blueprint/dev
    cp "$FOLDER/.tmp/dev/"* .blueprint/dev -r
    rm "$FOLDER/.tmp/dev" -rf
  fi

  rm -r "$FOLDER/.tmp"

  ((PROGRESS_NOW++))

  # Post-upgrade checks.
  PRINT INFO "Validating update.."
  score=0

  if dbValidate "blueprint.setupFinished"; then score=$((score+1))
  else PRINT WARNING "'blueprint.setupFinished' could not be detected or found."; fi

  # Finalize upgrade.
  if [[ ${score} == 1 ]]; then
    PRINT SUCCESS "Upgrade finished."
    hide_progress
    rm .blueprint.sh.bak
    exit 0 # success
  elif [[ ${score} == 0 ]]; then
    PRINT FATAL "All checks have failed. The 'blueprint.sh' file has been reverted."
    hide_progress
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1 # error
  else
    PRINT FATAL "Some checks have failed. The 'blueprint.sh' file has been reverted."
    hide_progress
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1 # error
  fi
}
