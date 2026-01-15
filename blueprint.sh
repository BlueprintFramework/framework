#!/bin/bash
# © 2023-2026 Emma (prpl.wtf)

# Learn more @ blueprint.zip
# Source code available at github.com/blueprintframework/framework
# Transparent financials available at hcb.hackclub.com/blueprint

# To make changes to the variables persist between updates, make a .blueprintrc file
# and override the variables there.

BLUEPRINT_ENGINE="solstice"
REPOSITORY="BlueprintFramework/framework"
REPOSITORY_BRANCH="main"
VERSION="rolling" #;

FOLDER=$(realpath "$(dirname "$0" 2> /dev/null)" 2> /dev/null) || FOLDER="$BLUEPRINT__FOLDER"
OWNERSHIP="www-data:www-data" #;
WEBUSER="www-data" #;
USERSHELL="/bin/bash" #;

# Check if the script is being sourced - and if so - load bash autocompletion.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  _blueprint_completions() {
    local cur cmd opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    cmd="${COMP_WORDS[1]}"

    case "${cmd}" in
      -install|-add|-i|-query|-q)
        opts="$(
          find "$BLUEPRINT__FOLDER"/*.blueprint 2> /dev/null |
          sed -e "s|^$BLUEPRINT__FOLDER/||g" -e "s|.blueprint$||g"
        )"
      ;;
      -remove|-r)
        opts="$(
          sed -e "s~|~~g" -e "s|,| |g" "$BLUEPRINT__FOLDER/.blueprint/extensions/blueprint/private/db/installed_extensions"
        )"
      ;;
      -export) opts="expose" ;;
      -upgrade) opts="remote" ;;

      *) opts="-install -add -remove -query -init -build -export -wipe -version -help -info -debug -upgrade -rerun-install" ;;
    esac

    if [[ ${cur} == * ]]; then
      # shellcheck disable=SC2207
      COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
      return 0
    fi
  }
  complete -F _blueprint_completions blueprint
  return 0
fi

# Set Blueprint environment variables.
export BLUEPRINT__FOLDER=$FOLDER
export BLUEPRINT__VERSION=$VERSION
export BLUEPRINT__DEBUG="$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
export NODE_OPTIONS="--openssl-legacy-provider"

# Defaults
D_OWNERSHIP="www-data:www-data"
D_WEBUSER="www-data"
D_USERSHELL="/bin/bash"

# Check for panels that are using Docker, which should have better support in the future.
if [[ -f "/.dockerenv" ]]; then
  DOCKER="y"
  FOLDER="/app"
else
  DOCKER="n"
fi

source "$FOLDER/.blueprintrc" 2> /dev/null

# This has caused a bunch of errors but is just here to make sure people actually upload the
# "blueprint" folder onto their panel when installing Blueprint. Pick your poison.
if [[ -d "$FOLDER/blueprint" ]]; then mv "$FOLDER/blueprint" "$FOLDER/.blueprint"; fi

if [[ $VERSION != "" ]]; then
  # This function makes sure some placeholders get replaced with the current Blueprint version.
  if [[ ! -f "$FOLDER/.blueprint/extensions/blueprint/private/db/version" ]]; then
    sed -E -i "s*::v*$VERSION*g" "$FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php"
    sed -E -i "s*::v*$VERSION*g" "$FOLDER/.blueprint/extensions/blueprint/public/index.html"
    touch "$FOLDER/.blueprint/extensions/blueprint/private/db/version"
  fi
fi

# Set internal variables.
__BuildDir=".blueprint/extensions/blueprint/private/build"

# Automatically navigate to the Pterodactyl directory when running the script.
cd "$FOLDER" || return

# Import libraries.
source scripts/libraries/parse_yaml.sh    || missinglibs+="[parse_yaml]"
source scripts/libraries/grabenv.sh       || missinglibs+="[grabenv]"
source scripts/libraries/logFormat.sh     || missinglibs+="[logFormat]"
source scripts/libraries/misc.sh          || missinglibs+="[misc]"


cdhalt() { PRINT FATAL "Attempted navigation into nonexistent directory, halting process."; exit 1; }
depend() {
  # Make sure Node.js is version 20 or higher.
  nodeMajor=$(node -v | awk -F. '{print $1}' | sed 's/[^0-9]*//g')

  # Check for required (both internal and external) dependencies.
  if \
  ! [ -x "$(command -v unzip)" ] ||                                               # unzip
  ! [ -x "$(command -v yarn)" ] ||                                                # yarn
  ! [ -x "$(command -v zip)" ] ||                                                 # zip
  ! [ -x "$(command -v curl)" ] ||                                                # curl
  ! [ -x "$(command -v php)" ] ||                                                 # php
  ! [ -x "$(command -v git)" ] ||                                                 # git
  ! [ -x "$(command -v grep)" ] ||                                                # grep
  ! [ -x "$(command -v sed)" ] ||                                                 # sed
  ! [ -x "$(command -v awk)" ] ||                                                 # awk
  ! [ -x "$(command -v tput)" ] ||                                                # tput
  ! [ -x "$(command -v node)" ] ||                                                # node
  { ! [ -x "$(command -v inotifywait)" ] && [[ "$DeveloperWatch" == true ]]; } || # inotify-tools (devdep)
  [[ $nodeMajor -lt 17 ]] ||                                                      # node version
  ! [ "$(ls "node_modules/"*"webpack"* 2> /dev/null)"   ] ||                      # webpack
  ! [ "$(ls "node_modules/"*"react"* 2> /dev/null)"     ] ||                      # react
  [[ $missinglibs != "" ]]; then                                                  # internal
    DEPEND_MISSING=true
  fi

  # Exit when missing dependencies.
  if [[ $DEPEND_MISSING == true ]]; then
    PRINT FATAL "Some framework dependencies couldn't be found or have issues. This is usually NOT a bug, do not report it as such."

    if [[ $nodeMajor -lt 20 ]]; then
      PRINT FATAL "Unsupported dependency \"node\" <20.x. (Requires >20.x)"
    fi

    if ! [ -x "$(command -v unzip)"                        ]; then PRINT FATAL "Missing dependency \"unzip\".";   fi
    if ! [ -x "$(command -v node)"                         ]; then PRINT FATAL "Missing dependency \"node\".";    fi
    if ! [ -x "$(command -v yarn)"                         ]; then PRINT FATAL "Missing dependency \"yarn\".";    fi
    if ! [ -x "$(command -v zip)"                          ]; then PRINT FATAL "Missing dependency \"zip\".";     fi
    if ! [ -x "$(command -v curl)"                         ]; then PRINT FATAL "Missing dependency \"curl\".";    fi
    if ! [ -x "$(command -v php)"                          ]; then PRINT FATAL "Missing dependency \"php\".";     fi
    if ! [ -x "$(command -v git)"                          ]; then PRINT FATAL "Missing dependency \"git\".";     fi
    if ! [ -x "$(command -v grep)"                         ]; then PRINT FATAL "Missing dependency \"grep\".";    fi
    if ! [ -x "$(command -v sed)"                          ]; then PRINT FATAL "Missing dependency \"sed\".";     fi
    if ! [ -x "$(command -v awk)"                          ]; then PRINT FATAL "Missing dependency \"awk\".";     fi
    if ! [ -x "$(command -v tput)"                         ]; then PRINT FATAL "Missing dependency \"tput\".";    fi
    if ! [ "$(ls "node_modules/"*"webpack"* 2> /dev/null)" ]; then PRINT FATAL "Missing dependency \"webpack\"."; fi
    if ! [ "$(ls "node_modules/"*"react"* 2> /dev/null)"   ]; then PRINT FATAL "Missing dependency \"react\".";   fi

    if ! [ -x "$(command -v inotifywait)" ] && [[ "$DeveloperWatch" == true ]]; then
      PRINT FATAL "Developer dependency \"inotify-tools\" is not installed or detected."
    fi

    if [[ $missinglibs == *"[parse_yaml]"*    ]]; then PRINT FATAL "Missing internal dependency \"internal:parse_yaml\"."; fi
    if [[ $missinglibs == *"[grabEnv]"*       ]]; then PRINT FATAL "Missing internal dependency \"internal:grabEnv\".";    fi
    if [[ $missinglibs == *"[logFormat]"*     ]]; then PRINT FATAL "Missing internal dependency \"internal:logFormat\".";  fi
    if [[ $missinglibs == *"[misc]"*          ]]; then PRINT FATAL "Missing internal dependency \"internal:misc\".";       fi

    exit 1
  fi
}

# Assign variables for extension flags.
assignflags() {
  F_ignorePlaceholders=false
  F_forceLegacyPlaceholders=false
  F_developerIgnoreInstallScript=false
  F_developerIgnoreRebuild=false
  F_developerKeepApplicationCache=false
  F_developerEscalateInstallScript=false
  F_developerEscalateExportScript=false
  if [[ ( $flags == *"ignorePlaceholders,"*             ) || ( $flags == *"ignorePlaceholders"             ) ]]; then F_ignorePlaceholders=true             ;fi
  if [[ ( $flags == *"forceLegacyPlaceholders,"*        ) || ( $flags == *"forceLegacyPlaceholders"        ) ]]; then F_forceLegacyPlaceholders=true        ;fi
  if [[ ( $flags == *"developerIgnoreInstallScript,"*   ) || ( $flags == *"developerIgnoreInstallScript"   ) ]]; then F_developerIgnoreInstallScript=true   ;fi
  if [[ ( $flags == *"developerIgnoreRebuild,"*         ) || ( $flags == *"developerIgnoreRebuild"         ) ]]; then F_developerIgnoreRebuild=true         ;fi
  if [[ ( $flags == *"developerKeepApplicationCache,"*  ) || ( $flags == *"developerKeepApplicationCache"  ) ]]; then F_developerKeepApplicationCache=true  ;fi
  if [[ ( $flags == *"developerEscalateInstallScript,"* ) || ( $flags == *"developerEscalateInstallScript" ) ]]; then F_developerEscalateInstallScript=true ;fi
  if [[ ( $flags == *"developerEscalateExportScript,"*  ) || ( $flags == *"developerEscalateExportScript"  ) ]]; then F_developerEscalateExportScript=true  ;fi


  warn_deprecated_flag() { PRINT WARNING "Extension flag '$1' is deprecated."; }

  F_hasInstallScript=false
  if [[ ( $flags == *"hasInstallScript,"* ) || ( $flags == *"hasInstallScript" ) ]]; then
    warn_deprecated_flag "hasInstallScript"
    F_hasInstallScript=true
  fi

  F_hasRemovalScript=false
  if [[ ( $flags == *"hasRemovalScript,"* ) || ( $flags == *"hasRemovalScript" ) ]]; then
    warn_deprecated_flag "hasRemovalScript"
    F_hasRemovalScript=true
  fi

  F_hasExportScript=false
  if [[ ( $flags == *"hasExportScript,"* ) || ( $flags == *"hasExportScript" ) ]]; then
    warn_deprecated_flag "hasExportScript"
    F_hasExportScript=true
  fi

  F_developerForceMigrate=false
  if [[ ( $flags == *"developerForceMigrate,"* ) || ( $flags == *"developerForceMigrate" ) ]]; then
    warn_deprecated_flag "developerForceMigrate"
    F_developerForceMigrate=true
  fi
}

# Adds the "blueprint" command to the /usr/local/bin directory and configures the correct permissions for it.
placeshortcut() {
  PRINT INFO "Placing Blueprint command shortcut.."

  rm -f scripts/helpers/blueprint.bak
  cp "scripts/helpers/blueprint" "scripts/helpers/blueprint.bak"
  sed -i "s~BLUEPRINT_FOLDER_HERE~$FOLDER~g" "scripts/helpers/blueprint.bak"

  rm -f /usr/local/bin/blueprint
  mv scripts/helpers/blueprint.bak /usr/local/bin/blueprint

  {
    chmod 755 \
      "$FOLDER/blueprint.sh" \
      /usr/local/bin/blueprint
  } >> "$BLUEPRINT__DEBUG"
}
if ! [ -x "$(command -v blueprint)" ]; then placeshortcut; fi


if [[ $1 != "-bash" ]]; then
  if dbValidate "blueprint.setupFinished"; then
    PRINT FATAL "Blueprint is already installed, use the 'blueprint' command instead."
    exit 2
  else
    # Only run if Blueprint is not in the process of upgrading.
    if [[ $BLUEPRINT_ENVIRONMENT != "upgrade2" ]]; then
      # Print Blueprint icon with ascii characters.
      C0="\x1b[0m"
      C1="\x1b[31;43;1m"
      C2="\x1b[32;44;1m"
      C3="\x1b[34;45;1m"
      C3="\x1b[0;37;1m"
      echo -e "$C0" \
        "\n$C4  ██$C1▌$C2▌$C3▌$C0   Blueprint Framework" \
        "\n$C4██  ██$C1▌$C2▌$C3▌$C0 https://blueprint.zip" \
        "\n$C4  ████$C1▌$C2▌$C3▌$C0 © 2023-2026 Emma (prpl.wtf)\n";

      export PROGRESS_TOTAL=15
      export PROGRESS_NOW=0
    else
      PROGRESS_TOTAL="$(("$PROGRESS_TOTAL" + 15))"
    fi

    if [[ $BLUEPRINT_ENVIRONMENT == "upgrade" ]]; then
      echo -e "\x1b[37;41;1m MANUAL ACTION REQUIRED \x1b[0m"
      echo -e "\n\x1b[31;49;1mThis is NOT a bug. Please follow the following instructions:\x1b[0m"

      echo -e "\n\x1b[31;49m1. Use the CTRL+C (^C) keyboard shortcut to terminate this process.\x1b[0m"
      echo -e "\x1b[31;49m2. Then, run 'blueprint -upgrade' AGAIN.\x1b[0m"

      read -r
      exit 1
    fi

    if [[ $BLUEPRINT_ENVIRONMENT == "upgrade2" ]]; then
      # Get rid of beta-2025-11 leftovers
      rm -rf resources/scripts/blueprint/utility resources/scripts/blueprint/css/BlueprintStylesheet.css resources/scripts/blueprint/index.ts
    fi

    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INFO "Installing node modules.."
      # Check for yarn before installing node modules..
      if ! [ -x "$(command -v yarn)" ]; then
        PRINT FATAL "Missing dependency \"yarn\"."
      fi
      hide_progress
    fi

    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      set -eo pipefail
      yarn install
      set +eo pipefail
    fi

    ((PROGRESS_NOW++))

    PRINT INFO "Searching and validating framework dependencies.."
    depend # Check if required dependencies are installed

    ((PROGRESS_NOW++))

    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      if \
      ! [ "$OWNERSHIP" = "$D_OWNERSHIP" ] ||
      ! [ "$WEBUSER"   = "$D_WEBUSER"   ] ||
      ! [ "$USERSHELL" = "$D_USERSHELL" ]; then
        PRINT WARNING "Blueprint variable customization is deprecated, autogenerating .blueprintrc file.."
        if [ -f "$FOLDER/.blueprintrc" ]; then
          PRINT WARNING "Could not autogenerate .blueprintrc file, already exists."
        else
          echo -e \
            "OWNERSHIP=\"$OWNERSHIP\"\n" \
            "WEBUSER=\"$WEBUSER\"\n" \
            "USERSHELL=\"$USERSHELL\"" \
            > "$FOLDER/.blueprintrc"
          PRINT INFO "Autogenerated .blueprintrc file."
        fi
      fi
    fi

    ((PROGRESS_NOW++))

    placeshortcut # Place Blueprint shortcut

    ((PROGRESS_NOW++))

    # Link directories.
    PRINT INFO "Linking directories and filesystems.."
    {
      ln -s -r -T "$FOLDER/.blueprint/extensions/blueprint/public" "$FOLDER/public/extensions/blueprint"
      ln -s -r -T "$FOLDER/.blueprint/extensions/blueprint/assets" "$FOLDER/public/assets/extensions/blueprint"
      ln -s -r -T "$FOLDER/scripts/libraries" "$FOLDER/.blueprint/lib"
    } 2>> "$BLUEPRINT__DEBUG"
    php artisan storage:link &>> "$BLUEPRINT__DEBUG"

    ((PROGRESS_NOW++))

    # Copy "Blueprint" extension page logo from assets.
    cp "$FOLDER/.blueprint/assets/Emblem/emblem.jpg" "$FOLDER/.blueprint/extensions/blueprint/assets/logo.jpg"

    ((PROGRESS_NOW++))

    # Put application into maintenance.
    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INPUT "Would you like to put your application into maintenance while Blueprint is installing? (Y/n)"
      hide_progress
      read -r YN
      if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then
        MAINTENANCE="true"
        PRINT INFO "Put application into maintenance mode."
        php artisan down &>> "$BLUEPRINT__DEBUG"
      else
        MAINTENANCE="false"
        PRINT INFO "Putting application into maintenance has been skipped."
      fi
    else
      MAINTENANCE="false"
      PRINT INFO "Putting application into maintenance has been skipped."
    fi

    ((PROGRESS_NOW++))

    # Run migrations if Blueprint is not running through Docker.
    if [[ ( $DOCKER != "y" ) && ( $BLUEPRINT_ENVIRONMENT != "ci" ) ]]; then
      PRINT INFO "Running database migrations.."
      hide_progress
      php artisan migrate --force
    fi

    ((PROGRESS_NOW++))

    # Seed Blueprint database records
    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INFO "Seeding Blueprint database records.."
      php artisan db:seed --class=BlueprintSeeder --force &>> "$BLUEPRINT__DEBUG"
    fi

    ((PROGRESS_NOW++))

    # Flush cache.
    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INFO "Flushing cache.."
      {
        php artisan view:cache
        php artisan config:cache
        php artisan route:clear
        php artisan cache:clear
        php artisan bp:cache
        php artisan bp:version:cache
      } &>> "$BLUEPRINT__DEBUG"
    fi

    ((PROGRESS_NOW++))

    # Restart queue workers
    PRINT INFO "Restarting queue workers.."
    php artisan queue:restart &>> "$BLUEPRINT__DEBUG"

    ((PROGRESS_NOW++))

    # Make sure all files have correct permissions.
    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INFO "Changing Pterodactyl file ownership to '$OWNERSHIP'.."
      find "$FOLDER/" \
        -path "$FOLDER/node_modules" -prune \
        -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"
    fi

    ((PROGRESS_NOW++))

    PRINT INFO "Cleaning up.."
    rm -f \
      ".blueprint/dev/.gitkeep" \
      ".blueprint/dist/types/.gitkeep"

    ((PROGRESS_NOW++))

    # Rebuild panel assets.
    if [[ $BLUEPRINT_ENVIRONMENT != "ci" ]]; then
      PRINT INFO "Rebuilding panel assets.."
      hide_progress
      cd "$FOLDER" || cdhalt
      set -eo pipefail
      rm -rf "$FOLDER/node_modules/.cache"
      yarn run build:production --progress
      set +eo pipefail
    fi

    ((PROGRESS_NOW++))

    if [[ $MAINTENANCE == "true" ]]; then
      # Put application into production.
      PRINT INFO "Put application into production."
      php artisan up &>> "$BLUEPRINT__DEBUG"
    fi

    ((PROGRESS_NOW++))

    # Let the panel know the user has finished installation.
    dbAdd "blueprint.setupFinished"
    sed -i "s~NOTINSTALLED~INSTALLED~g" "$FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php"

    # Finish installation
    if [[ $BLUEPRINT_ENVIRONMENT != "upgrade2" ]]; then
      PRINT SUCCESS "Blueprint has completed its installation process."
      hide_progress
    fi

    exit 0
  fi
fi

Command() {
  PRINT FATAL "'$cmd' is not a valid command or argument. Use argument '-help' for a list of commands."
}

cmd="${2}"
case "$cmd" in
  -add|-install|-i) source ./scripts/commands/extensions/install.sh ;;
  -remove|-r) source ./scripts/commands/extensions/remove.sh ;;
  -query|-q) source ./scripts/commands/extensions/query.sh ;;
  -init|-I) source ./scripts/commands/developer/init.sh ;;
  -build|-b) source ./scripts/commands/developer/build.sh ;;
  -watch) source ./scripts/commands/developer/watch.sh ;;
  -dist) source ./scripts/commands/developer/dist.sh ;;
  -export|-e) source ./scripts/commands/developer/export.sh ;;
  -wipe|-w) source ./scripts/commands/developer/wipe.sh ;;
  -info|-f) source ./scripts/commands/misc/info.sh ;;
  -debug) source ./scripts/commands/misc/debug.sh ;;
  -help|-h|help|'') source ./scripts/commands/misc/help.sh ;;
  -version|-v) source ./scripts/commands/misc/version.sh ;;
  -rerun-install) source ./scripts/commands/advanced/rerun-install.sh ;;
  -upgrade) source ./scripts/commands/advanced/upgrade.sh ;;
esac

shift 2
Command "$@"
exit 0
