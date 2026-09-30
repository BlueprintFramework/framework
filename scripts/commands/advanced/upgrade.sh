#!/bin/bash

Command() {
  # Confirmation question before updating Blueprint
  PRINT INPUT "You are about to update your Blueprint installation. Continue? (y/N)"
  read -r update_choice
  if [[ ( ${update_choice} != "y"* ) && ( ${update_choice} != "Y"* ) ]]; then
    # Exit when cancelled by user
    PRINT INFO "Upgrade cancelled by user."
    exit 1
  fi
  update_choice=""

  # Initial steps count for progress bar
  export PROGRESS_TOTAL=9
  export PROGRESS_NOW=0

  # Make sure the script is in $FOLDER
  cd "$FOLDER" || exit 1

  # Export the repository variables
  export remote_repo
  export remote_branch
  export fetched_version

  local update_fail extension identifier directory backup_directory

  if [[ -d '.update' ]]; then
    PRINT WARNING ".update already exists! Replacing it."
    rm -rf .update
  fi

  # Create temporary directory for upgrade files
  PRINT INFO "Creating .update directory.."
  mkdir -p .update

  # Define cleanup
  cleanup() {
    PRINT INFO "Cleaning up.."
    cd "$FOLDER" || exit 1

    if [[ $development_files == true ]]; then
      PRINT INFO "Restoring extension development files.."
      rm -rf .blueprint/dev
      mv .update/backup/dev .blueprint/dev
    fi
    rm -rf .update

    if [[ $1 != "" ]]; then
      hide_progress
      exit "$1"
    fi
  }

  ((PROGRESS_NOW++))

  # Prepare repository URL
  if [[ $1 == "remote" ]]; then
    PRINT DEBUG "\$1 was 'remote'"
    case $2 in
      # Custom git repository
      *.git|http://*|https://*)
        PRINT DEBUG "setting remote_repo to '$2', remote_branch to '$3'"
        remote_repo="$2"
        remote_branch="$3"

        if [[ $remote_branch == "" ]]; then
          PRINT FATAL "Expected a git branch at argument 3, was empty. Exiting.."
          cleanup 1
        fi
        if [[ $remote_repo != *.git ]]; then
          PRINT FATAL "Expected a git repository at argument 2, was invalid. (Did you forget to prepend your argument with .git?) Exiting.."
          cleanup 1
        fi
      ;;

      # Custom GitHub repository
      */*)
        PRINT DEBUG "setting remote_repo to 'https://github.com/$2.git', remote_branch to '$3'"
        remote_repo="https://github.com/$2.git"
        remote_branch="$3"

        if [[ $remote_branch == "" ]]; then
          PRINT WARNING "Expected a git branch at argument 3, was empty. Defaulting to $REPOSITORY_BRANCH.."
          remote_branch="$REPOSITORY_BRANCH"
        fi
      ;;

      # Blueprint default repository
      "")
        PRINT WARNING "No git repository provided, defaulting to '$REPOSITORY' (repo) and '$REPOSITORY_BRANCH' (branch)!"
        PRINT DEBUG "setting remote_repo to 'https://github.com/$REPOSITORY.git'"
        remote_repo="https://github.com/$REPOSITORY.git"
        remote_branch="$REPOSITORY_BRANCH"
      ;;

      # Invalid repository provided
      *)
        PRINT DEBUG "Invalid repository provided"
        PRINT FATAL "Expected a GitHub repository name or git repo url at argument 2, but was invalid. Exiting.."
        cleanup 1
      ;;
    esac
  else
    PRINT DEBUG "\$1 was NOT 'remote' (it was '$1')"
    PRINT INFO "Fetching version info"

    php artisan bp:version:cache 2>> "$BLUEPRINT__DEBUG"
    tag_latest=$(php artisan bp:version:latest)
    PRINT DEBUG "tag_latest is $tag_latest"

    fetched_version="$tag_latest"
    remote_repo="https://github.com/$REPOSITORY.git"
    remote_branch="release/$tag_latest"
    PRINT DEBUG "set remote_repo to '$remote_repo', remote_branch to '$remote_branch'"
  fi

  ((PROGRESS_NOW++))

  # Fetching repository with git
  PRINT INFO "Downloading repository.."
  hide_progress
  git clone "$remote_repo" .update/repo --branch "$remote_branch"

  if [[ ! -d ".update/repo" ]]; then
    PRINT FATAL "Could not download repository! Exiting.."
    cleanup 1
  fi

  ((PROGRESS_NOW++))

  # Determine and backup development files
  development_files=false
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    development_files=true
    PRINT INFO "Backing up extension development files.."
    mkdir -p .update/backup
    cp -Rf .blueprint/dev .update/backup/dev
  fi

  ((PROGRESS_NOW++))

  # Back up extension filesystems before replacing .blueprint.
  PRINT INFO "Backing up extension filesystems.."
  mkdir -p .update/backup/extensionfs .update/backup/storage
  for extension in .blueprint/extensions/*; do
    if [[ ! -d $extension || $extension == .blueprint/extensions/blueprint ]]; then continue; fi
    identifier="${extension##*/}"

    if [[ -d $extension/fs || -e $extension/private || -L $extension/private ]]; then
      mkdir -p ".update/backup/extensionfs/$identifier"
      for directory in fs private; do
        if [[ -e $extension/$directory || -L $extension/$directory ]] \
        && ! cp -a "$extension/$directory" ".update/backup/extensionfs/$identifier/"; then
          PRINT FATAL "Could not back up $extension/$directory. Upgrade cancelled."
          cleanup 1
        fi
      done
    fi
  done

  if ! cp -a .blueprint/extensions/blueprint/private/db/installed_extensions \
    .update/backup/extensionfs/installed_extensions; then
    PRINT FATAL "Could not back up the installed extensions list. Upgrade cancelled."
    cleanup 1
  fi
  for directory in storage/extensions storage/.extensions; do
    if [[ -d $directory ]] && ! cp -a "$directory" .update/backup/storage/; then
      PRINT FATAL "Could not back up $directory. Upgrade cancelled."
      cleanup 1
    fi
  done

  ((PROGRESS_NOW++))

  # Delete files
  PRINT INFO "Deleting files.."
  rm -rf .blueprint

  # Clean up folders with potentially broken symlinks.
  rm \
    "resources/views/blueprint/admin/wrappers/"* \
    "resources/views/blueprint/dashboard/wrappers/"* \
    "routes/blueprint/application/"* \
    "routes/blueprint/client/"* \
    "routes/blueprint/web/"* \
    &>> /dev/null # cannot forward to debug dir because it does not exist

  ((PROGRESS_NOW++))

  # Run update script
  PRINT INFO "Running update script.."
  source .update/repo/scripts/updater/update.sh
  hide_progress
  UpdaterInstall

  ((PROGRESS_NOW++))

  # Deprecated, kept in for backwards compatibility
  sed -i -E \
    -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$OWNERSHIP\" #;|g" \
    -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
    -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
    blueprint.sh

  # Run install script
  PRINT INFO "Running final install script.."
  chmod +x blueprint.sh
  mv blueprint .blueprint
  PRINT INFO "Restoring extension filesystems.."
  for extension in .update/backup/extensionfs/*; do
    if [[ ! -d $extension/fs ]]; then continue; fi
    identifier="${extension##*/}"
    if ! mkdir -p ".blueprint/extensions/$identifier" \
    || ! cp -a "$extension/fs" ".blueprint/extensions/$identifier/"; then
      PRINT FATAL "Could not restore ExtensionFS for '$identifier'. Backup retained in .update/backup."
      hide_progress
      exit 1
    fi
  done

  for directory in storage/extensions storage/.extensions; do
    if [[ -d .update/backup/$directory ]]; then
      if ! mkdir -p "$directory" || ! cp -a ".update/backup/$directory/." "$directory/"; then
        PRINT FATAL "Could not restore $directory. Backup retained in .update/backup."
        hide_progress
        exit 1
      fi
    fi
  done

  # Keep private data in storage after .update is removed.
  backup_directory="storage/.blueprint/extension-backups/$(date +%Y%m%d%H%M%S)-$$"
  if ! mkdir -p "$backup_directory" \
  || ! cp -a .update/backup/extensionfs/installed_extensions "$backup_directory/"; then
    PRINT FATAL "Could not archive extension data. Backup retained in .update/backup."
    hide_progress
    exit 1
  fi
  for extension in .update/backup/extensionfs/*; do
    if [[ ! -e $extension/private && ! -L $extension/private ]]; then continue; fi
    identifier="${extension##*/}"
    if ! mkdir -p "$backup_directory/$identifier" \
    || ! cp -a "$extension/private" "$backup_directory/$identifier/"; then
      PRINT FATAL "Could not archive private data for '$identifier'. Backup retained in .update/backup."
      hide_progress
      exit 1
    fi
  done

  ((PROGRESS_NOW++))

  hide_progress
  if ! BLUEPRINT_ENVIRONMENT="upgrade2" PROGRESS_NOW="$PROGRESS_NOW" PROGRESS_TOTAL="$PROGRESS_TOTAL" bash blueprint.sh; then
    PRINT FATAL "Final install failed. Extension data backup retained in .update/backup and $backup_directory."
    hide_progress
    exit 1
  fi

  ((PROGRESS_NOW++))

  cleanup

  # Tell user that update has finished
  if [[ $update_fail == "true" ]]; then
    PRINT FATAL "Update failed, please resolve errors above and try again"
    hide_progress
    exit 1
  fi
  if [[ -s $backup_directory/installed_extensions ]]; then
    PRINT WARNING "Extensions must be reinstalled. Private data backup: $FOLDER/$backup_directory"
  fi
  PRINT SUCCESS "Update finished!"
  hide_progress
  exit 0
}
