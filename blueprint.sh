#!/bin/bash

# blueprint.zip
# github.com/teamblueprint/main
# prpl.wtf

# This should allow Blueprint to run in Docker. Please note that changing the $FOLDER variable after running
# the Blueprint installation script will not change anything in any files besides blueprint.sh.
  FOLDER="/var/www/pterodactyl" #;

# If the version below does not match your downloaded version, please let us know.
  VERSION="alpha-NLM"



# Allow non-default Pterodactyl installation folders.
if [[ $_FOLDER != "" ]]; then
  if [[ ( ! -f "$FOLDER/.blueprint/extensions/blueprint/private/db/version" ) && ( $FOLDER == "/var/www/pterodactyl" ) ]]; then
    sed -i -E "s|FOLDER=\"/var/www/pterodactyl\" #;|FOLDER=\"$_FOLDER\" #;|g" "$_FOLDER"/blueprint.sh
  else
    echo "Variable cannot be replaced right now."
    exit 1
  fi
fi

# Check for panels that are using Docker, which should have better support in the future.
if [[ -f "/.dockerenv" ]]; then
  DOCKER="y"
else
  DOCKER="n"
fi

if [[ -d "$FOLDER/blueprint" ]]; then mv $FOLDER/blueprint $FOLDER/.blueprint; fi

if [[ $VERSION != "" ]]; then
  # This function makes sure some placeholders get replaced with the current Blueprint version.
  if [[ ! -f "$FOLDER/.blueprint/extensions/blueprint/private/db/version" ]]; then
    sed -E -i "s*::v*$VERSION*g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
    sed -E -i "s*::v*$VERSION*g" $FOLDER/.blueprint/extensions/blueprint/public/index.html
    touch $FOLDER/.blueprint/extensions/blueprint/private/db/version
  fi
fi

# Write environment variables.
export BLUEPRINT__FOLDER=$FOLDER
export BLUEPRINT__VERSION=$VERSION
export BLUEPRINT__DEBUG="$FOLDER"/.blueprint/extensions/blueprint/private/debug/logs.txt
export NODE_OPTIONS=--openssl-legacy-provider

# Automatically navigate to the Pterodactyl directory when running the core.
cd $FOLDER || return

# Import libraries.
source .blueprint/lib/bash_colors.sh              || missinglibs+="[bash_colors]"
source .blueprint/lib/parse_yaml.sh               || missinglibs+="[parse_yaml]"
source .blueprint/lib/db.sh                       || missinglibs+="[db]"
source .blueprint/lib/telemetry.sh                || missinglibs+="[telemetry]"
source .blueprint/lib/updateAdminCacheReminder.sh || missinglibs+="[updateAdminCacheReminder]"
source .blueprint/lib/grabenv.sh                  || missinglibs+="[grabenv]"
source .blueprint/lib/throwError.sh               || missinglibs+="[throwError]"

# Fallback to these functions if "bash_colors.sh" is missing
if [[ $missinglibs == *"[bash_colors]"* ]]; then
  log_reset() { echo -e "$1"; }
  log_reset_underline() { echo -e "$1"; }
  log_reset_reverse() { echo -e "$1"; }
  log_default() { echo -e "$1"; }
  log_defaultb () { echo -e "$1"; }
  log_bold() { echo -e "$1"; }
  log_bright() { echo -e "$1"; }
  log_underscore() { echo -e "$1"; }
  log_reverse() { echo -e "$1"; }
  log_black() { echo -e "$1"; }
  log_red() { echo -e "$1"; }
  log_green() { echo -e "$1"; }
  log_brown() { echo -e "$1"; }
  log_blue() { echo -e "$1"; }
  log_magenta() { echo -e "$1"; }
  log_cyan() { echo -e "$1"; }
  log_white() { echo -e "$1"; }
  log_yellow() { echo -e "$1"; }
  log_blackb() { echo -e "$1"; }
  log_redb() { echo -e "$1"; }
  log_greenb() { echo -e "$1"; }
  log_brownb() { echo -e "$1"; }
  log_blueb() { echo -e "$1"; }
  log_magentab() { echo -e "$1"; }
  log_cyanb() { echo -e "$1"; }
  log_whiteb() { echo -e "$1"; }
  log_yellowb() { echo -e "$1"; }
fi



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
  exit 1
fi


# Function that exits the script after logging a "red" message.
quit_red() { log_red "$1"; exit 1; }
throw() { throwError "$1"; exit 1; }


depend() {
  # Check for incorrect node version.
  nodeVer=$(node -v)
  if [[ $nodeVer != "v17."* ]] && [[ $nodeVer != "v18."* ]] && [[ $nodeVer != "v19."* ]] && [[ $nodeVer != "v20."* ]] && [[ $nodeVer != "v21."* ]]; then DEPEND_MISSING=true; fi

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
  ! [ "$(ls "node_modules/"*"cross-env"* 2> /dev/null)" ] || # cross-env
  [[ $missinglibs != "" ]]; then                             # internal
    DEPEND_MISSING=true
  fi

  # Exit when missing dependencies.
  if [[ $DEPEND_MISSING == true ]]; then 
    log_red log_bold "[FATAL] Blueprint found errors for the following dependencies:"

    if [[ $nodeVer != "v18."* ]] && [[ $nodeVer != "v19."* ]] && [[ $nodeVer != "v20."* ]] && [[ $nodeVer != "v21."* ]]; then log_red "  - \"node\" ($nodeVer) is an unsupported version."; fi

    if ! [ -x "$(command -v unzip)"                          ]; then log_red "  - \"unzip\" is not installed or detected.";     fi
    if ! [ -x "$(command -v node)"                           ]; then log_red "  - \"node\" is not installed or detected.";      fi
    if ! [ -x "$(command -v yarn)"                           ]; then log_red "  - \"yarn\" is not installed or detected.";      fi
    if ! [ -x "$(command -v zip)"                            ]; then log_red "  - \"zip\" is not installed or detected.";       fi
    if ! [ -x "$(command -v curl)"                           ]; then log_red "  - \"curl\" is not installed or detected.";      fi
    if ! [ -x "$(command -v php)"                            ]; then log_red "  - \"php\" is not installed or detected.";       fi
    if ! [ -x "$(command -v git)"                            ]; then log_red "  - \"git\" is not installed or detected.";       fi
    if ! [ -x "$(command -v grep)"                           ]; then log_red "  - \"grep\" is not installed or detected.";      fi
    if ! [ -x "$(command -v sed)"                            ]; then log_red "  - \"sed\" is not installed or detected.";       fi
    if ! [ -x "$(command -v awk)"                            ]; then log_red "  - \"awk\" is not installed or detected.";       fi
    if ! [ "$(ls "node_modules/"*"cross-env"* 2> /dev/null)" ]; then log_red "  - \"cross-env\" is not installed or detected."; fi

    if [[ $missinglibs == *"[bash_colors]"*              ]]; then log_red "  - \"internal:bash_colors\" is not installed or detected.";              fi
    if [[ $missinglibs == *"[parse_yaml]"*               ]]; then log_red "  - \"internal:parse_yaml\" is not installed or detected.";               fi
    if [[ $missinglibs == *"[db]"*                       ]]; then log_red "  - \"internal:db\" is not installed or detected.";                       fi
    if [[ $missinglibs == *"[telemetry]"*                ]]; then log_red "  - \"internal:telemetry\" is not installed or detected.";                fi
    if [[ $missinglibs == *"[updateAdminCacheReminder]"* ]]; then log_red "  - \"internal:updateAdminCacheReminder\" is not installed or detected."; fi
    if [[ $missinglibs == *"[grabEnv]"*                  ]]; then log_red "  - \"internal:grabEnv\" is not installed or detected.";                  fi
    if [[ $missinglibs == *"[throwError]"*               ]]; then log_red "  - \"internal:throwError\" is not installed or detected.";               fi

    exit 1
  fi
}

# Assign variables for extension flags.
assignflags() {
  F_ignorePlaceholders=false
  F_ignoreAlphabetPlaceholders=false
  F_hasInstallScript=false
  F_hasRemovalScript=false
  F_hasExportScript=false
  F_developerIgnoreInstallScript=false
  F_developerIgnoreRebuild=false
  if [[ ( $flags == *"ignorePlaceholders,"*           ) || ( $flags == *"ignorePlaceholders"           ) ]]; then F_ignorePlaceholders=true           ;fi
  if [[ ( $flags == *"ignoreAlphabetPlaceholders,"*   ) || ( $flags == *"ignoreAlphabetPlaceholders"   ) ]]; then F_ignoreAlphabetPlaceholders=true   ;fi
  if [[ ( $flags == *"hasInstallScript,"*             ) || ( $flags == *"hasInstallScript"             ) ]]; then F_hasInstallScript=true             ;fi
  if [[ ( $flags == *"hasRemovalScript,"*             ) || ( $flags == *"hasRemovalScript"             ) ]]; then F_hasRemovalScript=true             ;fi
  if [[ ( $flags == *"hasExportScript,"*              ) || ( $flags == *"hasExportScript"              ) ]]; then F_hasExportScript=true              ;fi
  if [[ ( $flags == *"developerIgnoreInstallScript,"* ) || ( $flags == *"developerIgnoreInstallScript" ) ]]; then F_developerIgnoreInstallScript=true ;fi
  if [[ ( $flags == *"developerIgnoreRebuild,"*       ) || ( $flags == *"developerIgnoreRebuild"       ) ]]; then F_developerIgnoreRebuild=true       ;fi
}


# Adds the "blueprint" command to the /usr/local/bin directory and configures the correct permissions for it.
touch /usr/local/bin/blueprint >> $BLUEPRINT__DEBUG
echo -e "#!/bin/bash\nbash $FOLDER/blueprint.sh -bash \$@;" > /usr/local/bin/blueprint
chmod u+x $FOLDER/blueprint.sh >> $BLUEPRINT__DEBUG
chmod u+x /usr/local/bin/blueprint >> $BLUEPRINT__DEBUG


if [[ $1 != "-bash" ]]; then
  if dbValidate "blueprint.setupFinished"; then
    quit_red "[FATAL] This command only works if you have yet to install Blueprint. Run 'blueprint (cmd) [arg]' instead."
  else
    # Only run if Blueprint is not in the process of upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log "  ██\n██  ██\n  ████\n"; # Blueprint "ascii" "logo".
      if [[ $DOCKER == "y" ]]; then
        log_yellow "[WARNING] Docker is not officially supported by Blueprint and you will run into errors. Only continue if you know what you are doing."
      fi
    fi

    log_bright "[INFO] Checking dependencies.."
    # Check if required programs are installed
    depend

    # Link directories.
    log_bright "[INFO] Linking directories.."
    cd $FOLDER/public/extensions        || throw 'cdMissingDirectory'; ln -s -T $FOLDER/.blueprint/extensions/blueprint/public blueprint  2>> $BLUEPRINT__DEBUG; cd $FOLDER || throw 'cdMissingDirectory'
    cd $FOLDER/public/assets/extensions || throw 'cdMissingDirectory'; ln -s -T $FOLDER/.blueprint/extensions/blueprint/assets blueprint  2>> $BLUEPRINT__DEBUG; cd $FOLDER || throw 'cdMissingDirectory'

    # Update folder placeholder on PlaceholderService and admin layout.
    log_bright "[INFO] Updating folder placeholders.."
    sed -i "s!::f!$FOLDER!g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
    sed -i "s!::f!$FOLDER!g" $FOLDER/resources/views/layouts/admin.blade.php

    # Copy "Blueprint" extension page logo from assets.
    log_bright "[INFO] Copying Blueprint logo from assets.."
    cp $FOLDER/.blueprint/assets/logo.jpg $FOLDER/.blueprint/extensions/blueprint/assets/logo.jpg

    # Put application into maintenance.
    log_bright "[INFO] Enable maintenance."
    php artisan down &>> $BLUEPRINT__DEBUG

    # Clear view cache.
    log_bright "[INFO] Clearing view cache.."
    php artisan view:clear &>> $BLUEPRINT__DEBUG
    php artisan config:clear &>> $BLUEPRINT__DEBUG

    # Link filesystems.
    log_bright "[INFO] Linking filesystems.."
    php artisan storage:link &>> $BLUEPRINT__DEBUG 

    # Roll admin css refresh number.
    log_bright "[INFO] Rolling admin cache refresh class name."
    updateCacheReminder

    # Run migrations if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
      read -r YN
      if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then 
        log_bright "[INFO] Running database migrations.."
        php artisan migrate --force
      else
        log_bright "[INFO] Database migrations have been skipped."
      fi
    fi

    # Make sure all files have correct permissions.
    log_bright "[INFO] Changing file ownership to www-data.."
    chown -R www-data:www-data $FOLDER/* &
    chown -R www-data:www-data $FOLDER/.blueprint/* &
    wait

    # Rebuild panel assets.
    log_bright "[INFO] Rebuilding panel assets.."
    yarn run build:production

    # Clear route cache.
    log_bright "[INFO] Updating route cache to include recent changes.."
    php artisan route:cache &>> $BLUEPRINT__DEBUG 

    # Put application into production.
    log_bright "[INFO] Disable maintenance."
    php artisan up &>> $BLUEPRINT__DEBUG

    # Sync some database values.
    log_bright "[INFO] Syncing database values.."
    php artisan bp:sync

    # Only show donate + success message if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_green "\n\n[SUCCESS] Blueprint has finished it's installation process."
    fi

    dbAdd "blueprint.setupFinished"
    # Let the panel know the user has finished installation.
    sed -i "s!NOTINSTALLED!INSTALLED!g" $FOLDER/app/BlueprintFramework/Services/PlaceholderService/BlueprintPlaceholderService.php
    exit 1
  fi
fi


# -i, -install
if [[ ( $2 == "-i" ) || ( $2 == "-install" ) ]]; then VCMD="y"
  if [[ $(( $# - 2 )) != 1 ]]; then quit_red "[FATAL] Expected 1 argument but got $(( $# - 2 )).";fi
  if [[ ( $3 == "./"* ) || ( $3 == "../"* ) || ( $3 == "/"* ) ]]; then quit_red "[FATAL] Installing extensions located in paths outside of '$FOLDER' is not possible.";fi

  log_bright "[INFO] Checking dependencies.."
  # Check if required programs are installed
  depend

  # The following code does some magic to allow for extensions with a
  # different root folder structure than expected by Blueprint.
  if [[ $3 == "test␀" ]]; then
    dev=true
    n="dev"
    mkdir -p ".blueprint/tmp/dev"
    cp -R ".blueprint/dev/"* ".blueprint/tmp/dev/"
  else
    dev=false
    n="$3"
    FILE="${n}.blueprint"
    if [[ ( $FILE == *".blueprint.blueprint" ) && ( $n == *".blueprint" ) ]]; then quit_red "[FATAL] Argument one in '-install' must not end with '.blueprint'."; fi
    if [[ ! -f "$FILE" ]]; then quit_red "[FATAL] $FILE could not be found.";fi

    ZIP="${n}.zip"
    cp "$FILE" ".blueprint/tmp/$ZIP"
    cd ".blueprint/tmp" || throw 'cdMissingDirectory'
    unzip -o -qq "$ZIP"
    rm "$ZIP"
    if [[ ! -f "$n/*" ]]; then
      cd ".." || throw 'cdMissingDirectory'
      rm -R "tmp"
      mkdir -p "tmp"
      cd "tmp" || throw 'cdMissingDirectory'

      mkdir -p "./$n"
      cp "../../$FILE" "./$n/$ZIP"
      cd "$n" || throw 'cdMissingDirectory'
      unzip -o -qq "$ZIP"
      rm "$ZIP"
      cd ".." || throw 'cdMissingDirectory'
    fi
  fi

  # Return to the Pterodactyl installation folder.
  cd $FOLDER || throw 'cdMissingDirectory'

  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/tmp/$n/conf.yml" ]]; then 
    # Quit if the extension doesn't have a conf.yml file.
    rm -R ".blueprint/tmp/$n"
    throw "confymlNotFound"
  fi

  eval "$(parse_yaml .blueprint/tmp/"${n}"/conf.yml conf_)"

  # Add aliases for config values to make working with them easier.
  name="$conf_info_name"
  identifier="$conf_info_identifier"
  description="$conf_info_description"
  flags="$conf_info_flags" #(optional)
  version="$conf_info_version"
  target="$conf_info_target"
  author="$conf_info_author" #(optional)
  icon="$conf_info_icon" #(optional)
  website="$conf_info_website"; #(optional)

  admin_view="$conf_admin_view"
  admin_controller="$conf_admin_controller"; #(optional)
  admin_css="$conf_admin_css"; #(optional)
  admin_wrapper="$conf_admin_wrapper"; #(optional)

  dashboard_css="$conf_dashboard_css"; #(optional)
  dashboard_wrapper="$conf_dashboard_wrapper"; #(optional)
  dashboard_components="$conf_dashboard_components"; #(optional)

  data_directory="$conf_data_directory"; #(optional)
  data_public="$conf_data_public"; #(optional)

  database_migrations="$conf_database_migrations"; #(optional)
  
  # "prevent" folder "escaping"
  if [[ ( $icon                 == "/"* ) || ( $icon                 == *"/.."* ) || ( $icon                 == *"../"* ) || ( $icon                 == *"/../"* ) || ( $icon                 == *"\n"* ) ]] ||
     [[ ( $admin_view           == "/"* ) || ( $admin_view           == *"/.."* ) || ( $admin_view           == *"../"* ) || ( $admin_view           == *"/../"* ) || ( $admin_view           == *"\n"* ) ]] ||
     [[ ( $admin_controller     == "/"* ) || ( $admin_controller     == *"/.."* ) || ( $admin_controller     == *"../"* ) || ( $admin_controller     == *"/../"* ) || ( $admin_controller     == *"\n"* ) ]] ||
     [[ ( $admin_css            == "/"* ) || ( $admin_css            == *"/.."* ) || ( $admin_css            == *"../"* ) || ( $admin_css            == *"/../"* ) || ( $admin_css            == *"\n"* ) ]] ||
     [[ ( $admin_wrapper        == "/"* ) || ( $admin_wrapper        == *"/.."* ) || ( $admin_wrapper        == *"../"* ) || ( $admin_wrapper        == *"/../"* ) || ( $admin_wrapper        == *"\n"* ) ]] ||
     [[ ( $dashboard_css        == "/"* ) || ( $dashboard_css        == *"/.."* ) || ( $dashboard_css        == *"../"* ) || ( $dashboard_css        == *"/../"* ) || ( $dashboard_css        == *"\n"* ) ]] ||
     [[ ( $dashboard_wrapper    == "/"* ) || ( $dashboard_wrapper    == *"/.."* ) || ( $dashboard_wrapper    == *"../"* ) || ( $dashboard_wrapper    == *"/../"* ) || ( $dashboard_wrapper    == *"\n"* ) ]] ||
     [[ ( $dashboard_components == "/"* ) || ( $dashboard_components == *"/.."* ) || ( $dashboard_components == *"../"* ) || ( $dashboard_components == *"/../"* ) || ( $dashboard_components == *"\n"* ) ]] ||
     [[ ( $data_directory       == "/"* ) || ( $data_directory       == *"/.."* ) || ( $data_directory       == *"../"* ) || ( $data_directory       == *"/../"* ) || ( $data_directory       == *"\n"* ) ]] ||
     [[ ( $data_public          == "/"* ) || ( $data_public          == *"/.."* ) || ( $data_public          == *"../"* ) || ( $data_public          == *"/../"* ) || ( $data_public          == *"\n"* ) ]] ||
     [[ ( $database_migrations  == "/"* ) || ( $database_migrations  == *"/.."* ) || ( $database_migrations  == *"../"* ) || ( $database_migrations  == *"/../"* ) || ( $database_migrations  == *"\n"* ) ]]; then
    rm -R ".blueprint/tmp/$n"
    throw "pathsEscape"
  fi

  # prevent potentional problems during installation due to wrongly defined folders
  if [[ ( $dashboard_components == *"/" ) || 
        ( $data_directory == *"/"       ) || 
        ( $data_public == *"/"          ) || 
        ( $database_migrations == *"/"  ) ]]; then
    rm -R ".blueprint/tmp/$n"
    quit_red "[FATAL] Directory paths in conf.yml should not end with a slash."
  fi

  # check if extension still has placeholder values
  if [[ ( $name    == "␀name␀" ) || ( $identifier == "␀identifier␀" ) || ( $description == "␀description␀" ) ]] ||
     [[ ( $version == "␀ver␀"  ) || ( $target     == "␀version␀"    ) || ( $author      == "␀author␀"      ) ]]; then
    rm -R ".blueprint/tmp/$n"
    quit_red "[FATAL] Some conf.yml options should be replaced automatically by Blueprint when using \"-init\", but that did not happen. Please verify you have the correct information in your conf.yml and then try again."
  fi

  # Detect if extension is already installed and prepare the upgrading process.
  if [[ $(cat .blueprint/extensions/blueprint/private/db/installed_extensions) == *"$identifier,"* ]]; then
    log_bright "[INFO] Extension appears to be installed already, reading variables.."
    eval "$(parse_yaml .blueprint/extensions/"${identifier}"/private/.store/conf.yml old_)"
    DUPLICATE="y"

    if [[ ! -f ".blueprint/extensions/$identifier/private/.store/build/button.blade.php" ]]; then
      rm -R ".blueprint/tmp/$n"
      quit_red "[FATAL] Upgrading extension has failed due to missing essential .store files."
    fi

    # Clean up some old extension files.
    log_bright "[INFO] Cleaning up old extension files.."
    if [[ $old_data_public != "" ]]; then
      # Clean up old public folder.
      rm -R ".blueprint/extensions/$identifier/public"
      mkdir ".blueprint/extensions/$identifier/public"
    fi
  fi

  # Assign variables to extension flags.
  log_bright "[INFO] Assigning variables to extension flags.."
  assignflags

  # Force http/https url scheme for extension website urls.
  if [[ $website != "" ]]; then
    if [[ ( $website != "https://"* ) && ( $website != "http://"* ) ]]; then
      website="http://${conf_info_website}"
      conf_info_website="${website}"
    fi


    # Change link icon depending on website url.
    websiteiconclass="bx-link-external"

    # git
    if [[ $website == *"://github.com/"*  ]] || [[ $website == *"://www.github.com/"*  ]] ||
       [[ $website == *"://github.com"    ]] || [[ $website == *"://www.github.com"    ]] ||
       [[ $website == *"://gitlab.com/"*  ]] || [[ $website == *"://www.gitlab.com/"*  ]] ||
       [[ $website == *"://gitlab.com"    ]] || [[ $website == *"://www.gitlab.com"    ]]; then websiteiconclass="bx-git-branch";   fi
    # discord
    if [[ $website == *"://discord.com/"* ]] || [[ $website == *"://www.discord.com/"* ]] ||
       [[ $website == *"://discord.com"   ]] || [[ $website == *"://www.discord.com"   ]] ||
       [[ $website == *"://discord.gg/"*  ]] || [[ $website == *"://www.discord.gg/"*  ]] ||
       [[ $website == *"://discord.gg"    ]] || [[ $website == *"://www.discord.gg"    ]]; then websiteiconclass="bxl-discord-alt"; fi
    # patreon
    if [[ $website == *"://patreon.com/"* ]] || [[ $website == *"://www.patreon.com/"* ]] ||
       [[ $website == *"://patreon.com"   ]] || [[ $website == *"://www.patreon.com"   ]]; then websiteiconclass="bxl-patreon";     fi
    # reddit
    if [[ $website == *"://reddit.com/"*  ]] || [[ $website == *"://www.reddit.com/"*  ]] ||
       [[ $website == *"://reddit.com"    ]] || [[ $website == *"://www.reddit.com"    ]]; then websiteiconclass="bxl-reddit";      fi
    # trello
    if [[ $website == *"://trello.com/"*  ]] || [[ $website == *"://www.trello.com/"*  ]] ||
       [[ $website == *"://trello.com"    ]] || [[ $website == *"://www.trello.com"    ]]; then websiteiconclass="bxl-trello";      fi
  fi

  if [[ $dev == true ]]; then
    mv ".blueprint/tmp/$n" ".blueprint/tmp/$identifier"
    n=$identifier
  fi

  if ! $F_ignorePlaceholders; then
    # Prepare variables for placeholders
    log_bright "[INFO] Preparing placeholders.."
    DIR=".blueprint/tmp/$n"
    INSTALLMODE="normal"
    installation_timestamp=$(date +%s)
    if [[ $dev == true ]]; then INSTALLMODE="developer"; fi
    EXTPUBDIR="$FOLDER/.blueprint/extensions/$identifier/public"
    if [[ $data_public == "" ]]; then EXTPUBDIR="null"; fi
    if $F_ignoreAlphabetPlaceholders; then log_bright "[INFO] Alphabet placeholders will be skipped due to the 'ignoreAlphabetPlaceholders' flag."; fi

    log_bright log_bold "[INFO] Applying placeholders.."
    PLACE_PLACEHOLDERS() {
      local dir="$1"
      for file in "$dir"/*; do
        if [ -f "$file" ]; then
          file=${file// /\\ }
          sed -i "s~\^#version#\^~$version~g" "$file"
          sed -i "s~\^#author#\^~$author~g" "$file"
          sed -i "s~\^#name#\^~$name~g" "$file"
          sed -i "s~\^#identifier#\^~$identifier~g" "$file"
          sed -i "s~\^#path#\^~$FOLDER~g" "$file"
          sed -i "s~\^#datapath#\^~$FOLDER/.blueprint/extensions/$identifier/private~g" "$file"
          sed -i "s~\^#publicpath#\^~$EXTPUBDIR~g" "$file"
          sed -i "s~\^#installmode#\^~$INSTALLMODE~g" "$file"
          sed -i "s~\^#blueprintversion#\^~$VERSION~g" "$file"
          sed -i "s~\^#timestamp#\^~$installation_timestamp~g" "$file"
          sed -i "s~\^#componentroot#\^~@/blueprint/extensions/$identifier~g" "$file"

          if ! $F_ignoreAlphabetPlaceholders; then
            sed -i "s~__version__~$version~g" "$file"
            sed -i "s~__author__~$author~g" "$file"
            sed -i "s~__identifier__~$identifier~g" "$file"
            sed -i "s~__name__~$name~g" "$file"
            sed -i "s~__path__~$FOLDER~g" "$file"
            sed -i "s~__datapath__~$FOLDER/.blueprint/extensions/$identifier/private~g" "$file"
            sed -i "s~__publicpath__~$EXTPUBDIR~g" "$file"
            sed -i "s~__installmode__~$INSTALLMODE~g" "$file"
            sed -i "s~__blueprintversion__~$VERSION~g" "$file"
            sed -i "s~__timestamp__~$installation_timestamp~g" "$file"
            sed -i "s~__componentroot__~@/blueprint/extensions/$identifier~g" "$file"
          fi

          log_bright "  - ${file}"
        elif [ -d "$file" ]; then
          PLACE_PLACEHOLDERS "$file"
        fi
      done
    }

    PLACE_PLACEHOLDERS "$DIR"
  else log_bright "[INFO] Placeholders will be skipped due to the 'ignorePlaceholders' flag."; fi

  if [[ $name == "" ]]; then rm -R ".blueprint/tmp/$n";               quit_red "[FATAL] 'info_name' is a required configuration option.";fi
  if [[ $identifier == "" ]]; then rm -R ".blueprint/tmp/$n";         quit_red "[FATAL] 'info_identifier' is a required configuration option.";fi
  if [[ $description == "" ]]; then rm -R ".blueprint/tmp/$n";        quit_red "[FATAL] 'info_description' is a required configuration option.";fi
  if [[ $version == "" ]]; then rm -R ".blueprint/tmp/$n";            quit_red "[FATAL] 'info_version' is a required configuration option.";fi
  if [[ $target == "" ]]; then rm -R ".blueprint/tmp/$n";             quit_red "[FATAL] 'info_target' is a required configuration option.";fi

  if [[ $icon == "" ]]; then                                      log_yellow "[WARNING] This extension does not come with an icon, consider adding one.";fi
  if [[ $admin_controller == "" ]]; then                             log_bright "[INFO] Admin controller field left blank, using default controller instead.."
    controller_type="default";else controller_type="custom";fi
  if [[ $admin_view == "" ]]; then rm -R ".blueprint/tmp/$n";         quit_red "[FATAL] 'admin_view' is a required configuration option.";fi
  if [[ $target != "$VERSION" ]]; then                              log_yellow "[WARNING] This extension is built for version $target, but your version is $VERSION.";fi
  if [[ $identifier != "$n" ]]; then rm -R ".blueprint/tmp/$n";         quit_red "[FATAL] The extension file name must be the same as your identifier. (example: identifier.blueprint)";fi
  if [[ $identifier == "blueprint" ]]; then rm -R ".blueprint/tmp/$n";quit_red "[FATAL] Extensions can not have the identifier 'blueprint'.";fi

  if [[ $identifier =~ [a-z] ]]; then                                log_bright "[INFO] Identifier a-z checks passed."
  else rm -R ".blueprint/tmp/$n";                                     quit_red "[FATAL] The extension identifier should be lowercase and only contain characters a-z.";fi
  


  # Validate paths to files and directories defined in conf.yml.
  log_bright "[INFO] Validating conf.yml file path values.."
  if [[ ( ! -f ".blueprint/tmp/$n/$icon"                 ) && ( ${icon} != ""                 ) ]] ||    # file:   icon                 (optional)
     [[ ( ! -f ".blueprint/tmp/$n/$admin_view"           )                                      ]] ||    # file:   admin_view
     [[ ( ! -f ".blueprint/tmp/$n/$admin_controller"     ) && ( ${admin_controller} != ""     ) ]] ||    # file:   admin_controller     (optional)
     [[ ( ! -f ".blueprint/tmp/$n/$admin_css"            ) && ( ${admin_css} != ""            ) ]] ||    # file:   admin_css            (optional)
     [[ ( ! -f ".blueprint/tmp/$n/$admin_wrapper"        ) && ( ${admin_wrapper} != ""        ) ]] ||    # file:   admin_wrapper        (optional)
     [[ ( ! -f ".blueprint/tmp/$n/$dashboard_css"        ) && ( ${dashboard_css} != ""        ) ]] ||    # file:   dashboard_css        (optional)
     [[ ( ! -f ".blueprint/tmp/$n/$dashboard_wrapper"    ) && ( ${dashboard_wrapper} != ""    ) ]] ||    # file:   dashboard_wrapper    (optional)
     [[ ( ! -d ".blueprint/tmp/$n/$dashboard_components" ) && ( ${dashboard_components} != "" ) ]] ||    # folder: dashboard_components (optional)
     [[ ( ! -d ".blueprint/tmp/$n/$data_directory"       ) && ( ${data_directory} != ""       ) ]] ||    # folder: data_directory       (optional)
     [[ ( ! -d ".blueprint/tmp/$n/$data_public"          ) && ( ${data_public} != ""          ) ]] ||    # folder: data_public          (optional)
     [[ ( ! -d ".blueprint/tmp/$n/$data_migrations"      ) && ( ${data_migrations} != ""      ) ]];then  # folder: data_migrations      (optional)
    rm -R ".blueprint/tmp/$n"
    throw 'confymlMissingFiles'
  fi

  # Validate custom script paths.
  if [[ $F_hasInstallScript == true || $F_hasRemovalScript == true || $F_hasExportScript == true ]]; then
    if [[ $data_directory == "" ]]; then rm -R ".blueprint/tmp/$n"; throw 'scriptsNoDataDir'; fi

    if [[ $F_hasInstallScript == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/install.sh" ]] ||
       [[ $F_hasRemovalScript == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/remove.sh"  ]] ||
       [[ $F_hasExportScript  == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/export.sh"  ]]; then
      rm -R ".blueprint/tmp/$n"
      throw 'scriptsMissingFiles'
    fi
  fi

  # Place database migrations.
  if [[ $database_migrations != "" ]]; then
    log_bright "[INFO] Placing database migrations.."
    cp -R ".blueprint/tmp/$n/$database_migrations/"* "database/migrations/" 2>> $BLUEPRINT__DEBUG
  fi

  # Create, link and connect components directory.
  if [[ $dashboard_components != "" ]]; then
    YARN="y"
    log_bright "[INFO] Creating components directory.."
    mkdir -p ".blueprint/extensions/$identifier/components"
    
    cd $FOLDER/resources/scripts/blueprint/extensions || throw 'cdMissingDirectory'
    ln -s -T $FOLDER/.blueprint/extensions/"$identifier"/components "$identifier" 2>> $BLUEPRINT__DEBUG
    cd $FOLDER || throw 'cdMissingDirectory'

    log_bright "[INFO] Placing components directory contents.."
    cp -R ".blueprint/tmp/$n/$dashboard_components/"* ".blueprint/extensions/$identifier/components/" 2>> $BLUEPRINT__DEBUG
    if [[ -f ".blueprint/tmp/$n/$dashboard_components/Components.yml" ]]; then

      # fetch component config
      eval "$(parse_yaml .blueprint/tmp/"$n"/"$dashboard_components"/Components.yml Components_)"
      if [[ $DUPLICATE == "y" ]]; then eval "$(parse_yaml .blueprint/extensions/"${identifier}"/private/.store/Components.yml OldComponents_)"; fi

      # define static variables to make stuff a bit easier
      im="\/\* blueprint\/import \*\/"; re="{/\* blueprint\/react \*/}"; co="resources/scripts/blueprint/components"
      s="import ${identifier^}Component from '"; e="';"

      PLACE_REACT() {
        if [[ ( $1 == "/"* ) || ( $1 == *"/.."* ) || ( $1 == *"../"* ) || ( $1 == *"/../"* ) || ( $1 == *"\n"* ) || ( $1 == *"@"* ) || ( $1 == *"\\"* ) ]]; then rm -R ".blueprint/tmp/$n"; throw 'componentEscape'; fi
        if [[ $3 != "$1" ]]; then
          # remove old components
          sed -i "s~""${s}@/blueprint/extensions/${identifier}/$3${e}""~~g" "$co"/"$2"
          sed -i "s~""<${identifier^}Component />""~~g" "$co"/"$2"
        fi
        if [[ ! $1 == "" ]]; then

          # validate file name
          if [[ ${1} == *".tsx" ]] ||
             [[ ${1} == *".ts"  ]] ||
             [[ ${1} == *".jsx" ]] ||
             [[ ${1} == *".js"  ]]; then 
            rm -R ".blueprint/tmp/$n"
            throw 'componentFileExtension'
          fi

          # validate path
          if [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.tsx" ]] &&
             [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.ts"  ]] &&
             [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.jsx" ]] &&
             [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.js"  ]]; then 
            rm -R ".blueprint/tmp/$n"
            throw 'missingComponentFiles'
          fi

          # remove components
          sed -i "s~""${s}@/blueprint/extensions/${identifier}/$1${e}""~~g" "$co"/"$2"
          sed -i "s~""<${identifier^}Component />""~~g" "$co"/"$2"
          # add components
          sed -i "s~""$im""~""${im}${s}@/blueprint/extensions/${identifier}/$1${e}""~g" "$co"/"$2"
          sed -i "s~""$re""~""${re}\<${identifier^}Component /\>""~g" "$co"/"$2"
        fi
      }

      # place component items
      # -> PLACE_REACT "$Components_" "path/.tsx" "$OldComponents_"


      # navigation
      PLACE_REACT "$Components_Navigation_NavigationBar_BeforeNavigation" "Navigation/NavigationBar/BeforeNavigation.tsx" "$OldComponents_Navigation_NavigationBar_BeforeNavigation"
      PLACE_REACT "$Components_Navigation_NavigationBar_AdditionalItems" "Navigation/NavigationBar/AdditionalItems.tsx" "$OldComponents_Navigation_NavigationBar_AdditionalItems"
      PLACE_REACT "$Components_Navigation_NavigationBar_AfterNavigation" "Navigation/NavigationBar/AfterNavigation.tsx" "$OldComponents_Navigation_NavigationBar_AfterNavigation"
      PLACE_REACT "$Components_Navigation_SubNavigation_BeforeSubNavigation" "Navigation/SubNavigation/BeforeSubNavigation.tsx" "$OldComponents_Navigation_SubNavigation_BeforeSubNavigation"
      PLACE_REACT "$Components_Navigation_SubNavigation_AdditionalServerItems" "Navigation/SubNavigation/AdditionalServerItems.tsx" "$OldComponents_Navigation_SubNavigation_AdditionalServerItems"
      PLACE_REACT "$Components_Navigation_SubNavigation_AdditionalAccountItems" "Navigation/SubNavigation/AdditionalAccountItems.tsx" "$OldComponents_Navigation_SubNavigation_AdditionalAccountItems"
      PLACE_REACT "$Components_Navigation_SubNavigation_AfterSubNavigation" "Navigation/SubNavigation/AfterSubNavigation.tsx" "$OldComponents_Navigation_SubNavigation_AfterSubNavigation"

      # dashboard
      PLACE_REACT "$Components_Dashboard_ServerRow_BeforeEntryName" "Dashboard/ServerRow/BeforeEntryName.tsx" "$OldComponents_Dashboard_ServerRow_BeforeEntryName"
      PLACE_REACT "$Components_Dashboard_ServerRow_AfterEntryName" "Dashboard/ServerRow/AfterEntryName.tsx" "$OldComponents_Dashboard_ServerRow_AfterEntryName"
      PLACE_REACT "$Components_Dashboard_ServerRow_BeforeEntryDescription" "Dashboard/ServerRow/BeforeEntryDescription.tsx" "$OldComponents_Dashboard_ServerRow_BeforeEntryDescription"
      PLACE_REACT "$Components_Dashboard_ServerRow_AfterEntryDescription" "Dashboard/ServerRow/AfterEntryDescription.tsx" "$OldComponents_Dashboard_ServerRow_AfterEntryDescription"
      PLACE_REACT "$Components_Dashboard_ServerRow_ResourceLimits" "Dashboard/ServerRow/ResourceLimits.tsx" "$OldComponents_Dashboard_ServerRow_ResourceLimits"


      # server
      PLACE_REACT "$Components_Server_Terminal_BeforeContent" "Server/Terminal/BeforeContent.tsx" "$OldComponents_Server_Terminal_BeforeContent"
      PLACE_REACT "$Components_Server_Terminal_AfterContent" "Server/Terminal/AfterContent.tsx" "$OldComponents_Server_Terminal_AfterContent"

      PLACE_REACT "$Components_Server_Files_Browse_BeforeContent" "Server/Files/Browse/BeforeContent.tsx" "$OldComponents_Server_Files_Browse_BeforeContent"
      PLACE_REACT "$Components_Server_Files_Browse_FileButtons" "Server/Files/Browse/FileButtons.tsx" "$OldComponents_Server_Files_Browse_FileButtons"
      PLACE_REACT "$Components_Server_Files_Browse_DropdownItems" "Server/Files/Browse/DropdownItems.tsx" "$OldComponents_Server_Files_Browse_DropdownItems"
      PLACE_REACT "$Components_Server_Files_Browse_AfterContent" "Server/Files/Browse/AfterContent.tsx" "$OldComponents_Server_Files_Browse_AfterContent"
      PLACE_REACT "$Components_Server_Files_Edit_BeforeEdit" "Server/Files/Edit/BeforeEdit.tsx" "$OldComponents_Server_Files_Edit_BeforeEdit"
      PLACE_REACT "$Components_Server_Files_Edit_AfterEdit" "Server/Files/Edit/AfterEdit.tsx" "$OldComponents_Server_Files_Edit_AfterEdit"
      
      PLACE_REACT "$Components_Server_Databases_BeforeContent" "Server/Databases/BeforeContent.tsx" "$OldComponents_Server_Databases_BeforeContent"
      PLACE_REACT "$Components_Server_Databases_AfterContent" "Server/Databases/AfterContent.tsx" "$OldComponents_Server_Databases_AfterContent"

      PLACE_REACT "$Components_Server_Schedules_List_BeforeContent" "Server/Schedules/List/BeforeContent.tsx" "$OldComponents_Server_Schedules_List_BeforeContent"
      PLACE_REACT "$Components_Server_Schedules_List_AfterContent" "Server/Schedules/List/AfterContent.tsx" "$OldComponents_Server_Schedules_List_AfterContent"
      PLACE_REACT "$Components_Server_Schedules_Edit_BeforeEdit" "Server/Schedules/Edit/BeforeEdit.tsx" "$OldComponents_Server_Schedules_Edit_BeforeEdit"
      PLACE_REACT "$Components_Server_Schedules_Edit_AfterEdit" "Server/Schedules/Edit/AfterEdit.tsx" "$OldComponents_Server_Schedules_Edit_AfterEdit"

      PLACE_REACT "$Components_Server_Users_BeforeContent" "Server/Users/BeforeContent.tsx" "$OldComponents_Server_Users_BeforeContent"
      PLACE_REACT "$Components_Server_Users_AfterContent" "Server/Users/AfterContent.tsx" "$OldComponents_Server_Users_AfterContent"

      PLACE_REACT "$Components_Server_Backups_BeforeContent" "Server/Backups/BeforeContent.tsx" "$OldComponents_Server_Backups_BeforeContent"
      PLACE_REACT "$Components_Server_Backups_DropdownItems" "Server/Backups/DropdownItems.tsx" "$OldComponents_Server_Backups_DropdownItems"
      PLACE_REACT "$Components_Server_Backups_AfterContent" "Server/Backups/AfterContent.tsx" "$OldComponents_Server_Backups_AfterContent"

      PLACE_REACT "$Components_Server_Network_BeforeContent" "Server/Network/BeforeContent.tsx" "$OldComponents_Server_Network_BeforeContent"
      PLACE_REACT "$Components_Server_Network_AfterContent" "Server/Network/AfterContent.tsx" "$OldComponents_Server_Network_AfterContent"

      PLACE_REACT "$Components_Server_Startup_BeforeContent" "Server/Startup/BeforeContent.tsx" "$OldComponents_Server_Startup_BeforeContent"
      PLACE_REACT "$Components_Server_Startup_AfterContent" "Server/Startup/AfterContent.tsx" "$OldComponents_Server_Startup_AfterContent"

      PLACE_REACT "$Components_Server_Settings_BeforeContent" "Server/Settings/BeforeContent.tsx" "$OldComponents_Server_Settings_BeforeContent"
      PLACE_REACT "$Components_Server_Settings_AfterContent" "Server/Settings/AfterContent.tsx" "$OldComponents_Server_Settings_AfterContent"


      # account
      PLACE_REACT "$Components_Account_Overview_BeforeContent" "Account/Overview/BeforeContent.tsx" "$OldComponents_Account_Overview_BeforeContent"
      PLACE_REACT "$Components_Account_Overview_AfterContent" "Account/Overview/AfterContent.tsx" "$OldComponents_Account_Overview_AfterContent"

      PLACE_REACT "$Components_Account_API_BeforeContent" "Account/API/BeforeContent.tsx" "$OldComponents_Account_API_BeforeContent"
      PLACE_REACT "$Components_Account_API_AfterContent" "Account/API/AfterContent.tsx" "$OldComponents_Account_API_AfterContent"

      PLACE_REACT "$Components_Account_SSH_BeforeContent" "Account/SSH/BeforeContent.tsx" "$OldComponents_Account_SSH_BeforeContent"
      PLACE_REACT "$Components_Account_SSH_AfterContent" "Account/SSH/AfterContent.tsx" "$OldComponents_Account_SSH_AfterContent"

    else
      # warn about missing components.yml file
      log_yellow "[WARNING] Could not find '$dashboard_components/Components.yml', component extendability might be limited."
    fi
  fi

  # Create and link public directory.
  if [[ $data_public != "" ]]; then
    log_bright "[INFO] Creating public directory.."
    mkdir -p ".blueprint/extensions/$identifier/public"
    
    cd $FOLDER/public/extensions || throw 'cdMissingDirectory'
    ln -s -T $FOLDER/.blueprint/extensions/"$identifier"/public "$identifier" 2>> $BLUEPRINT__DEBUG
    cd $FOLDER || throw 'cdMissingDirectory'

    log_bright "[INFO] Placing public directory contents.."
    cp -R ".blueprint/tmp/$n/$data_public/"* ".blueprint/extensions/$identifier/public/" 2>> $BLUEPRINT__DEBUG
  fi

  # Prepare build files.
  cp ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak" 2>> $BLUEPRINT__DEBUG
  if [[ $controller_type == "default" ]]; then # use default controller when admin_controller is left blank
    cp ".blueprint/extensions/blueprint/private/build/extensions/controller.php" ".blueprint/extensions/blueprint/private/build/extensions/controller.php.bak" 2>> $BLUEPRINT__DEBUG
  fi
  cp ".blueprint/extensions/blueprint/private/build/extensions/route.php" ".blueprint/extensions/blueprint/private/build/extensions/route.php.bak" 2>> $BLUEPRINT__DEBUG
  cp ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php" ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak" 2>> $BLUEPRINT__DEBUG


  # Start creating data directory.
  log_bright "[INFO] Creating data directory.."
  mkdir -p ".blueprint/extensions/$identifier/private"
  mkdir -p ".blueprint/extensions/$identifier/private/.store"
  
  log_bright "[INFO] Caching extension config inside of data directory.."
  cp ".blueprint/tmp/$n/conf.yml" ".blueprint/extensions/$identifier/private/.store/conf.yml" #backup conf.yml
  if [[ -f ".blueprint/tmp/$n/$dashboard_components/Components.yml" ]]; then
    cp ".blueprint/tmp/$n/$dashboard_components/Components.yml" ".blueprint/extensions/$identifier/private/.store/Components.yml" #backup Components.yml
  fi
  
  if [[ $data_directory != "" ]]; then
    log_bright "[INFO] Placing private directory contents.."
    cp -R ".blueprint/tmp/$n/$data_directory/"* ".blueprint/extensions/$identifier/private/"
  fi
  # End creating data directory.


  # Link and create assets folder.
  if [[ $DUPLICATE != "y" ]]; then
    # Create assets folder if the extension is not updating.
    mkdir .blueprint/extensions/"$identifier"/assets
  fi
  cd $FOLDER/public/assets/extensions || throw 'cdMissingDirectory'
  ln -s -T $FOLDER/.blueprint/extensions/"$identifier"/assets "$identifier" 2>> $BLUEPRINT__DEBUG
  cd $FOLDER || throw 'cdMissingDirectory'
  
  if [[ $icon == "" ]]; then
    # use random placeholder icon if extension does not
    # come with an icon.
    icnNUM=$(( 1 + RANDOM % 9 ))
    cp ".blueprint/assets/defaultExtensionLogo$icnNUM.jpg" ".blueprint/extensions/$identifier/assets/icon.jpg"
  else
    cp ".blueprint/tmp/$n/$icon" ".blueprint/extensions/$identifier/assets/icon.jpg"
  fi;
  ICON="/assets/extensions/$identifier/icon.jpg"
  CONTENT=$(cat .blueprint/tmp/"$n"/"$admin_view")

  if [[ $admin_css != "" ]]; then
    log_bright "[INFO] Placing admin css.."
    updateCacheReminder
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" ".blueprint/extensions/blueprint/assets/admin.extensions.css"
    echo -e "@import url(/assets/extensions/$identifier/admin.style.css);" >> ".blueprint/extensions/blueprint/assets/admin.extensions.css"
    cp ".blueprint/tmp/$n/$admin_css" ".blueprint/extensions/$identifier/assets/admin.style.css"
  fi
  if [[ $dashboard_css != "" ]]; then
    log_bright "[INFO] Placing dashboard css.."
    YARN="y"
    sed -i "s~@import url(./imported/$identifier.css);~~g" "resources/scripts/blueprint/css/extensions.css"
    echo -e "@import url(./imported/$identifier.css);" >> "resources/scripts/blueprint/css/extensions.css"
    cp ".blueprint/tmp/$n/$dashboard_css" "resources/scripts/blueprint/css/imported/$identifier.css"
  fi

  if [[ $name == *"~"* ]]; then        log_yellow "[WARNING] 'name' contains '~' and may result in an error.";fi
  if [[ $description == *"~"* ]]; then log_yellow "[WARNING] 'description' contains '~' and may result in an error.";fi
  if [[ $version == *"~"* ]]; then     log_yellow "[WARNING] 'version' contains '~' and may result in an error.";fi
  if [[ $CONTENT == *"~"* ]]; then     log_yellow "[WARNING] 'CONTENT' contains '~' and may result in an error.";fi
  if [[ $ICON == *"~"* ]]; then        log_yellow "[WARNING] 'ICON' contains '~' and may result in an error.";fi
  if [[ $identifier == *"~"* ]]; then  log_yellow "[WARNING] 'identifier' contains '~' and may result in an error.";fi

  # Replace $name variables.
  sed -i "s~␀title␀~$name~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
  sed -i "s~␀name␀~$name~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
  sed -i "s~␀name␀~$name~g" ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak"

  # Replace $description variables.
  sed -i "s~␀description␀~$description~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"

  # Replace $version variables.
  sed -i "s~␀version␀~$version~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
  sed -i "s~␀version␀~$version~g" ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak"

  # Replace $ICON variables.
  sed -i "s~␀icon␀~$ICON~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"

  # Replace $website variables.
  if [[ $website != "" ]]; then
    sed -i "s~␀website␀~$website~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
    sed -i "s~<!--websitecomment␀ ~~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
    sed -i "s~ ␀websitecomment-->~~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
    sed -i "s~␀weblinkicon␀~$websiteiconclass~g" ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
  fi

  # Replace $identifier variables.
  if [[ $controller_type == "default" ]]; then
    sed -i "s~␀id␀~$identifier~g" ".blueprint/extensions/blueprint/private/build/extensions/controller.php.bak"
  fi
  sed -i "s~␀id␀~$identifier~g" ".blueprint/extensions/blueprint/private/build/extensions/route.php.bak"
  sed -i "s~␀id␀~$identifier~g" ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak"

  # Place extension admin view content into template.
  echo -e "$CONTENT\n@endsection" >> ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"


  # Read final results.
  ADMINVIEW_RESULT=$(<.blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak)
  ADMINROUTE_RESULT=$(<.blueprint/extensions/blueprint/private/build/extensions/route.php.bak)
  ADMINBUTTON_RESULT=$(<.blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak)
  if [[ $controller_type == "default" ]]; then
    ADMINCONTROLLER_RESULT=$(<.blueprint/extensions/blueprint/private/build/extensions/controller.php.bak)
  fi
  ADMINCONTROLLER_NAME="${identifier}ExtensionController.php"

  # Place admin extension view.
  mkdir -p "resources/views/admin/extensions/$identifier"
  touch "resources/views/admin/extensions/$identifier/index.blade.php"
  echo "$ADMINVIEW_RESULT" > "resources/views/admin/extensions/$identifier/index.blade.php"

  # Place admin extension view controller.
  mkdir -p "app/Http/Controllers/Admin/Extensions/$identifier"
  touch "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  if [[ $controller_type == "default" ]]; then
    # Use custom view controller.
    touch "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
    echo "$ADMINCONTROLLER_RESULT" > "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  else
    # Use default extension controller.
    cp .blueprint/tmp/"$n"/"$admin_controller" "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  fi

  if [[ $DUPLICATE != "y" ]]; then
    # Place admin route if extension is not updating.
    { echo "
    // $identifier:start";
    echo "$ADMINROUTE_RESULT";
    echo // "$identifier":stop; } >> "routes/admin.php"
  else
    # Replace old extensions page button if extension is updating.
    OLDBUTTON_RESULT=$(<.blueprint/extensions/"$identifier"/private/.store/build/button.blade.php)
    sed -i "s~$OLDBUTTON_RESULT~~g" "resources/views/admin/extensions.blade.php"
  fi
  sed -i "s~<!--␀replace␀-->~$ADMINBUTTON_RESULT\n<!--␀replace␀-->~g" "resources/views/admin/extensions.blade.php"

  # Place dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then
    log_bright "[INFO] Placing dashboard wrapper.."
    if [[ $DUPLICATE == "y" ]]; then
      sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" "resources/views/templates/wrapper.blade.php"
      sed -i "s~<!--␀$identifier:start␀-->~~g" "resources/views/templates/wrapper.blade.php"
      sed -i "s~<!--␀$identifier:stop␀-->~~g" "resources/views/templates/wrapper.blade.php"
    fi
    touch ".blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK"
    cat <(echo "<!--␀$identifier:start␀-->") ".blueprint/tmp/$n/$dashboard_wrapper" > ".blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK"
    cp ".blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK" ".blueprint/tmp/$n/$dashboard_wrapper"
    rm ".blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK"
    echo -e "\n<!--␀$identifier:stop␀-->" >> ".blueprint/tmp/$n/$dashboard_wrapper"
    sed -i "/<\!-- wrapper:insert -->/r .blueprint/tmp/$n/$dashboard_wrapper" "resources/views/templates/wrapper.blade.php"
  fi

  # Place admin wrapper
  if [[ $admin_wrapper != "" ]]; then
    log_bright "[INFO] Placing admin wrapper.."
    if [[ $DUPLICATE == "y" ]]; then
      sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" "resources/views/layouts/admin.blade.php"
      sed -i "s~<!--␀$identifier:start␀-->~~g" "resources/views/layouts/admin.blade.php"
      sed -i "s~<!--␀$identifier:stop␀-->~~g" "resources/views/layouts/admin.blade.php"
    fi
    touch ".blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK"
    cat <(echo "<!--␀$identifier:start␀-->") ".blueprint/tmp/$n/$admin_wrapper" > ".blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK"
    cp ".blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK" ".blueprint/tmp/$n/$admin_wrapper"
    rm ".blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK"
    echo -e "\n<!--␀$identifier:stop␀-->" >> ".blueprint/tmp/$n/$admin_wrapper"
    sed -i "/<\!-- wrapper:insert -->/r .blueprint/tmp/$n/$admin_wrapper" "resources/views/layouts/admin.blade.php"
  fi

  # Create backup of generated values.
  log_bright "[INFO] Backing up (some) build files.."
  mkdir -p ".blueprint/extensions/$identifier/private/.store/build"
  cp ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak" ".blueprint/extensions/$identifier/private/.store/build/button.blade.php"
  cp ".blueprint/extensions/blueprint/private/build/extensions/route.php.bak" ".blueprint/extensions/$identifier/private/.store/build/route.php"

  # Remove temporary built files.
  log_bright "[INFO] Cleaning up temporary built files.."
  rm ".blueprint/extensions/blueprint/private/build/extensions/admin.blade.php.bak"
  if [[ $controller_type == "default" ]]; then
    rm ".blueprint/extensions/blueprint/private/build/extensions/controller.php.bak"
  fi
  rm ".blueprint/extensions/blueprint/private/build/extensions/route.php.bak"
  rm ".blueprint/extensions/blueprint/private/build/extensions/button.blade.php.bak"
  log_bright "[INFO] Cleaning up temp files.."
  rm -R ".blueprint/tmp/$n"

  if [[ $database_migrations != "" ]]; then
    log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
    read -r YN
    if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]]; then 
      log_bright "[INFO] Running database migrations.."
      php artisan migrate --force
    else
      log_bright "[INFO] Database migrations have been skipped."
    fi
  fi

  if [[ $YARN == "y" ]]; then 
    if [[ ( $F_developerIgnoreRebuild == true ) && ( $dev == true ) ]]; then
      log_yellow "[WARNING] Rebuilding skipped due to 'developerIgnoreRebuild' flag being present."
    else
      log_bright "[INFO] Rebuilding panel.."
      yarn run build:production
    fi
  fi

  log_bright "[INFO] Updating route cache to include recent changes.."
  php artisan route:cache &>> $BLUEPRINT__DEBUG

  chown -R www-data:www-data "$FOLDER/.blueprint/extensions/$identifier/private"
  chmod --silent -R +x ".blueprint/extensions/"* 2>> $BLUEPRINT__DEBUG

  if [[ ( $F_developerIgnoreInstallScript == false ) || ( $dev != true ) ]]; then
    if $F_hasInstallScript; then
      log_yellow "[WARNING] This extension uses a custom installation script, proceed with caution."
      chmod +x ".blueprint/extensions/$identifier/private/install.sh"

      # Run script while also parsing some useful variables for the install script to use.
      EXTENSION_IDENTIFIER="$identifier" \
      EXTENSION_TARGET="$target"         \
      EXTENSION_VERSION="$version"       \
      PTERODACTYL_DIRECTORY="$FOLDER"    \
      BLUEPRINT_VERSION="$VERSION"       \
      BLUEPRINT_DEVELOPER="$dev"         \
      bash ".blueprint/extensions/$identifier/private/install.sh"

      echo -e "\e[0m\x1b[0m\033[0m"
    fi
  else
    log_bright "[INFO] Custom installation scripts will be skipped on developer commands due to the 'developerIgnoreInstallScript' flag."
  fi

  if [[ $DUPLICATE != "y" ]]; then
    echo "${identifier}," >> ".blueprint/extensions/blueprint/private/db/installed_extensions"
    log_bright "[INFO] Added '$identifier' to the list of installed extensions."
  fi

  if [[ $dev != true ]]; then
    if [[ $DUPLICATE == "y" ]]; then
      log_green "\n\n[SUCCESS] $identifier should now be updated."
    else
      log_green "\n\n[SUCCESS] $identifier should now be installed."
    fi
    sendTelemetry "FINISH_EXTENSION_INSTALLATION" >> $BLUEPRINT__DEBUG
  elif [[ $dev == true ]]; then
    log_green "\n\n[SUCCESS] $identifier should now be built."
    sendTelemetry "BUILD_DEVELOPMENT_EXTENSION" >> $BLUEPRINT__DEBUG
  fi
fi

# -r, -remove
if [[ ( $2 == "-r" ) || ( $2 == "-remove" ) ]]; then VCMD="y"
  if [[ $(( $# - 2 )) != 1 ]]; then quit_red "[FATAL] Expected 1 argument but got $(( $# - 2 )).";fi
  
  # Check if the extension is installed.
  if [[ $(cat ".blueprint/extensions/blueprint/private/db/installed_extensions") != *"$identifier,"* ]]; then
    quit_red "[FATAL] '$3' is not installed."
  fi

  if [[ -f ".blueprint/extensions/$3/private/.store/conf.yml" ]]; then 
    eval "$(parse_yaml ".blueprint/extensions/$3/private/.store/conf.yml" conf_)"
    # Add aliases for config values to make working with them easier.
    name="$conf_info_name";    
    identifier="$conf_info_identifier"
    description="$conf_info_description"
    flags="$conf_info_flags" #(optional)
    version="$conf_info_version"
    target="$conf_info_target"
    author="$conf_info_author" #(optional)
    icon="$conf_info_icon" #(optional)
    website="$conf_info_website"; #(optional)

    admin_view="$conf_admin_view"
    admin_controller="$conf_admin_controller"; #(optional)
    admin_css="$conf_admin_css"; #(optional)
    admin_wrapper="$conf_admin_wrapper"; #(optional)

    dashboard_css="$conf_dashboard_css"; #(optional)
    dashboard_wrapper="$conf_dashboard_wrapper"; #(optional)
    dashboard_components="$conf_dashboard_components"; #(optional)

    data_directory="$conf_data_directory"; #(optional)
    data_public="$conf_data_public"; #(optional)

    database_migrations="$conf_database_migrations"; #(optional)
  else 
    quit_red "[FATAL] Backup conf.yml could not be found."
  fi

  log_blue "[INPUT] Are you sure you want to continue? Some extension files might not be removed as Blueprint does not keep track of them. (y/N)"
  read -r YN
  if [[ ( $YN == "n"* ) || ( $YN == "N"* ) || ( $YN == "" ) ]]; then log_bright "[INFO] Extension removal cancelled.";exit 1;fi

  log_bright "[INFO] Checking dependencies.."
  depend

  # Assign variables to extension flags.
  log_bright "[INFO] Assigning variables to extension flags.."
  assignflags

  if $F_hasRemovalScript; then
    log_yellow "[WARNING] This extension uses a custom removal script, proceed with caution."
    chmod +x ".blueprint/extensions/$identifier/private/remove.sh"

    # Run script while also parsing some useful variables for the uninstall script to use.
    EXTENSION_IDENTIFIER="$identifier" \
    EXTENSION_TARGET="$target"         \
    EXTENSION_VERSION="$version"       \
    PTERODACTYL_DIRECTORY="$FOLDER"    \
    BLUEPRINT_VERSION="$VERSION"       \
    bash ".blueprint/extensions/$identifier/private/remove.sh"
    
    echo -e "\e[0m\x1b[0m\033[0m"
  fi

  # Remove admin button 
  log_bright "[INFO] Removing admin button.."
  OLDBUTTON_RESULT=$(cat ".blueprint/extensions/$identifier/private/.store/build/button.blade.php")
  sed -i "s~$OLDBUTTON_RESULT~~g" "resources/views/admin/extensions.blade.php"

  # Remove admin routes
  log_bright "[INFO] Removing admin routes.."
  sed -n -i "/\/\/ $identifier:start/{p; :a; N; /\/\/ $identifier:stop/!ba; s/.*\n//}; p" "routes/admin.php"
  sed -i "s~// $identifier:start~~g" "routes/admin.php"
  sed -i "s~// $identifier:stop~~g" "routes/admin.php"
  
  # Remove admin view
  log_bright "[INFO] Removing admin view.."
  rm -R "resources/views/admin/extensions/$identifier"

  # Remove admin controller
  log_bright "[INFO] Removing admin controller.."
  rm -R "app/Http/Controllers/Admin/Extensions/$identifier"

  # Remove admin css
  if [[ $admin_css != "" ]]; then
    log_bright "[INFO] Removing admin css.."
    updateCacheReminder
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" ".blueprint/extensions/blueprint/assets/admin.extensions.css"
  fi

  # Remove admin wrapper
  if [[ $admin_wrapper != "" ]]; then 
    log_bright "[INFO] Removing admin wrapper.."
    sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" "resources/views/layouts/admin.blade.php"
    sed -i "s~<!--␀$identifier:start␀-->~~g" "resources/views/layouts/admin.blade.php"
    sed -i "s~<!--␀$identifier:stop␀-->~~g" "resources/views/layouts/admin.blade.php"
  fi

  # Remove dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then 
    log_bright "[INFO] Removing dashboard wrapper.."
    sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" "resources/views/templates/wrapper.blade.php"
    sed -i "s~<!--␀$identifier:start␀-->~~g" "resources/views/templates/wrapper.blade.php"
    sed -i "s~<!--␀$identifier:stop␀-->~~g" "resources/views/templates/wrapper.blade.php"
  fi

  # Remove dashboard css
  if [[ $dashboard_css != "" ]]; then
    log_bright "[INFO] Removing dashboard css.."
    sed -i "s~@import url(./imported/$identifier.css);~~g" "resources/scripts/blueprint/css/extensions.css"
    rm "resources/scripts/blueprint/css/imported/$identifier.css"
    YARN="y"
  fi

  # Remove dashboard components
  if [[ $dashboard_components != "" ]]; then
    log_bright "[INFO] Removing dashboard components.."
    rm $FOLDER/resources/scripts/blueprint/extensions/"$identifier"
    # fetch component config
    eval "$(parse_yaml .blueprint/extensions/"$identifier"/components/Components.yml Components_)"

    # define static variables to make stuff a bit easier
    im="\/\* blueprint\/import \*\/"; re="{/\* blueprint\/react \*/}"; co="resources/scripts/blueprint/components"
    s="import ${identifier^}Component from '"; e="';"

    REMOVE_REACT() {
      if [[ ! $1 == "" ]]; then
        # remove components
        sed -i "s~""${s}@/blueprint/extensions/${identifier}/$1${e}""~~g" "$co"/"$2"
        sed -i "s~""<${identifier^}Component />""~~g" "$co"/"$2"
      fi
    }

    # remove component items
    # -> REMOVE_REACT "$Components_" "path/.tsx" "$OldComponents_"


    # navigation
    REMOVE_REACT "$Components_Navigation_NavigationBar_BeforeNavigation" "Navigation/NavigationBar/BeforeNavigation.tsx"
    REMOVE_REACT "$Components_Navigation_NavigationBar_AdditionalItems" "Navigation/NavigationBar/AdditionalItems.tsx"
    REMOVE_REACT "$Components_Navigation_NavigationBar_AfterNavigation" "Navigation/NavigationBar/AfterNavigation.tsx"
    REMOVE_REACT "$Components_Navigation_SubNavigation_BeforeSubNavigation" "Navigation/SubNavigation/BeforeSubNavigation.tsx"
    REMOVE_REACT "$Components_Navigation_SubNavigation_AdditionalServerItems" "Navigation/SubNavigation/AdditionalServerItems.tsx"
    REMOVE_REACT "$Components_Navigation_SubNavigation_AdditionalAccountItems" "Navigation/SubNavigation/AdditionalAccountItems.tsx"
    REMOVE_REACT "$Components_Navigation_SubNavigation_AfterSubNavigation" "Navigation/SubNavigation/AfterSubNavigation.tsx"


    # dashboard
    REMOVE_REACT "$Components_Dashboard_ServerRow_BeforeEntryName" "Dashboard/ServerRow/BeforeEntryName.tsx"
    REMOVE_REACT "$Components_Dashboard_ServerRow_AfterEntryName" "Dashboard/ServerRow/AfterEntryName.tsx"
    REMOVE_REACT "$Components_Dashboard_ServerRow_BeforeEntryDescription" "Dashboard/ServerRow/BeforeEntryDescription.tsx"
    REMOVE_REACT "$Components_Dashboard_ServerRow_AfterEntryDescription" "Dashboard/ServerRow/AfterEntryDescription.tsx"
    REMOVE_REACT "$Components_Dashboard_ServerRow_ResourceLimits" "Dashboard/ServerRow/ResourceLimits.tsx"


    # server
    REMOVE_REACT "$Components_Server_Terminal_BeforeContent" "Server/Terminal/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Terminal_AfterContent" "Server/Terminal/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Files_Browse_BeforeContent" "Server/Files/Browse/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Files_Browse_FileButtons" "Server/Files/Browse/FileButtons.tsx"
    REMOVE_REACT "$Components_Server_Files_Browse_DropdownItems" "Server/Files/Browse/DropdownItems.tsx"
    REMOVE_REACT "$Components_Server_Files_Browse_AfterContent" "Server/Files/Browse/AfterContent.tsx"
    REMOVE_REACT "$Components_Server_Files_Edit_BeforeEdit" "Server/Files/Edit/BeforeEdit.tsx"
    REMOVE_REACT "$Components_Server_Files_Edit_AfterEdit" "Server/Files/Edit/AfterEdit.tsx"
    
    REMOVE_REACT "$Components_Server_Databases_BeforeContent" "Server/Databases/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Databases_AfterContent" "Server/Databases/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Schedules_List_BeforeContent" "Server/Schedules/List/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Schedules_List_AfterContent" "Server/Schedules/List/AfterContent.tsx"
    REMOVE_REACT "$Components_Server_Schedules_Edit_BeforeEdit" "Server/Schedules/Edit/BeforeEdit.tsx"
    REMOVE_REACT "$Components_Server_Schedules_Edit_AfterEdit" "Server/Schedules/Edit/AfterEdit.tsx"

    REMOVE_REACT "$Components_Server_Users_BeforeContent" "Server/Users/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Users_AfterContent" "Server/Users/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Backups_BeforeContent" "Server/Backups/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Backups_DropdownItems" "Server/Backups/DropdownItems.tsx"
    REMOVE_REACT "$Components_Server_Backups_AfterContent" "Server/Backups/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Network_BeforeContent" "Server/Network/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Network_AfterContent" "Server/Network/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Startup_BeforeContent" "Server/Startup/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Startup_AfterContent" "Server/Startup/AfterContent.tsx"

    REMOVE_REACT "$Components_Server_Settings_BeforeContent" "Server/Settings/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Settings_AfterContent" "Server/Settings/AfterContent.tsx"


    # account
    REMOVE_REACT "$Components_Account_Overview_BeforeContent" "Account/Overview/BeforeContent.tsx"
    REMOVE_REACT "$Components_Account_Overview_AfterContent" "Account/Overview/AfterContent.tsx"

    REMOVE_REACT "$Components_Account_API_BeforeContent" "Account/API/BeforeContent.tsx"
    REMOVE_REACT "$Components_Account_API_AfterContent" "Account/API/AfterContent.tsx"

    REMOVE_REACT "$Components_Account_SSH_BeforeContent" "Account/SSH/BeforeContent.tsx"
    REMOVE_REACT "$Components_Account_SSH_AfterContent" "Account/SSH/AfterContent.tsx"

    YARN="y"
  fi

  # Remove public folder
  if [[ $data_public != "" ]]; then 
    log_bright "[INFO] Removing public folder.."
    rm -R ".blueprint/extensions/$identifier/public"
    rm -R "public/extensions/$identifier"
  fi

  # Remove assets folder
  log_bright "[INFO] Removing assets.."
  rm -R ".blueprint/extensions/$identifier/assets"
  rm -R "public/assets/extensions/$identifier"

  # Remove data folder
  log_bright "[INFO] Removing data folder.."
  rm -R ".blueprint/extensions/$identifier/private"

  # Rebuild panel
  if [[ $YARN == "y" ]]; then
    log_bright "[INFO] Rebuilding panel assets.."
    yarn run build:production
  fi

  log_bright "[INFO] Updating route cache to include recent changes.."
  php artisan route:cache &>> $BLUEPRINT__DEBUG
  
  # Remove from installed list
  log_bright "[INFO] Removing extension from installed extensions list.."
  sed -i "s~$identifier,~~g" ".blueprint/extensions/blueprint/private/db/installed_extensions"

  log_green "[SUCCESS] '$identifier' has been removed from your panel. Please note that some files might be left behind."
  sendTelemetry "FINISH_EXTENSION_REMOVAL" >> $BLUEPRINT__DEBUG
fi


# help, -help, --help,
# h,    -h,    --h
if [[ ( $2 == "help" ) || ( $2 == "-help" ) || ( $2 == "--help" ) || 
      ( $2 == "h" )    || ( $2 == "-h" )    || ( $2 == "--h" )    || ( $2 == "" ) ]]; then VCMD="y"

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
  -install [name]      -i  install/update a blueprint extension
  -remove [name]       -r  remove a blueprint extension
  \x1b[0m
  
${help_dev_primary}Developer${help_dev_status}\x1b[0m${help_dev_secondary}
  -init                -I  initialize development files
  -build               -b  install/update your development files
  -export (expose)     -e  export/download your development files
  -wipe                -w  remove your development files
  \x1b[0m
  
\x1b[34;1mMisc\x1b[0m\x1b[34m
  -version             -v  returns the blueprint version
  -help                -h  displays this menu
  -info                -f  show neofetch-like information about blueprint
  -debug [lines]           print given amount of debug lines
  \x1b[0m
  
\x1b[34;1mAdvanced\x1b[0m\x1b[34m
  -upgrade (dev)           update/reset to a newer/development version
  -rerun-install           rerun the blueprint installation script
  \x1b[0m
  "
fi


# -v, -version
if [[ ( $2 == "-v" ) || ( $2 == "-version" ) ]]; then VCMD="y"
  echo -e ${VERSION}
fi

# -debug
if [[ $2 == "-debug" ]]; then VCMD="y"
  if [[ $3 -lt 1 ]]; then throw "debugLineCount"; fi
  echo -e "\x1b[30;47;1m  --- DEBUG START ---  \x1b[0m"
  echo -e "$(v="$(<.blueprint/extensions/blueprint/private/debug/logs.txt)";printf -- "%s" "$v"|tail -"$3")"
  echo -e "\x1b[30;47;1m  ---  DEBUG END  ---  \x1b[0m"
fi


# -init
if [[ ( $2 == "-init" || $2 == "-I" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then quit_red "[FATAL] Developer mode is not enabled."; fi

  # To prevent accidental wiping of your dev directory, you are unable to initialize another extension
  # until you wipe the contents of the .blueprint/dev directory.
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    quit_red "[FATAL] Your development directory contains files. To protect you against accidental data loss, you are unable to initialize another extension unless you clear your .blueprint/dev folder."
  fi

  ask_template() {
    log_blue "[INPUT] Initial Template:"
    log_blue "$(curl 'https://raw.githubusercontent.com/teamblueprint/templates/main/repository' 2>> $BLUEPRINT__DEBUG)"
    read -r ASKTEMPLATE

    REDO_TEMPLATE=false

    # Template should not be empty
    if [[ ${ASKTEMPLATE} == "" ]]; then 
      log_yellow "[WARNING] Template should not be empty."
      REDO_TEMPLATE=true
    fi

    # Unknown template.
    if [[ $(echo -e "$(curl "https://raw.githubusercontent.com/teamblueprint/templates/main/${ASKTEMPLATE}/TemplateConfiguration.yml" 2>> $BLUEPRINT__DEBUG)") == "404: Not Found" ]]; then 
      log_yellow "[WARNING] Unknown template, please choose a valid option."
      REDO_TEMPLATE=true
    fi

    if [[ ${REDO_TEMPLATE} == true ]]; then
      # Ask again if response does not pass validation.
      ASKTEMPLATE=""
      ask_template
    fi
  }

  ask_name() {
    log_blue "[INPUT] Name (Generic Extension):"
    read -r ASKNAME

    REDO_NAME=false

    # Name should not be empty
    if [[ ${ASKNAME} == "" ]]; then 
      log_yellow "[WARNING] Name should not be empty."
      REDO_NAME=true
    fi

    if [[ ${REDO_NAME} == true ]]; then
      # Ask again if response does not pass validation.
      ASKNAME=""
      ask_name
    fi
  }

  ask_identifier() {
    log_blue "[INPUT] Identifier (genericextension):"
    read -r ASKIDENTIFIER

    REDO_IDENTIFIER=false

    # Identifier should not be empty
    if [[ ${ASKIDENTIFIER} == "" ]]; then
      log_yellow "[WARNING] Identifier should not be empty."
      REDO_IDENTIFIER=true
    fi
  
    # Identifier should be a-z.
    if [[ ${ASKIDENTIFIER} =~ [a-z] ]]; then
      echo ok >> $BLUEPRINT__DEBUG
    else 
      log_yellow "[WARNING] Identifier should only contain a-z characters."
      REDO_IDENTIFIER=true
    fi

    if [[ ${REDO_IDENTIFIER} == true ]]; then
      # Ask again if response does not pass validation.
      ASKIDENTIFIER=""
      ask_identifier
    fi
  }

  ask_description() {
    log_blue "[INPUT] Description (My awesome description):"
    read -r ASKDESCRIPTION

    REDO_DESCRIPTION=false

    # Description should not be empty
    if [[ ${ASKDESCRIPTION} == "" ]]; then
      log_yellow "[WARNING] Description should not be empty."
      REDO_DESCRIPTION=true
    fi

    if [[ ${REDO_DESCRIPTION} == true ]]; then
      # Ask again if response does not pass validation.
      ASKDESCRIPTION=""
      ask_description
    fi
  }

  ask_version() {
    log_blue "[INPUT] Version (indev):"
    read -r ASKVERSION

    REDO_VERSION=false

    # Version should not be empty
    if [[ ${ASKVERSION} == "" ]]; then
      log_yellow "[WARNING] Version should not be empty."
      REDO_VERSION=true
    fi

    if [[ ${REDO_VERSION} == true ]]; then
      # Ask again if response does not pass validation.
      ASKVERSION=""
      ask_version
    fi
  }

  ask_author() {
    log_blue "[INPUT] Author (prplwtf):"
    read -r ASKAUTHOR

    REDO_AUTHOR=false

    # Author should not be empty
    if [[ ${ASKAUTHOR} == "" ]]; then
      log_yellow "[WARNING] Author should not be empty."
      REDO_AUTHOR=true
    fi

    if [[ ${REDO_AUTHOR} == true ]]; then
      # Ask again if response does not pass validation.
      ASKAUTHOR=""
      ask_author
    fi
  }

  ask_template
  ask_name
  ask_identifier
  ask_description
  ask_version
  ask_author

  tnum=${ASKTEMPLATE}
  log_bright "[INFO] Downloading templates from 'teamblueprint/templates'.."
  if [[ $(php artisan bp:latest) != "$VERSION" ]]; then log_yellow "[WARNING] Your Blueprint installation version is outdated, some templates might break or show random bugs."; fi
  cd .blueprint/tmp || throw 'cdMissingDirectory'
  git clone "https://github.com/teamblueprint/templates.git"
  cd ${FOLDER}/.blueprint || throw 'cdMissingDirectory'
  cp -R tmp/templates/* extensions/blueprint/private/build/templates/
  rm -R tmp/templates
  cd ${FOLDER} || throw 'cdMissingDirectory'

  eval "$(parse_yaml .blueprint/extensions/blueprint/private/build/templates/"${tnum}"/TemplateConfiguration.yml t_)"

  log_bright "[INFO] Copying template contents to the tmp directory.."
  mkdir -p .blueprint/tmp/init
  cp -R .blueprint/extensions/blueprint/private/build/templates/"${tnum}"/contents/* .blueprint/tmp/init/

  log_bright "[INFO] Applying variables.."
  sed -i "s~␀name␀~${ASKNAME}~g" .blueprint/tmp/init/conf.yml; #NAME
  sed -i "s~␀identifier␀~${ASKIDENTIFIER}~g" .blueprint/tmp/init/conf.yml; #IDENTIFIER
  sed -i "s~␀description␀~${ASKDESCRIPTION}~g" .blueprint/tmp/init/conf.yml; #DESCRIPTION
  sed -i "s~␀ver␀~${ASKVERSION}~g" .blueprint/tmp/init/conf.yml; #VERSION
  sed -i "s~␀author␀~${ASKAUTHOR}~g" .blueprint/tmp/init/conf.yml; #AUTHOR

  if [[ "${t_template_files_icon}" != "" ]]; then
    log_bright "[INFO] Rolling (and applying) extension placeholder icon.."
    icnNUM=$(( 1 + RANDOM % 9 ))
    cp .blueprint/assets/defaultExtensionLogo"${icnNUM}".jpg .blueprint/tmp/init/"${t_template_files_icon}"
    sed -i "s~␀icon␀~${t_template_files_icon}~g" .blueprint/tmp/init/conf.yml; #ICON
  fi

  log_bright "[INFO] Applying core variables.."
  sed -i "s~␀version␀~${VERSION}~g" .blueprint/tmp/init/conf.yml #BLUEPRINT-VERSION

  # Return files to folder.
  log_bright "[INFO] Copying output to extension development directory."
  cp -R .blueprint/tmp/init/* .blueprint/dev/

  # Remove tmp files.
  log_bright "[INFO] Purging contents of tmp folder."
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  # Wipe templates from disk.
  log_bright "[INFO] Wiping downloaded templates from disk.."
  rm -R .blueprint/extensions/blueprint/private/build/templates/*

  sendTelemetry "INITIALIZE_DEVELOPMENT_EXTENSION" >> $BLUEPRINT__DEBUG

  log_green "[SUCCESS] Your extension files have been generated and exported to '.blueprint/dev'."
fi


# -build
if [[ ( $2 == "-build" || $2 == "-b" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then quit_red "[FATAL] Developer mode is not enabled."; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    quit_red "[FATAL] You do not have any development files."
  fi
  log_bright "[INFO] Installing development extension files.."
  blueprint -i test␀
fi


# -export
if [[ ( $2 == "-export" || $2 == "-e" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then quit_red "[FATAL] Developer mode is not enabled."; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    quit_red "[FATAL] You do not have any development files."
  fi

  log_bright "[INFO] Exporting extension files located in '.blueprint/dev'."

  cd .blueprint || throw 'cdMissingDirectory'
  rm dev/.gitkeep 2>> $BLUEPRINT__DEBUG

  eval "$(parse_yaml dev/conf.yml conf_)"; identifier="${conf_info_identifier}"

  cp -R dev/* tmp/
  cd tmp || throw 'cdMissingDirectory'

  # Assign variables to extension flags.
  flags="$conf_info_flags"
  log_bright "[INFO] Assigning variables to extension flags.."
  assignflags

  if $F_hasExportScript; then
    chmod +x "${conf_data_directory}""/export.sh"

    # Run script while also parsing some useful variables for the export script to use.
    EXTENSION_IDENTIFIER="$conf_info_identifier"        \
    EXTENSION_TARGET="$conf_info_target"                \
    EXTENSION_VERSION="$conf_info_version"              \
    PTERODACTYL_DIRECTORY="$FOLDER"                     \
    BLUEPRINT_EXPORT_DIRECTORY="$FOLDER/.blueprint/tmp" \
    BLUEPRINT_VERSION="$VERSION"                        \
    bash "${conf_data_directory}""/export.sh"

    echo -e "\e[0m\x1b[0m\033[0m"
  fi

  zip -r extension.zip ./*
  cd ${FOLDER} || throw 'cdMissingDirectory'
  cp .blueprint/tmp/extension.zip "${identifier}.blueprint"
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  if [[ $3 == "expose"* ]]; then 
    log_bright "[INFO] Generating download url.."
    randstr=${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}
    mkdir .blueprint/extensions/blueprint/assets/exports/${randstr}
    cp "${identifier}".blueprint .blueprint/extensions/blueprint/assets/exports/${randstr}/"${identifier}".blueprint
    log_bright "[INFO] Download url will expire after 2 minutes."

    sendTelemetry "EXPOSE_DEVELOPMENT_EXTENSION" >> $BLUEPRINT__DEBUG
    log_green log_bold "\n[SUCCESS] Your extension has been exported successfully."
    log_green "  - $(grabAppUrl)/assets/extensions/blueprint/exports/${randstr}/${identifier}.blueprint"
    log_green "  - ${FOLDER}/${identifier}.blueprint"

    eval "$(sleep 120 && rm -R .blueprint/extensions/blueprint/assets/exports/${randstr} 2>> $BLUEPRINT__DEBUG)" &
  else
    sendTelemetry "EXPORT_DEVELOPMENT_EXTENSION" >> $BLUEPRINT__DEBUG
    log_green log_bold "\n[SUCCESS] Your extension has been exported successfully."
    log_green "  - ${FOLDER}/${identifier}.blueprint"
  fi
fi


# -wipe
if [[ ( $2 == "-wipe" || $2 == "-w" ) ]]; then VCMD="y"
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then quit_red "[FATAL] Developer mode is not enabled."; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    quit_red "[FATAL] You do not have any development files."
  fi

  log_blue "[INPUT] You are about to wipe all of your development files, are you sure you want to continue? This cannot be undone. (y/N)"
  read -r YN
  if [[ ( ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ) || ( ( ${YN} == "" ) ) ]]; then log_bright "[INFO] Development files removal cancelled.";exit 1;fi

  log_bright "[INFO] Wiping development folder.."
  rm -R .blueprint/dev/* 2>> $BLUEPRINT__DEBUG
  rm -R .blueprint/dev/.* 2>> $BLUEPRINT__DEBUG

  log_green "[SUCCESS] Your development files have been removed."
fi

# -info
if [[ ( $2 == "-info" || $2 == "-f" ) ]]; then VCMD="y"
  fetchversion() { if [[ $VERSION != "" ]]; then log_reset log_white $VERSION; else echo "none"; fi }
  fetchfolder() { if [[ $FOLDER != "" ]]; then log_reset log_white $FOLDER; else echo "none"; fi }
  fetchurl() { if [[ $(grabAppUrl) != "" ]]; then log_reset log_white "$(grabAppUrl)"; else echo "none"; fi }
  fetchlocale() { if [[ $(grabAppLocale) != "" ]]; then log_reset log_white "$(grabAppLocale)"; else echo "none"; fi }
  fetchtimezone() { if [[ $(grabAppTimezone) != "" ]]; then log_reset log_white "$(grabAppTimezone)"; else echo "none"; fi }
  fetchextensions() { log_reset log_white "$(echo "$(<.blueprint/extensions/blueprint/private/db/installed_extensions)" | tr -cd ',' | wc -c | tr -d ' ')"; }
  fetchdeveloper() { log_reset log_white "$(if dbValidate "blueprint.developerEnabled"; then echo "true"; else echo "false"; fi;)"; }
  fetchtelemetry() { log_reset log_white "$(telemetrykey=$(cat .blueprint/extensions/blueprint/private/db/telemetry_id); if [[ $telemetrykey == "KEY_NOT_UPDATED" ]]; then echo "false"; else echo "true"; fi;)"; }
  fetchnode() { if [[ $(node -v) != "" ]]; then log_reset log_white "$(node -v)"; else echo "none"; fi }
  fetchyarn() { if [[ $(yarn -v) != "" ]]; then log_reset log_white "$(yarn -v)"; else echo "none"; fi }

  log_bright          " "
  log_blue log_bold   "    ⣿⣿    $(log_reset log_bold log_blue "Version:") $(fetchversion)"
  log_blue log_bold   "  ⣿⣿  ⣿⣿  $(log_reset log_bold log_blue "Folder:") $(fetchfolder)"
  log_blue log_bold   "    ⣿⣿⣿⣿  $(log_reset log_bold log_blue "URL:") $(fetchurl)"
  log_blue            "          $(log_reset log_bold log_blue "Locale:") $(fetchlocale)"
  log_blue            "          $(log_reset log_bold log_blue "Timezone:") $(fetchtimezone)"
  log_blue            "          $(log_reset log_bold log_blue "Extensions:") $(fetchextensions)"
  log_blue            "          $(log_reset log_bold log_blue "Developer:") $(fetchdeveloper)"
  log_blue            "          $(log_reset log_bold log_blue "Telemetry:") $(fetchtelemetry)"
  log_blue            "          $(log_reset log_bold log_blue "Node:") $(fetchnode)"
  log_blue            "          $(log_reset log_bold log_blue "Yarn:") $(fetchyarn)"
  log_bright " "
fi

# -rerun-install
if [[ $2 == "-rerun-install" ]]; then VCMD="y"
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n"
  dbRemove "blueprint.setupFinished"
  cd ${FOLDER} || throw 'cdMissingDirectory'
  bash blueprint.sh
fi

# -upgrade
if [[ $2 == "-upgrade" ]]; then VCMD="y"
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n"

  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    quit_red "[FATAL] Your development directory contains files. To protect you against accidental data loss, you are unable to upgrade unless you clear your .blueprint/dev folder."
  fi


  # Confirmation question for developer upgrade.
  if [[ $3 == "dev" ]]; then
    log_blue "[INPUT] Upgrading to the latest dev build will update Blueprint to an unstable work-in-progress preview of the next version. Continue? (y/N)"
    read -r YN
    if [[ ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi
    YN=""
  fi

  # Confirmation question for both developer and stable upgrade.
  log_blue "[INPUT] Upgrading will wipe your .blueprint folder and will overwrite your extensions. Continue? (y/N)"
  read -r YN
  if [[ ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi
  YN=""

  # Last confirmation question for both developer and stable upgrade.
  log_blue "[INPUT] This is the last warning before upgrading/wiping Blueprint. Type 'continue' to continue, all other input will be taken as 'no'."
  read -r YN
  if [[ ${YN} != "continue" ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi
  YN=""


  log_bright "[INFO] Blueprint is upgrading.. Please do not turn off your machine."
  cp blueprint.sh .blueprint.sh.bak
  if [[ $3 == "dev" ]]; then  bash tools/update.sh ${FOLDER} dev
  else                        bash tools/update.sh ${FOLDER}; fi

  chmod +x blueprint.sh
  sed -i -E "s|FOLDER=\"/var/www/pterodactyl\" #;|FOLDER=\"$FOLDER\" #;|g" $FOLDER/blueprint.sh
  mv $FOLDER/blueprint $FOLDER/.blueprint;
  bash blueprint.sh --post-upgrade
  log_bright "[INFO] Bash might spit out some errors from here on out. Unexpected end of file (eof), command not found and syntax errors are expected behaviour."

  # Ask user if they'd like to migrate their database.
  log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
  read -r YN
  if [[ ( ${YN} == "y" ) || ( ${YN} == "Y" ) || ( ${YN} == "" ) ]]; then 
    log_bright "[INFO] Running database migrations.."
    php artisan migrate --force
  else
    log_bright "[INFO] Database migrations have been skipped."
  fi
  YN=""

  # Post-upgrade checks.
  log_bright "[INFO] Running post-upgrade checks.."
  score=0

  if dbValidate "blueprint.setupFinished"; then
    score=$((score+1))
  else
    log_yellow "[WARNING] 'blueprint.setupFinished' could not be found."
  fi

  # Finalize upgrade.
  if [[ ${score} == 1 ]]; then
    log_green "[SUCCESS] Blueprint has upgraded successfully."
    rm .blueprint.sh.bak
    exit 1
  elif [[ ${score} == 0 ]]; then
    log_red "[FATAL] All checks have failed."
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1
  else
    log_yellow "[WARNING] Some post-upgrade checks have failed."
    rm blueprint.sh
    mv .blueprint.sh.bak blueprint.sh
    exit 1
  fi
fi



# When the users attempts to run an invalid command.
if [[ ${VCMD} != "y" && $1 == "-bash" ]]; then
  # This is logged as a "fatal" error since it's something that is making Blueprint run unsuccessfully.
  quit_red "[FATAL] '$2' is not a valid command or argument. Use argument '-help' for a list of commands."
fi
