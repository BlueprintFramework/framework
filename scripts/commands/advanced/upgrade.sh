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
  export PROGRESS_TOTAL=10
  export PROGRESS_NOW=0

  # Make sure the script is in $FOLDER
  cd "$FOLDER" || exit 1

  # Create temporary directory for upgrade files
  PRINT INFO "Creating .update directory.."
  mkdir -p .update

  # Define cleanup for this step
  cleanup() {
    cd "$FOLDER" || exit 1
    rm -rf .update

    if [[ $1 != "" ]]; then
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
        if [[ $remote_branch != *.git ]]; then
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
          PRINT FATAL "Expected a git branch at argument 3, was empty. Exiting.."
          cleanup 1
        fi
      ;;

      # Blueprint default repository
      "")
        PRINT INFO "No git repository provided, defaulting to '$REPOSITORY' (repo) and '$REPOSITORY_BRANCH' (branch)!"
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
  fi

  ((PROGRESS_NOW++))

  # Fetching repository with git
  PRINT INFO "Downloading repository.."
  git clone "$remote_repo" .update/repo --branch "$remote_branch"

  if [[ ! -d ".update/repo" ]]; then
    PRINT FATAL "Could not download repository! Exiting.."
    cleanup 1
  fi

  ((PROGRESS_NOW++))

  # Run update script
  PRINT INFO "Running update script.."
  bash .update/repo
}
