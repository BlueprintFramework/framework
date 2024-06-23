#!/bin/bash
# © 2023-2024 Ivy (prpl.wtf)

# Learn more @ blueprint.zip
# Source code available on github.com/blueprintframework/framework

# This should allow Blueprint to run in Docker. Please note that changing the $FOLDER variable after running
# the Blueprint installation script will not change anything in any files besides blueprint.sh.
  FOLDER=$(realpath "$(dirname "$0")")

# This stores the webserver ownership user which Blueprint uses when applying webserver permissions.
  OWNERSHIP="www-data:www-data" #;

# This stores options for permissions related to running install scripts the webserver user.
  WEBUSER="www-data" #;
  USERSHELL="/bin/bash" #;

# Defines the version Blueprint will display as the active one.
  VERSION="beta-F248-1"

# Default GitHub repository to use when upgrading Blueprint.
  REPOSITORY="BlueprintFramework/framework"



# Check if the script is being sourced - and if so - load bash autocompletion.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  _blueprint_completions() {
    local cur cmd opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    cmd="${COMP_WORDS[1]}"

    case "${cmd}" in
      -install|-add|-i) opts="$(find "$FOLDER"/*.blueprint | sed -e "s|^$FOLDER/||g" -e "s|.blueprint$||g")" ;;
      -remove|-r) opts="$(sed "s|,||g" "$FOLDER/.blueprint/extensions/blueprint/private/db/installed_extensions")" ;;
      -export) opts="expose" ;;
      -debug) opts="100 200" ;;
      -upgrade) opts="remote" ;;
      
      *) opts="-install -add -remove -init -build -export -wipe -version -help -info -debug -upgrade -rerun-install" ;;
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

# Check for panels that are using Docker, which should have better support in the future.
if [[ -f "/.dockerenv" ]]; then
  DOCKER="y"
  FOLDER="/app"
else
  DOCKER="n"
fi

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

# Write environment variables.
export BLUEPRINT__FOLDER=$FOLDER
export BLUEPRINT__VERSION=$VERSION
export BLUEPRINT__DEBUG="$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
export NODE_OPTIONS=--openssl-legacy-provider
# Write internal variables.
__BuildDir=".blueprint/extensions/blueprint/private/build"

# Automatically navigate to the Pterodactyl directory when running the core.
cd "$FOLDER" || return

# Import libraries.
source scripts/libraries/parse_yaml.sh || missinglibs+="[parse_yaml]"
source scripts/libraries/grabenv.sh    || missinglibs+="[grabenv]"
source scripts/libraries/logFormat.sh  || missinglibs+="[logFormat]"
source scripts/libraries/misc.sh       || missinglibs+="[misc]"


# -config
# usage: "cITEM=VALUE bash blueprint.sh -config"
if [[ "$1" == "-config" ]]; then

  # cTELEMETRY_ID
  # Update the telemetry id.
  if [[ "$cTELEMETRY_ID" != "" ]]; then
    echo "$cTELEMETRY_ID" > .blueprint/extensions/blueprint/private/db/telemetry_id
  fi

  # cDEVELOPER
  # Enable/Disable developer mode.
  if [[ "$cDEVELOPER" != "" ]]; then
    if [[ "$cDEVELOPER" == "true" ]]; then
      dbAdd "blueprint.developerEnabled"
    else
      dbRemove "blueprint.developerEnabled"
    fi
  fi

  echo .
  exit 0
fi

cdhalt() { PRINT FATAL "Attempted navigation into nonexistent directory, halting process."; exit 1; }


depend() {
  # Check for compatible node versions
  nodeVer=$(node -v)
  if [[ $nodeVer != "v17."* ]] \
  && [[ $nodeVer != "v18."* ]] \
  && [[ $nodeVer != "v19."* ]] \
  && [[ $nodeVer != "v20."* ]] \
  && [[ $nodeVer != "v21."* ]] \
  && [[ $nodeVer != "v22."* ]]; then
    DEPEND_MISSING=true
  fi

  # Check for required (both internal and external) dependencies.
  if \
  ! [ -x "$(command -v unzip)" ] ||                          # unzip
  ! [ -x "$(command -v node)" ] ||                           # node
  ! [ -x "$(command -v yarn)" ] ||                           # yarn
  ! [ -x "$(command -v zip)" ] ||                            # zip
  ! [ -x "$(command -v curl)" ] ||                           # curl
  ! [ -x "$(command -v php)" ] ||                            # php
  ! [ -x "$(command -v git)" ] ||                            # git
  ! [ -x "$(command -v grep)" ] ||                           # grep
  ! [ -x "$(command -v sed)" ] ||                            # sed
  ! [ -x "$(command -v awk)" ] ||                            # awk
  ! [ -x "$(command -v tput)" ] ||                           # tput
  ! [ "$(ls "node_modules/"*"cross-env"* 2> /dev/null)" ] || # cross-env
  ! [ "$(ls "node_modules/"*"webpack"* 2> /dev/null)"   ] || # webpack
  ! [ "$(ls "node_modules/"*"react"* 2> /dev/null)"     ] || # react
  [[ $missinglibs != "" ]]; then                             # internal
    DEPEND_MISSING=true
  fi

  # Exit when missing dependencies.
  if [[ $DEPEND_MISSING == true ]]; then
    PRINT FATAL "Some framework dependencies are not installed or detected."

    if [[ $nodeVer != "v18."* ]] \
    && [[ $nodeVer != "v19."* ]] \
    && [[ $nodeVer != "v20."* ]] \
    && [[ $nodeVer != "v21."* ]] \
    && [[ $nodeVer != "v22."* ]]; then
      PRINT FATAL "Required dependency \"node\" is using an unsupported version."
    fi

    if ! [ -x "$(command -v unzip)"                          ]; then PRINT FATAL "Required dependency \"unzip\" is not installed or detected.";     fi
    if ! [ -x "$(command -v node)"                           ]; then PRINT FATAL "Required dependency \"node\" is not installed or detected.";      fi
    if ! [ -x "$(command -v yarn)"                           ]; then PRINT FATAL "Required dependency \"yarn\" is not installed or detected.";      fi
    if ! [ -x "$(command -v zip)"                            ]; then PRINT FATAL "Required dependency \"zip\" is not installed or detected.";       fi
    if ! [ -x "$(command -v curl)"                           ]; then PRINT FATAL "Required dependency \"curl\" is not installed or detected.";      fi
    if ! [ -x "$(command -v php)"                            ]; then PRINT FATAL "Required dependency \"php\" is not installed or detected.";       fi
    if ! [ -x "$(command -v git)"                            ]; then PRINT FATAL "Required dependency \"git\" is not installed or detected.";       fi
    if ! [ -x "$(command -v grep)"                           ]; then PRINT FATAL "Required dependency \"grep\" is not installed or detected.";      fi
    if ! [ -x "$(command -v sed)"                            ]; then PRINT FATAL "Required dependency \"sed\" is not installed or detected.";       fi
    if ! [ -x "$(command -v awk)"                            ]; then PRINT FATAL "Required dependency \"awk\" is not installed or detected.";       fi
    if ! [ -x "$(command -v tput)"                           ]; then PRINT FATAL "Required dependency \"tput\" is not installed or detected.";      fi
    if ! [ "$(ls "node_modules/"*"cross-env"* 2> /dev/null)" ]; then PRINT FATAL "Required dependency \"cross-env\" is not installed or detected."; fi
    if ! [ "$(ls "node_modules/"*"webpack"* 2> /dev/null)"   ]; then PRINT FATAL "Required dependency \"webpack\" is not installed or detected.";   fi
    if ! [ "$(ls "node_modules/"*"react"* 2> /dev/null)"     ]; then PRINT FATAL "Required dependency \"react\" is not installed or detected.";     fi

    if [[ $missinglibs == *"[parse_yaml]"* ]]; then PRINT FATAL "Required internal dependency \"internal:parse_yaml\" is not installed or detected."; fi
    if [[ $missinglibs == *"[grabEnv]"*    ]]; then PRINT FATAL "Required internal dependency \"internal:grabEnv\" is not installed or detected.";    fi
    if [[ $missinglibs == *"[logFormat]"*  ]]; then PRINT FATAL "Required internal dependency \"internal:logFormat\" is not installed or detected.";  fi
    if [[ $missinglibs == *"[misc]"*       ]]; then PRINT FATAL "Required internal dependency \"internal:misc\" is not installed or detected.";       fi

    exit 1
  fi
}

# Assign variables for extension flags.
assignflags() {
  F_ignorePlaceholders=false
  F_forceLegacyPlaceholders=false
  F_hasInstallScript=false
  F_hasRemovalScript=false
  F_hasExportScript=false
  F_developerIgnoreInstallScript=false
  F_developerIgnoreRebuild=false
  F_developerForceMigrate=false
  F_developerKeepApplicationCache=false
  F_developerEscalateExportScript=false
  if [[ ( $flags == *"ignorePlaceholders,"*            ) || ( $flags == *"ignorePlaceholders"            ) ]]; then F_ignorePlaceholders=true            ;fi
  if [[ ( $flags == *"forceLegacyPlaceholders,"*       ) || ( $flags == *"forceLegacyPlaceholders"       ) ]]; then F_forceLegacyPlaceholders=true       ;fi
  if [[ ( $flags == *"hasInstallScript,"*              ) || ( $flags == *"hasInstallScript"              ) ]]; then F_hasInstallScript=true              ;fi
  if [[ ( $flags == *"hasRemovalScript,"*              ) || ( $flags == *"hasRemovalScript"              ) ]]; then F_hasRemovalScript=true              ;fi
  if [[ ( $flags == *"hasExportScript,"*               ) || ( $flags == *"hasExportScript"               ) ]]; then F_hasExportScript=true               ;fi
  if [[ ( $flags == *"developerIgnoreInstallScript,"*  ) || ( $flags == *"developerIgnoreInstallScript"  ) ]]; then F_developerIgnoreInstallScript=true  ;fi
  if [[ ( $flags == *"developerIgnoreRebuild,"*        ) || ( $flags == *"developerIgnoreRebuild"        ) ]]; then F_developerIgnoreRebuild=true        ;fi
  if [[ ( $flags == *"developerForceMigrate,"*         ) || ( $flags == *"developerForceMigrate"         ) ]]; then F_developerForceMigrate=true         ;fi
  if [[ ( $flags == *"developerKeepApplicationCache,"* ) || ( $flags == *"developerKeepApplicationCache" ) ]]; then F_developerKeepApplicationCache=true ;fi
  if [[ ( $flags == *"developerEscalateExportScript,"* ) || ( $flags == *"developerEscalateExportScript" ) ]]; then F_developerEscalateExportScript=true ;fi
}


# Adds the "blueprint" command to the /usr/local/bin directory and configures the correct permissions for it.
placeshortcut() {
  PRINT INFO "Placing Blueprint command shortcut.."
  {
    touch /usr/local/bin/blueprint
    chmod u+x \
      "$FOLDER/blueprint.sh" \
      /usr/local/bin/blueprint
  } >> "$BLUEPRINT__DEBUG"
  echo -e \
    "#!/bin/bash \n" \
    "if [[ \"\${BASH_SOURCE[0]}\" != \"\${0}\" ]]; then source \"$FOLDER/blueprint.sh\"; return 0; fi; "\
    "bash $FOLDER/blueprint.sh -bash \$@;" \
    > /usr/local/bin/blueprint
}
if ! [ -x "$(command -v blueprint)" ]; then placeshortcut; fi


if [[ $1 != "-bash" ]]; then
  if dbValidate "blueprint.setupFinished"; then
    PRINT FATAL "Installation process has already been finished before, consider using the 'blueprint' command."
    exit 2
  else
    # Only run if Blueprint is not in the process of upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      # Print Blueprint icon with ascii characters.
      echo -e "  ██\n██  ██\n  ████\n";
    fi

    PRINT INFO "Searching and validating framework dependencies.."
    # Check if required dependencies are installed
    depend

    # Place Blueprint shortcut
    placeshortcut

    # Link directories.
    PRINT INFO "Linking directories and filesystems.."
    {
      ln -s -r -T "$FOLDER/.blueprint/extensions/blueprint/public" "$FOLDER/public/extensions/blueprint"
      ln -s -r -T "$FOLDER/.blueprint/extensions/blueprint/assets" "$FOLDER/public/assets/extensions/blueprint"
      ln -s -r -T "$FOLDER/scripts/libraries" "$FOLDER/.blueprint/lib"
    } 2>> "$BLUEPRINT__DEBUG"
    php artisan storage:link &>> "$BLUEPRINT__DEBUG"

    PRINT INFO "Replacing internal placeholders.."
    # Copy "Blueprint" extension page logo from assets.
    cp "$FOLDER/.blueprint/assets/logo.jpg" "$FOLDER/.blueprint/extensions/blueprint/assets/logo.jpg"

    # Put application into maintenance.
    PRINT INPUT "Would you like to put your application into maintenance while Blueprint is installing? (Y/n)"
    read -r YN
    if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then
      MAINTENANCE="true"
      PRINT INFO "Put application into maintenance mode."
      php artisan down &>> "$BLUEPRINT__DEBUG"
    else
      MAINTENANCE="false"
      PRINT INFO "Putting application into maintenance has been skipped."
    fi

    # Flush cache.
    PRINT INFO "Flushing view, config and route cache.."
    {
      php artisan view:cache
      php artisan config:cache
      php artisan route:clear
      php artisan cache:clear
    } &>> "$BLUEPRINT__DEBUG"
    updateCacheReminder

    # Run migrations if Blueprint is not upgrading.
    if [[ ( $1 != "--post-upgrade" ) && ( $DOCKER != "y" ) ]]; then
      PRINT INPUT "Would you like to migrate your database? (Y/n)"
      read -r YN
      if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then
        PRINT INFO "Running database migrations.."
        php artisan migrate --force
      else
        PRINT INFO "Database migrations have been skipped."
      fi
    fi

    # Make sure all files have correct permissions.
    PRINT INFO "Changing Pterodactyl file ownership to '$OWNERSHIP'.."
    find "$FOLDER/" \
      -path "$FOLDER/node_modules" -prune \
      -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"

    # Rebuild panel assets.
    PRINT INFO "Rebuilding panel assets.."
    yarn run build:production --progress

    if [[ $DOCKER != "y" ]]; then
      # Sync some database values.
      PRINT INFO "Syncing Blueprint-related database values.."
      php artisan bp:sync
    fi

    if [[ $DOCKER != "y" ]] && [[ $MAINTENANCE == "true" ]]; then
      # Put application into production.
      PRINT INFO "Put application into production."
      php artisan up &>> "$BLUEPRINT__DEBUG"
    fi

    # Finish installation
    if [[ $1 != "--post-upgrade" ]]; then
      PRINT SUCCESS "Blueprint has completed its installation process."
    fi

    dbAdd "blueprint.setupFinished"
    # Let the panel know the user has finished installation.
    sed -i "s/NOTINSTALLED/INSTALLED/g" "$FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php"
    exit 0
  fi
fi


# help, -help, --help,
# h,    -h,    --h
if [[ ( $2 == "help" ) || ( $2 == "-help" ) || ( $2 == "--help" ) ||
      ( $2 == "h" )    || ( $2 == "-h" )    || ( $2 == "--h" )    || ( $2 == "" ) ]]; then VCMD="y"

  source ./scripts/commands/misc/help.sh

  HelpCommand
fi


# -i, -install, -add
if [[ ( $2 == "-i" ) || ( $2 == "-install" ) || ( $2 == "-add" ) ]]; then VCMD="y"
  if [[ $3 == "" ]]; then PRINT FATAL "Expected at least 1 argument but got 0.";exit 2;fi
  if [[ ( $3 == "./"* ) || ( $3 == "../"* ) || ( $3 == "/"* ) ]]; then PRINT FATAL "Cannot import extensions from external paths.";exit 2;fi

  PRINT INFO "Searching and validating framework dependencies.."
  # Check if required programs and libraries are installed.
  depend

  source ./scripts/commands/extensions/install.sh

  # Install selected extensions
  current=0
  extensions=$(shiftArgs "$@")
  total=$(echo "$extensions" | wc -w)
  for extension in $extensions; do
    (( current++ ))
    InstallCommand "$extension" "$current" "$total"
  done

  exit 0 # success
fi

# -r, -remove
if [[ ( $2 == "-r" ) || ( $2 == "-remove" ) ]]; then VCMD="y"
  if [[ $3 == "" ]]; then PRINT FATAL "Expected at least 1 argument but got 0.";exit 2;fi

  source ./scripts/commands/extensions/remove.sh

  # Remove selected extensions
  current=0
  extensions=$(shiftArgs "$@")
  total=$(echo "$extensions" | wc -w)
  for extension in $extensions; do
    (( current++ ))
    RemoveCommand "$extension" "$current" "$total"
  done

  exit 0 # success
fi


# -v, -version
if [[ ( $2 == "-v" ) || ( $2 == "-version" ) ]]; then VCMD="y"
  echo -e ${VERSION}
fi


# -debug
if [[ $2 == "-debug" ]]; then VCMD="y"
  if ! [[ $3 =~ [0-9] ]] && [[ $3 != "" ]]; then PRINT FATAL "Amount of debug lines must be a number."; exit 2; fi
  if [[ $3 -lt 1 ]]; then PRINT FATAL "Provide the amount of debug lines to print as an argument, which must be greater than one (1)."; exit 2; fi
  echo -e "\x1b[30;47;1m  --- DEBUG START ---  \x1b[0m"
  echo -e "$(v="$(<.blueprint/extensions/blueprint/private/debug/logs.txt)";printf -- "%s" "$v"|tail -"$3")"
  echo -e "\x1b[30;47;1m  ---  DEBUG END  ---  \x1b[0m"
fi


# -init
if [[ ( $2 == "-init" || $2 == "-I" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  # To prevent accidental wiping of your dev directory, you are unable to initialize another extension
  # until you wipe the contents of the .blueprint/dev directory.
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory contains files. To protect you against accidental data loss, you are unable to initialize another extension unless you clear the '.blueprint/dev' folder."
    exit 2
  fi

  ask_template() {
    PRINT INPUT "Choose an extension template:"
    echo -e "$(curl 'https://raw.githubusercontent.com/BlueprintFramework/templates/main/repository' 2>> "$BLUEPRINT__DEBUG")"
    read -r ASKTEMPLATE
    REDO_TEMPLATE=false

    # Template should not be empty
    if [[ ${ASKTEMPLATE} == "" ]]; then
      PRINT WARNING "Template should not be empty."
      REDO_TEMPLATE=true
    fi
    # Unknown template.
    if [[ $(echo -e "$(curl "https://raw.githubusercontent.com/BlueprintFramework/templates/main/${ASKTEMPLATE}/TemplateConfiguration.yml" 2>> "$BLUEPRINT__DEBUG")") == "404: Not Found" ]]; then
      PRINT WARNING "Unknown template, please choose a valid option."
      REDO_TEMPLATE=true
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_TEMPLATE} == true ]]; then ASKTEMPLATE=""; ask_template; fi
  }

  ask_name() {
    INPUT_DEFAULT="SpaceInvaders"
    PRINT INPUT "Name [$INPUT_DEFAULT]:"
    read -r ASKNAME
    REDO_NAME=false

    # Name should not be empty
    if [[ ${ASKNAME} == "" ]]; then
      ASKNAME="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_NAME} == true ]]; then ASKNAME=""; ask_name; fi
  }

  ask_identifier() {
    INPUT_DEFAULT="spaceinvaders"
    PRINT INPUT "Identifier [$INPUT_DEFAULT]:"
    read -r ASKIDENTIFIER
    REDO_IDENTIFIER=false

    # Identifier should not be empty
    if [[ ${ASKIDENTIFIER} == "" ]]; then
      ASKIDENTIFIER="$INPUT_DEFAULT"
    fi
    # Identifier should be a-z.
    if ! [[ ${ASKIDENTIFIER} =~ [a-z] ]]; then
      PRINT WARNING "Identifier should only contain a-z characters."
      REDO_IDENTIFIER=true
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_IDENTIFIER} == true ]]; then ASKIDENTIFIER=""; ask_identifier; fi
  }

  ask_description() {
    INPUT_DEFAULT="Shoot down space aliens!"
    PRINT INPUT "Description [$INPUT_DEFAULT]:"
    read -r ASKDESCRIPTION
    REDO_DESCRIPTION=false

    # Description should not be empty
    if [[ ${ASKDESCRIPTION} == "" ]]; then
      ASKDESCRIPTION="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_DESCRIPTION} == true ]]; then ASKDESCRIPTION=""; ask_description; fi
  }

  ask_version() {
    INPUT_DEFAULT="1.0"
    PRINT INPUT "Version [$INPUT_DEFAULT]:"
    read -r ASKVERSION
    REDO_VERSION=false

    # Version should not be empty
    if [[ ${ASKVERSION} == "" ]]; then
      ASKVERSION="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_VERSION} == true ]]; then ASKVERSION=""; ask_version; fi
  }

  ask_author() {
    INPUT_DEFAULT="byte"
    PRINT INPUT "Author [$INPUT_DEFAULT]:"
    read -r ASKAUTHOR
    REDO_AUTHOR=false

    # Author should not be empty
    if [[ ${ASKAUTHOR} == "" ]]; then
      ASKAUTHOR="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_AUTHOR} == true ]]; then ASKAUTHOR=""; ask_author; fi
  }

  ask_template
  ask_name
  ask_identifier
  ask_description
  ask_version
  ask_author

  tnum=${ASKTEMPLATE}
  PRINT INFO "Fetching templates.."
  if [[ $(php artisan bp:latest) != "$VERSION" ]]; then PRINT WARNING "Active Blueprint version is not latest, you might run into compatibility issues."; fi
  cd .blueprint/tmp || cdhalt
  git clone "https://github.com/BlueprintFramework/templates.git"
  cd "${FOLDER}"/.blueprint || cdhalt
  cp -R tmp/templates/* extensions/blueprint/private/build/templates/
  rm -R tmp/templates
  cd "${FOLDER}" || cdhalt

  eval "$(parse_yaml $__BuildDir/templates/"${tnum}"/TemplateConfiguration.yml t_)"

  PRINT INFO "Building template.."
  mkdir -p .blueprint/tmp/init
  cp -R $__BuildDir/templates/"${tnum}"/contents/* .blueprint/tmp/init/

  sed -i \
    -e "s~␀name␀~${ASKNAME}~g" \
    -e "s~␀identifier␀~${ASKIDENTIFIER}~g" \
    -e "s~␀description␀~${ASKDESCRIPTION}~g" \
    -e "s~␀ver␀~${ASKVERSION}~g" \
    -e "s~␀author␀~${ASKAUTHOR}~g" \
    -e "s~␀version␀~${VERSION}~g" \
    -e "s~\[name\]~${ASKNAME}~g" \
    -e "s~\[identifier\]~${ASKIDENTIFIER}~g" \
    -e "s~\[description\]~${ASKDESCRIPTION}~g" \
    -e "s~\[ver\]~${ASKVERSION}~g" \
    -e "s~\[author\]~${ASKAUTHOR}~g" \
    -e "s~\[version\]~${VERSION}~g" \
    ".blueprint/tmp/init/conf.yml"

  # Return files to folder.
  cp -R .blueprint/tmp/init/* .blueprint/dev/

  # Remove tmp files.
  PRINT INFO "Cleaning up build files.."
  rm -R \
    ".blueprint/tmp" \
    "$__BuildDir/templates/"*
  mkdir -p .blueprint/tmp

  PRINT SUCCESS "Extension files initialized and imported to '.blueprint/dev'."
  sendTelemetry "INITIALIZE_DEVELOPMENT_EXTENSION" >> "$BLUEPRINT__DEBUG"
fi


# -build
if [[ ( $2 == "-build" || $2 == "-b" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi
  PRINT INFO "Starting developer extension installation.."
  blueprint -i "[developer-build]"
fi


# -export
if [[ ( $2 == "-export" || $2 == "-e" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  PRINT INFO "Start packaging extension.."

  cd .blueprint || cdhalt
  rm dev/.gitkeep 2>> "$BLUEPRINT__DEBUG"

  eval "$(parse_yaml dev/conf.yml conf_)"; identifier="${conf_info_identifier}"

  cp -r dev/* tmp/
  cd tmp || cdhalt

  # Assign variables to extension flags.
  flags="$conf_info_flags"
  PRINT INFO "Reading and assigning extension flags.."
  assignflags

  if $F_hasExportScript; then
    chmod +x "${conf_data_directory}""/export.sh"

    # Run script while also parsing some useful variables for the export script to use.
    if $F_developerEscalateExportScript; then
      EXTENSION_IDENTIFIER="$conf_info_identifier"        \
      EXTENSION_TARGET="$conf_info_target"                \
      EXTENSION_VERSION="$conf_info_version"              \
      PTERODACTYL_DIRECTORY="$FOLDER"                     \
      BLUEPRINT_EXPORT_DIRECTORY="$FOLDER/.blueprint/tmp" \
      BLUEPRINT_VERSION="$VERSION"                        \
      bash "${conf_data_directory}"/export.sh
    else
      su "$WEBUSER" -s "$USERSHELL" -c "
          cd \"$FOLDER\"/.blueprint/tmp;
          EXTENSION_IDENTIFIER=\"$conf_info_identifier\"        \
          EXTENSION_TARGET=\"$conf_info_target\"                \
          EXTENSION_VERSION=\"$conf_info_version\"              \
          PTERODACTYL_DIRECTORY=\"$FOLDER\"                     \
          BLUEPRINT_EXPORT_DIRECTORY=\"$FOLDER/.blueprint/tmp\" \
          BLUEPRINT_VERSION=\"$VERSION\"                        \
          bash \"${conf_data_directory}\"/export.sh
        "
    fi
    echo -e "\e[0m\x1b[0m\033[0m"
  fi

  zip -r extension.zip ./*
  cd "${FOLDER}" || cdhalt
  cp .blueprint/tmp/extension.zip "${identifier}.blueprint"
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  if [[ $3 == "expose"* ]]; then
    PRINT INFO "Generating download url.. (expires after 2 minutes)"
    randstr=${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}
    mkdir .blueprint/extensions/blueprint/assets/exports/${randstr}
    cp "${identifier}".blueprint .blueprint/extensions/blueprint/assets/exports/${randstr}/"${identifier}".blueprint

    PRINT SUCCESS "Extension has been exported to '$(grabAppUrl)/assets/extensions/blueprint/exports/${randstr}/${identifier}.blueprint' and '${FOLDER}/${identifier}.blueprint'."
    sleep 120 && rm -R .blueprint/extensions/blueprint/assets/exports/${randstr} 2>> "$BLUEPRINT__DEBUG" &
  else
    PRINT SUCCESS "Extension has been exported to '${FOLDER}/${identifier}.blueprint'."
  fi
  sendTelemetry "EXPORT_DEVELOPMENT_EXTENSION" >> "$BLUEPRINT__DEBUG"
fi


# -wipe
if [[ ( $2 == "-wipe" || $2 == "-w" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  PRINT INPUT "You are about to wipe all of your development files, are you sure you want to continue? This cannot be undone. (y/N)"
  read -r YN
  if [[ ( ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ) || ( ( ${YN} == "" ) ) ]]; then PRINT INFO "Development files removal cancelled.";exit 1;fi

  PRINT INFO "Clearing development folder.."
  rm -R \
    .blueprint/dev/* \
    .blueprint/dev/.* \
    2>> "$BLUEPRINT__DEBUG"

  PRINT SUCCESS "Development folder has been cleared."
fi


# -info
if [[ ( $2 == "-info" || $2 == "-f" ) ]]; then VCMD="y"
  fetchversion()    { printf "\x1b[0m\x1b[37m"; if [[ $VERSION != "" ]]; then echo $VERSION; else echo "none"; fi }
  fetchfolder()     { printf "\x1b[0m\x1b[37m"; if [[ $FOLDER != "" ]]; then echo "$FOLDER"; else echo "none"; fi }
  fetchurl()        { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppUrl) != "" ]]; then grabAppUrl; else echo "none"; fi }
  fetchlocale()     { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppLocale) != "" ]]; then grabAppLocale; else echo "none"; fi }
  fetchtimezone()   { printf "\x1b[0m\x1b[37m"; if [[ $(grabAppTimezone) != "" ]]; then grabAppTimezone; else echo "none"; fi }
  fetchextensions() { printf "\x1b[0m\x1b[37m"; tr -cd ',' <.blueprint/extensions/blueprint/private/db/installed_extensions | wc -c | tr -d ' '; }
  fetchdeveloper()  { printf "\x1b[0m\x1b[37m"; if dbValidate "blueprint.developerEnabled"; then echo "true"; else echo "false"; fi }
  fetchtelemetry()  { printf "\x1b[0m\x1b[37m"; if [[ $(cat .blueprint/extensions/blueprint/private/db/telemetry_id) == "KEY_NOT_UPDATED" ]]; then echo "false"; else echo "true"; fi }
  fetchnode()       { printf "\x1b[0m\x1b[37m"; if [[ $(node -v) != "" ]]; then node -v; else echo "none"; fi }
  fetchyarn()       { printf "\x1b[0m\x1b[37m"; if [[ $(yarn -v) != "" ]]; then yarn -v; else echo "none"; fi }

  echo    " "
  echo -e "\x1b[34;1m    ⣿⣿    Version: $(fetchversion)"
  echo -e "\x1b[34;1m  ⣿⣿  ⣿⣿  Folder: $(fetchfolder)"
  echo -e "\x1b[34;1m    ⣿⣿⣿⣿  URL: $(fetchurl)"
  echo -e "\x1b[34;1m          Locale: $(fetchlocale)"
  echo -e "\x1b[34;1m          Timezone: $(fetchtimezone)"
  echo -e "\x1b[34;1m          Extensions: $(fetchextensions)"
  echo -e "\x1b[34;1m          Developer: $(fetchdeveloper)"
  echo -e "\x1b[34;1m          Telemetry: $(fetchtelemetry)"
  echo -e "\x1b[34;1m          Node: $(fetchnode)"
  echo -e "\x1b[34;1m          Yarn: $(fetchyarn)"
  echo -e "\x1b[0m"
fi


# -rerun-install
if [[ $2 == "-rerun-install" ]]; then VCMD="y"
  PRINT WARNING "This is an advanced feature, only proceed if you know what you are doing."
  dbRemove "blueprint.setupFinished"
  cd "${FOLDER}" || cdhalt
  bash blueprint.sh
fi


# -upgrade
if [[ $2 == "-upgrade" ]]; then VCMD="y"
  PRINT WARNING "This is an advanced feature, only proceed if you know what you are doing."

  # Confirmation question for developer upgrade.
  if [[ $3 == "remote" ]]; then
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


  if [[ $3 == "remote" ]]; then PRINT INFO "Fetching and pulling latest commit.."
  else                          PRINT INFO "Fetching and pulling latest release.."; fi

  mkdir "$FOLDER/.tmp"
  cp blueprint.sh .blueprint.sh.bak

  HAS_DEV=false
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT INFO "Backing up extension development files.."
    mkdir -p "$FOLDER/.tmp/dev"
    cp .blueprint/dev/* "$FOLDER/.tmp/dev/" -Rf
    HAS_DEV=true
  fi

  mkdir -p "$FOLDER/.tmp/files"
  cd "$FOLDER/.tmp/files" || cdhalt
  if [[ $3 == "remote" ]]; then
    if [[ $4 == "" ]]; then REMOTE_REPOSITORY="$REPOSITORY"
    else REMOTE_REPOSITORY="$4"; fi
    # download latest commit
    git clone https://github.com/"$REMOTE_REPOSITORY".git main
  else
    # download latest release
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

  if [[ ! -d "main" ]]; then
    cd "$FOLDER" || cdhalt
    rm -r "$FOLDER/.tmp" &>> "$BLUEPRINT__DEBUG"
    rm "$FOLDER/.blueprint.sh.bak" &>> "$BLUEPRINT__DEBUG"
    PRINT FATAL "Remote does not exist or encountered an error, try again later."
    exit 1
  fi

  # Remove some files/directories that don't have to be moved to the Pterodactyl folder.
  rm -r \
    "main/.github" \
    "main/.git" \
    "main/.gitignore" \
    "main/README.md" \
    &>> "$BLUEPRINT__DEBUG"

  # Copy fetched release files to the Pterodactyl directory and remove temp files.
  cp -r main/* "$FOLDER"/
  rm -r \
    "main" \
    "$FOLDER"/.blueprint \
    "$FOLDER"/.tmp/files
  cd "$FOLDER" || cdhalt

  # Clean up folders with potentially broken symlinks.
  rm \
    "resources/views/blueprint/admin/wrappers/"* \
    "resources/views/blueprint/dashboard/wrappers/"* \
    "routes/blueprint/application/"* \
    "routes/blueprint/client/"* \
    "routes/blueprint/web/"* \
    &>> /dev/null # cannot forward to debug dir because it does not exist

  chmod +x blueprint.sh
  sed -i -E \
    -e "s|OWNERSHIP=\"www-data:www-data\" #;|OWNERSHIP=\"$OWNERSHIP\" #;|g" \
    -e "s|WEBUSER=\"www-data\" #;|WEBUSER=\"$WEBUSER\" #;|g" \
    -e "s|USERSHELL=\"/bin/bash\" #;|USERSHELL=\"$USERSHELL\" #;|g" \
    "$FOLDER/blueprint.sh"
  mv "$FOLDER/blueprint" "$FOLDER/.blueprint"
  bash blueprint.sh --post-upgrade

  # Ask user if they'd like to migrate their database.
  PRINT INPUT "Would you like to migrate your database? (Y/n)"
  read -r YN
  if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then
    PRINT INFO "Running database migrations.."
    php artisan migrate --force
    php artisan up &>> "$BLUEPRINT__DEBUG"
  else
    PRINT INFO "Database migrations have been skipped."
  fi
  YN=""

  if [[ ${HAS_DEV} == true ]]; then
    PRINT INFO "Restoring extension development files.."
    mkdir -p .blueprint/dev
    cp "$FOLDER/.tmp/dev/"* .blueprint/dev -r
    rm "$FOLDER/.tmp/dev" -rf
  fi

  rm -r "$FOLDER/.tmp"

  # Post-upgrade checks.
  PRINT INFO "Validating update.."
  score=0

  if dbValidate "blueprint.setupFinished"; then score=$((score+1))
  else PRINT WARNING "'blueprint.setupFinished' could not be detected or found."; fi

  # Finalize upgrade.
  if [[ ${score} == 1 ]]; then
    PRINT SUCCESS "Upgrade finished."
    rm .blueprint.sh.bak
    exit 0 # success
  elif [[ ${score} == 0 ]]; then
    PRINT FATAL "All checks have failed. The 'blueprint.sh' file has been reverted."
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1 # error
  else
    PRINT FATAL "Some checks have failed. The 'blueprint.sh' file has been reverted."
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1 # error
  fi
fi



# When the users attempts to run an invalid command.
if [[ ${VCMD} != "y" && $1 == "-bash" ]]; then
  # This is logged as a "fatal" error since it's something that is making Blueprint run unsuccessfully.
  PRINT FATAL "'$2' is not a valid command or argument. Use argument '-help' for a list of commands."
  exit 2
fi