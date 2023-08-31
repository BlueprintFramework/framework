#!/bin/bash

# ptero.shop
# github.com/teamblueprint/main
# prpl.wtf

# This should allow Blueprint to run in Docker. Please note that changing the $FOLDER variable after running
# the Blueprint installation script will not change anything in any files besides blueprint.sh.
  FOLDER="/var/www/pterodactyl" #;

# If the fallback version below does not match your downloaded version, please let us know.
  VER_FALLBACK="alpha-VKL"

# This will be automatically replaced by some marketplaces, if not, $VER_FALLBACK will be used as fallback.
  PM_VERSION="([(pterodactylmarket_version)])"



# Allow non-default Pterodactyl installation folders.
if [[ $_FOLDER != "" ]]; then
  if [[ ( ! -f "$FOLDER/.blueprint/data/internal/db/version" ) || ( $FOLDER == "/var/www/pterodactyl" ) ]]; then
    sed -i -E "s|FOLDER=\"$FOLDER\" #;|FOLDER=\"$_FOLDER\" #;|g" $_FOLDER/blueprint.sh
  else
    echo "Variable cannot be replaced right now."
  fi
  exit 1
fi

# Check for panels that are using Docker.
if [[ -f ".dockerenv" ]]; then
  DOCKER="y"
  FOLDER="/var/www/html"
else
  DOCKER="n"
fi

if [[ -d "$FOLDER/blueprint" ]]; then mv $FOLDER/blueprint $FOLDER/.blueprint; fi

if [[ $PM_VERSION == "([(pterodactylmarket""_version)])" ]]; then
  # This runs when the placeholder has not changed, indicating an issue with PterodactylMarket
  # or Blueprint being installed from other sources.
  if [[ ! -f "$FOLDER/.blueprint/data/internal/db/version" ]]; then
    sed -E -i "s*&bp.version&*$VER_FALLBACK*g" app/Services/Helpers/BlueprintPlaceholderService.php
    sed -E -i "s*@version*$VER_FALLBACK*g" public/extensions/blueprint/index.html
    touch $FOLDER/.blueprint/data/internal/db/version
  fi
  
  VERSION=$VER_FALLBACK
elif [[ $PM_VERSION != "([(pterodactylmarket""_version)])" ]]; then
  # This runs in case it is possible to use the PterodactylMarket placeholder instead of the
  # fallback version.
  if [[ ! -f "$FOLDER/.blueprint/data/internal/db/version" ]]; then
    sed -E -i "s*&bp.version&*$PM_VERSION*g" app/Services/Helpers/BlueprintPlaceholderService.php
    sed -E -i "s*@version*$PM_VERSION*g" public/extensions/blueprint/index.html
    touch $FOLDER/.blueprint/data/internal/db/version
  fi

  VERSION=$PM_VERSION
fi

# Fix for Blueprint's bash database/telemetry/admincachereminder to work with Docker and custom folder installations.
sed -i "s!&bp.folder&!$FOLDER!g" $FOLDER/.blueprint/lib/db.sh
sed -i "s!&bp.folder&!$FOLDER!g" $FOLDER/.blueprint/lib/telemetry.sh
sed -i "s!&bp.folder&!$FOLDER!g" $FOLDER/.blueprint/lib/updateAdminCacheReminder.sh

# Automatically navigate to the Pterodactyl directory when running the core.
cd $FOLDER 

# Import libraries.
source .blueprint/lib/bash_colors.sh
source .blueprint/lib/parse_yaml.sh
source .blueprint/lib/db.sh
source .blueprint/lib/telemetry.sh
source .blueprint/lib/updateAdminCacheReminder.sh
if [[ ! -f ".blueprint/lib/bash_colors.sh" ]]; then LIB__bash_colors="missing";fi
if [[ ! -f ".blueprint/lib/parse_yaml.sh" ]]; then LIB__parse_yaml="missing";fi
if [[ ! -f ".blueprint/lib/db.sh" ]]; then LIB__db="missing";fi
if [[ ! -f ".blueprint/lib/telemetry.sh" ]]; then LIB__telemetry="missing";fi
if [[ ! -f ".blueprint/lib/updateAdminCacheReminder.sh" ]]; then LIB__updateAdminCacheReminder="missing";fi

# Fallback to these functions if "bash_colors.sh" is missing
if [[ $LIB__bash_colors == "missing" ]]; then
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

# Make sure yarn doesn't freak out when building the panel.
export NODE_OPTIONS=--openssl-legacy-provider



# -config
# usage: "cITEM=VALUE bash blueprint.sh -config"
if [[ "$1" == "-config" ]]; then

  # cTELEMETRY_ID
  # Update the telemetry id.
  if [[ $cTELEMETRY_ID != "" ]]; then
    echo "$cTELEMETRY_ID" > .blueprint/data/internal/db/telemetry_id
  fi

  # cDEVELOPER
  # Enable/Disable developer mode.
  if [[ $cDEVELOPER != "" ]]; then
    echo "$cDEVELOPER" > .blueprint/data/internal/db/developer
  fi

  echo .
  exit 1
fi


# Function that exits the script after logging a "red" message.
quit_red() { log_red "$1"; exit 1; }


depend() {
  # Check for required dependencies.
  if ! [ -x "$(command -v unzip)" ]; then
    log_red '[FATAL] Required dependency unzip is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if ! [ -x "$(command -v node)" ]; then
    log_red '[FATAL] Required dependency node is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if ! [ -x "$(command -v yarn)" ]; then
    log_red '[FATAL] Required dependency yarn is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi

  # End process when using an older Node.JS version.
  nodeVer=$(node -v)
  if [[ $nodeVer != "v17."* ]] && 
     [[ $nodeVer != "v18."* ]] && 
     [[ $nodeVer != "v19."* ]] && 
     [[ $nodeVer != "v20."* ]] && 
     [[ $nodeVer != "v21."* ]]; then 
    log_red '[FATAL] Required dependency node is an unsupported version.' >&2
    DEPEND_MISSING=true
  fi

  # Check for internal dependencies.
  if [[ $LIB__bash_colors ]]; then
    log_red '[FATAL] Internal dependency bash_colors is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if [[ $LIB__parse_yaml ]]; then
    log_red '[FATAL] Internal dependency parse_yaml is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if [[ $LIB__db ]]; then
    log_red '[FATAL] Internal dependency db is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if [[ $LIB__telemetry ]]; then
    log_red '[FATAL] Internal dependency telemetry is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi; if [[ $LIB__updateAdminCacheReminder ]]; then
    log_red '[FATAL] Internal dependency updateAdminCacheReminder is not installed or detected.' >&2
    DEPEND_MISSING=true
  fi

  # Exit when missing dependencies.
  if [[ $DEPEND_MISSING == true ]]; then exit 1; fi
}


# Adds the "blueprint" command to the /usr/local/bin directory and configures the correct permissions for it.
touch /usr/local/bin/blueprint > /dev/null
echo -e "#!/bin/bash\nbash $FOLDER/blueprint.sh -bash \$@;" > /usr/local/bin/blueprint
chmod u+x $FOLDER/blueprint.sh > /dev/null
chmod u+x /usr/local/bin/blueprint > /dev/null


if [[ $1 != "-bash" ]]; then
  if dbValidate "blueprint.setupFinished"; then
    log_yellow "[WARNING] This command only works if you have yet to install Blueprint. Run 'blueprint (cmd) [arg]' instead."
    exit 1
  else
    # Only run if Blueprint is not in the process of upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log "  ██\n██  ██\n  ████\n"; # Blueprint "ascii" "logo".
      if [[ $DOCKER == "y" ]]; then
        log_yellow "[WARNING] While running Blueprint with docker is supported, you may run into some issues. Report problems you find at ptero.shop/issue."
      fi
    fi

    log_bright "[INFO] Checking dependencies.."
    # Check if required programs are installed
    depend

    # Update folder placeholder on PlaceholderService and admin layout.
    log_bright "[INFO] Updating folder placeholders.."
    sed -i "s!&bp.folder&!$FOLDER!g" $FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php
    sed -i "s!&bp.folder&!$FOLDER!g" $FOLDER/resources/views/layouts/admin.blade.php

    # Copy "Blueprint" extension page logo from assets.
    log_bright "[INFO] Copying Blueprint logo from assets."
    cp $FOLDER/.blueprint/assets/logo.jpg $FOLDER/public/assets/extensions/blueprint/logo.jpg

    # Put application into maintenance.
    log_bright "[INFO] Enable maintenance."
    php artisan down

    # Inject custom Blueprint css into Pterodactyl's admin panel.
    log_bright "[INFO] Modifying admin panel css."
    sed -i "s!@import url(/assets/extensions/blueprint/blueprint.style.css);!!g" $FOLDER/public/themes/pterodactyl/css/pterodactyl.css
    sed -i "s!/\* admin.css \*/!!g" $FOLDER/public/themes/pterodactyl/css/pterodactyl.css
    sed -i '1i@import url(/assets/extensions/blueprint/blueprint.style.css);\n/* admin.css */' $FOLDER/public/themes/pterodactyl/css/pterodactyl.css

    # Clear view cache.
    log_bright "[INFO] Clearing view cache."
    php artisan view:clear
    php artisan config:clear

    # Roll admin css refresh number.
    log_bright "[INFO] Rolling admin cache refresh class name."
    updateCacheReminder


    # Run migrations if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
      read YN
      if [[ ( $YN == "y" ) || ( $YN == "Y" ) || ( $YN == "" ) ]]; then 
        log_bright "[INFO] Running database migrations.."
        php artisan migrate --force
      else
        log_bright "[INFO] Database migrations have been skipped."
      fi
    fi


    # Make sure all files have correct permissions.
    log_bright "[INFO] Changing file ownership to www-data."
    chown -R www-data:www-data $FOLDER/*
    chown -R www-data:www-data $FOLDER/.blueprint/*

    log_bright "[INFO] Removing placeholder files."
    # Remove placeholder README.md files.
    if [[ -f "$FOLDER/.blueprint/dev/README.md" ]]; then
      rm -R $FOLDER/.blueprint/dev/*
    fi
    if [[ -f "$FOLDER/.blueprint/data/extensions/README.md" ]]; then
      rm -R $FOLDER/.blueprint/data/extensions/*
    fi
    if [[ -f "$FOLDER/tools/tmp/README.md" ]]; then
      rm $FOLDER/tools/tmp/README.md
    fi

    # Rebuild panel assets.
    log_bright "[INFO] Rebuilding panel assets.."
    yarn run build:production

    # Put application into production.
    log_bright "[INFO] Disable maintenance."
    php artisan up

    # Only show donate + success message if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_bright "[INFO] Blueprint is completely open source and free. Please consider supporting us on \"ptero.shop/donate\"."
      sleep 2
      log_green "\n\n[SUCCESS] Blueprint should now be installed. If something didn't work as expected, please let us know at ptero.shop/issue."
    fi

    dbAdd "blueprint.setupFinished"
    # Let the panel know the user has finished installation.
    sed -i "s!NOTINSTALLED!INSTALLED!g" $FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php
    exit 1
  fi
fi


# -i, -install
if [[ ( $2 == "-i" ) || ( $2 == "-install" ) ]]; then VCMD="y"
  if [[ $(expr $# - 2) != 1 ]]; then quit_red "[FATAL] Expected 1 argument but got $(expr $# - 2).";fi
  if [[ ( $3 == "./"* ) || ( $3 == "../"* ) || ( $3 == "/"* ) ]]; then quit_red "[FATAL] Installing extensions located in paths outside of '$FOLDER' is not possible.";fi

  log_bright "[INFO] Checking dependencies.."
  # Check if required programs are installed
  depend

  if [[ $3 == "test␀" ]]; then
    dev=true
    n="dev"
    mkdir -p .blueprint/tmp/dev
    cp -R .blueprint/dev/* .blueprint/tmp/dev/
  else
    dev=false
    n=$3
    FILE=$n".blueprint"
    if [[ ! -f "$FILE" ]]; then quit_red "[FATAL] $FILE could not be found.";fi

    ZIP=$n".zip"
    cp $FILE .blueprint/tmp/$ZIP
    cd .blueprint/tmp
    unzip -o -qq $ZIP
    rm $ZIP
    if [[ ! -f "$n/*" ]]; then
      cd ..
      rm -R tmp
      mkdir -p tmp
      cd tmp

      mkdir -p ./$n
      cp ../../$FILE ./$n/$ZIP
      cd $n
      unzip -o -qq $ZIP
      rm $ZIP
      cd ..
    fi
  fi

  # Return to the Pterodactyl installation folder.
  cd $FOLDER

  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/tmp/$n/conf.yml" ]]; then quit_red "[FATAL] Could not find a conf.yml file.";fi
  eval $(parse_yaml .blueprint/tmp/$n/conf.yml conf_)

  # Add aliases for config values to make working with them easier.
  name="$conf_info_name"
  identifier="$conf_info_identifier"
  description="$conf_info_description"
  flags="$conf_info_flags"
  version="$conf_info_version"
  target="$conf_info_target"
  author="$conf_info_author"
  icon="$conf_info_icon" #(optional)
  website="$conf_info_website"; #(optional)

  admin_view="$conf_admin_view"
  admin_controller="$conf_admin_controller"; #(optional)
  admin_css="$conf_admin_css"; #(optional)
  admin_wrapper="$conf_admin_wrapper"; #(optional)

  dashboard_wrapper="$conf_dashboard_wrapper"; #(optional)
  dashboard_css="$conf_dashboard_css"; #(optional)

  data_directory="$conf_data_directory"; #(optional)
  data_public="$conf_data_public"; #(optional)

  database_migrations="$conf_database_migrations"; #(optional)

  if [[ ( $icon == "/"*                ) || ( $icon == "."*                ) || ( $icon == *"\n"*                ) ]] ||
     [[ ( $admin_view == "/"*          ) || ( $admin_view == "."*          ) || ( $admin_view == *"\n"*          ) ]] ||
     [[ ( $admin_controller == "/"*    ) || ( $admin_controller == "."*    ) || ( $admin_controller == *"\n"*    ) ]] ||
     [[ ( $admin_css == "/"*           ) || ( $admin_css == "."*           ) || ( $admin_css == *"\n"*           ) ]] ||
     [[ ( $data_directory == "/"*      ) || ( $data_directory == "."*      ) || ( $data_directory == *"\n"*      ) ]] ||
     [[ ( $data_public == "/"*         ) || ( $data_public == "."*         ) || ( $data_public == *"\n"*         ) ]] ||
     [[ ( $database_migrations == "/"* ) || ( $database_migrations == "."* ) || ( $database_migrations == *"\n"* ) ]]; then
    rm -R .blueprint/tmp/$n
    quit_red "[FATAL] Extension has failed security checks, halting installation."
  fi

  # Detect if extension is already installed and prepare the upgrading process.
  if [[ $(cat .blueprint/data/internal/db/installed_extensions) == *"$identifier,"* ]]; then
    log_bright "[INFO] Extension appears to be installed already, reading variables.."
    eval $(parse_yaml .blueprint/data/extensions/$identifier/.store/conf.yml old_)
    DUPLICATE="y"

    if [[ ! -f ".blueprint/data/extensions/$identifier/.store/build/button.blade.php" ]]; then
      rm -R .blueprint/tmp/$n
      quit_red "[FATAL] Upgrading extension has failed due to missing essential .store files."
    fi

    # clean up public folder
    log_bright "[INFO] Cleaning up old extension files.."
    if [[ $old_data_public != "" ]]; then
      rm -R public/extensions/$old_identifier/*
    fi
  fi

  if [[ $website != "" ]]; then
    if [[ $website != "https://"* ]]; then
      if [[ $website != "http://"* ]]; then
        website="http://"$info_website
      fi
    fi
  fi

  if [[ $dev == true ]]; then
    mv .blueprint/tmp/$n .blueprint/tmp/$identifier
    n=$identifier
  fi

  if [[ ( $flags != *"ignorePlaceholders,"* ) && ( $flags != *"ignorePlaceholders" ) ]]; then
    DIR=.blueprint/tmp/$n/*

    if [[ ( $flags == *"ignoreAlphabetPlaceholders,"* ) || ( $flags == *"ignoreAlphabetPlaceholders" ) ]]; then
      SKIPAZPLACEHOLDERS=true
      log_bright "[INFO] Alphabet placeholders will be skipped due to the 'ignoreAlphabetPlaceholders' flag."
    else
      SKIPAZPLACEHOLDERS=false
    fi

    for f in $(find $DIR -type f -exec echo {} \;); do
      sed -i "s~\^#version#\^~$version~g" $f
      sed -i "s~\^#author#\^~$author~g" $f
      sed -i "s~\^#name#\^~$name~g" $f
      sed -i "s~\^#identifier#\^~$identifier~g" $f
      sed -i "s~\^#path#\^~$FOLDER~g" $f
      sed -i "s~\^#datapath#\^~$FOLDER/.blueprint/data/extensions/$identifier~g" $f

      if [[ $SKIPAZPLACEHOLDERS != true ]]; then
        sed -i "s~__version__~$version~g" $f
        sed -i "s~__author__~$author~g" $f
        sed -i "s~__identifier__~$identifier~g" $f
        sed -i "s~__name__~$name~g" $f
        sed -i "s~__path__~$FOLDER~g" $f
        sed -i "s~__datapath__~$FOLDER/.blueprint/data/extensions/$identifier~g" $f
      fi

      log_bright "[INFO] Done placeholders in '$f'."
    done
  else log_bright "[INFO] Placeholders will be skipped due to the 'ignorePlaceholders' flag."; fi

  if [[ $name == "" ]]; then rm -R .blueprint/tmp/$n;                 quit_red "[FATAL] 'info_name' is a required configuration option.";fi
  if [[ $identifier == "" ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] 'info_identifier' is a required configuration option.";fi
  if [[ $description == "" ]]; then rm -R .blueprint/tmp/$n;          quit_red "[FATAL] 'info_description' is a required configuration option.";fi
  if [[ $version == "" ]]; then rm -R .blueprint/tmp/$n;              quit_red "[FATAL] 'info_version' is a required configuration option.";fi
  if [[ $target == "" ]]; then rm -R .blueprint/tmp/$n;               quit_red "[FATAL] 'info_target' is a required configuration option.";fi

  if [[ $icon == "" ]]; then                                        log_yellow "[WARNING] This extension does not come with an icon, consider adding one.";fi
  if [[ $admin_controller == "" ]]; then                            log_bright "[INFO] Admin controller field left blank, using default controller instead.."
    controller_type="default";else controller_type="custom";fi
  if [[ $admin_view == "" ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] 'admin_view' is a required configuration option.";fi
  if [[ $target != $VERSION ]]; then                                log_yellow "[WARNING] This extension is built for version $target, but your version is $VERSION.";fi
  if [[ $identifier != $n ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] The extension file name must be the same as your identifier. (example: identifier.blueprint)";fi
  if [[ $identifier == "blueprint" ]]; then rm -R .blueprint/tmp/$n;  quit_red "[FATAL] Extensions can not have the identifier 'blueprint'.";fi

  if [[ $identifier =~ [a-z] ]]; then                               log_bright "[INFO] Identifier a-z checks passed."
  else rm -R .blueprint/tmp/$n;                                       quit_red "[FATAL] The extension identifier should be lowercase and only contain characters a-z.";fi
  if [[ ! -f ".blueprint/tmp/$n/$icon" ]]; then
    rm -R .blueprint/tmp/$n;                                          quit_red "[FATAL] The 'info_icon' path points to a file that does not exist.";fi

  if [[ $database_migrations != "" ]]; then
    cp -R .blueprint/tmp/$n/$database_migrations/* database/migrations/ 2> /dev/null
  fi

  if [[ $data_public != "" ]]; then
    mkdir -p public/extensions/$identifier
    cp -R .blueprint/tmp/$n/$data_public/* public/extensions/$identifier/ 2> /dev/null
  fi

  cp -R .blueprint/data/internal/build/extensions/admin.blade.php .blueprint/data/internal/build/extensions/admin.blade.php.bak 2> /dev/null
  if [[ $admin_controller == "" ]]; then # use default controller when admin_controller is left blank
    cp -R .blueprint/data/internal/build/extensions/controller.php .blueprint/data/internal/build/extensions/controller.php.bak 2> /dev/null
  fi
  cp -R .blueprint/data/internal/build/extensions/route.php .blueprint/data/internal/build/extensions/route.php.bak 2> /dev/null
  cp -R .blueprint/data/internal/build/extensions/button.blade.php .blueprint/data/internal/build/extensions/button.blade.php.bak 2> /dev/null

  # Start creating data directory.
  mkdir -p .blueprint/data/extensions/$identifier
  mkdir -p .blueprint/data/extensions/$identifier/.store
  
  cp .blueprint/tmp/$n/conf.yml .blueprint/data/extensions/$identifier/.store/conf.yml; #backup conf.yml
  
  if [[ $data_directory != "" ]]; then
    cp -R .blueprint/tmp/$n/$data_directory/* .blueprint/data/extensions/$identifier/
  fi
  # End creating data directory.

  mkdir -p public/assets/extensions/$identifier
  if [[ $icon == "" ]]; then
    # use random placeholder icon if extension does not
    # come with an icon.
    icnNUM=$(expr 1 + $RANDOM % 6)
    cp .blueprint/assets/defaultExtensionLogo$icnNUM.jpg public/assets/extensions/$identifier/icon.jpg
  else
    cp .blueprint/tmp/$n/$icon public/assets/extensions/$identifier/icon.jpg
  fi;
  ICON="/assets/extensions/$identifier/icon.jpg"
  CONTENT=$(cat .blueprint/tmp/$n/$admin_view)

  if [[ $admin_css != "" ]]; then
    updateCacheReminder
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" public/themes/pterodactyl/css/pterodactyl.css
    sed -i "s~/\* admin.css \*/~/\* admin.css \*/\n@import url(/assets/extensions/$identifier/admin.style.css);~g" public/themes/pterodactyl/css/pterodactyl.css
    cp .blueprint/tmp/$n/$admin_css public/assets/extensions/$identifier/admin.style.css
  fi
  if [[ $dashboard_css != "" ]]; then
    YARN="y"
    sed -i "s~@import url($identifier.css);~~g" resources/scripts/css/extensions.css
    sed -i "s~/\* client.css \*/~/\* client.css \*/\n@import url($identifier.css);~g" resources/scripts/css/extensions.css
    cp .blueprint/tmp/$n/$dashboard_css resources/scripts/css/$identifier.css
  fi

  if [[ $name == *"~"* ]]; then log_yellow "[WARNING] 'name' contains '~' and may result in an error.";fi
  if [[ $description == *"~"* ]]; then log_yellow "[WARNING] 'description' contains '~' and may result in an error.";fi
  if [[ $version == *"~"* ]]; then log_yellow "[WARNING] 'version' contains '~' and may result in an error.";fi
  if [[ $CONTENT == *"~"* ]]; then log_yellow "[WARNING] 'CONTENT' contains '~' and may result in an error.";fi
  if [[ $ICON == *"~"* ]]; then log_yellow "[WARNING] 'ICON' contains '~' and may result in an error.";fi
  if [[ $identifier == *"~"* ]]; then log_yellow "[WARNING] 'identifier' contains '~' and may result in an error.";fi

  sed -i "s~␀title␀~$name~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
  sed -i "s~␀name␀~$name~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
  sed -i "s~␀name␀~$name~g" .blueprint/data/internal/build/extensions/button.blade.php.bak

  sed -i "s~␀description␀~$description~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak

  sed -i "s~␀version␀~$version~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
  sed -i "s~␀version␀~$version~g" .blueprint/data/internal/build/extensions/button.blade.php.bak

  sed -i "s~␀icon␀~$ICON~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak

  if [[ $website != "" ]]; then
    sed -i "s~␀website␀~$website~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
    sed -i "s~<!--websitecomment␀ ~~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
    sed -i "s~ ␀websitecomment-->~~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak
  fi

  echo -e "$CONTENT\n@endsection" >> .blueprint/data/internal/build/extensions/admin.blade.php.bak


  if [[ $admin_controller == "" ]]; then
    sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/controller.php.bak
  fi
  sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/route.php.bak
  sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/button.blade.php.bak

  ADMINVIEW_RESULT=$(cat .blueprint/data/internal/build/extensions/admin.blade.php.bak)
  ADMINROUTE_RESULT=$(cat .blueprint/data/internal/build/extensions/route.php.bak)
  ADMINBUTTON_RESULT=$(cat .blueprint/data/internal/build/extensions/button.blade.php.bak)
  if [[ $admin_controller == "" ]]; then
    ADMINCONTROLLER_RESULT=$(cat .blueprint/data/internal/build/extensions/controller.php.bak)
  fi
  ADMINCONTROLLER_NAME=$identifier"ExtensionController.php"

  mkdir -p resources/views/admin/extensions/$identifier
  touch resources/views/admin/extensions/$identifier/index.blade.php
  echo $ADMINVIEW_RESULT > resources/views/admin/extensions/$identifier/index.blade.php

  mkdir -p app/Http/Controllers/Admin/Extensions/$identifier
  touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME

  if [[ $admin_controller == "" ]]; then
    touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME
    echo $ADMINCONTROLLER_RESULT > app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME
  else
    cp .blueprint/tmp/$n/$admin_controller app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME
  fi

  if [[ $DUPLICATE != "y" ]]; then
    echo $ADMINROUTE_RESULT >> routes/admin.php
  fi

  if [[ $DUPLICATE == "y" ]]; then
    OLDBUTTON_RESULT=$(cat .blueprint/data/extensions/$identifier/.store/build/button.blade.php)
    sed -i "s~$OLDBUTTON_RESULT~~g" resources/views/admin/extensions.blade.php
  fi
  sed -i "s~<!--␀replace␀-->~$ADMINBUTTON_RESULT\n<!--␀replace␀-->~g" resources/views/admin/extensions.blade.php

  # insert "dashboard_wrapper" into wrapper.blade.php
  if [[ $dashboard_wrapper != "" ]]; then
    if [[ $DUPLICATE == "y" ]]; then
      sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" resources/views/templates/wrapper.blade.php
      sed -i "s~<!--␀$identifier:start␀-->~~g" resources/views/templates/wrapper.blade.php
      sed -i "s~<!--␀$identifier:stop␀-->~~g" resources/views/templates/wrapper.blade.php
    fi
    touch .blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK
    cat <(echo "<!--␀$identifier:start␀-->") .blueprint/tmp/$n/$dashboard_wrapper > .blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK
    cp .blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK .blueprint/tmp/$n/$dashboard_wrapper
    rm .blueprint/tmp/$n/$dashboard_wrapper.BLUEPRINTBAK
    echo -e "\n<!--␀$identifier:stop␀-->" >> .blueprint/tmp/$n/$dashboard_wrapper
    sed -i "/<\!-- wrapper:insert -->/r .blueprint/tmp/$n/$dashboard_wrapper" resources/views/templates/wrapper.blade.php
  fi

  # insert "admin_wrapper" into admin.blade.php
  if [[ $admin_wrapper != "" ]]; then
    if [[ $DUPLICATE == "y" ]]; then
      sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" resources/views/layouts/admin.blade.php
      sed -i "s~<!--␀$identifier:start␀-->~~g" resources/views/layouts/admin.blade.php
      sed -i "s~<!--␀$identifier:stop␀-->~~g" resources/views/layouts/admin.blade.php
    fi
    touch .blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK
    cat <(echo "<!--␀$identifier:start␀-->") .blueprint/tmp/$n/$admin_wrapper > .blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK
    cp .blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK .blueprint/tmp/$n/$admin_wrapper
    rm .blueprint/tmp/$n/$admin_wrapper.BLUEPRINTBAK
    echo -e "\n<!--␀$identifier:stop␀-->" >> .blueprint/tmp/$n/$admin_wrapper
    sed -i "/<\!-- wrapper:insert -->/r .blueprint/tmp/$n/$admin_wrapper" resources/views/layouts/admin.blade.php
  fi

  # Create backup of generated values.
  log_bright "[INFO] Backing up (some) build files.."
  mkdir -p .blueprint/data/extensions/$identifier/.store/build
  cp .blueprint/data/internal/build/extensions/button.blade.php.bak .blueprint/data/extensions/$identifier/.store/build/button.blade.php
  cp .blueprint/data/internal/build/extensions/route.php.bak .blueprint/data/extensions/$identifier/.store/build/route.php

  log_bright "[INFO] Cleaning up build files.."
  rm .blueprint/data/internal/build/extensions/admin.blade.php.bak
  if [[ $admin_controller == "" ]]; then
    rm .blueprint/data/internal/build/extensions/controller.php.bak
  fi
  rm .blueprint/data/internal/build/extensions/route.php.bak
  rm .blueprint/data/internal/build/extensions/button.blade.php.bak
  log_bright "[INFO] Cleaning up temp files.."
  rm -R .blueprint/tmp/$n

  if [[ $database_migrations != "" ]]; then
    log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
    read YN
    if [[ ( $YN == "y" ) || ( $YN == "Y" ) || ( $YN == "" ) ]]; then 
      log_bright "[INFO] Running database migrations.."
      php artisan migrate --force
    else
      log_bright "[INFO] Database migrations have been skipped."
    fi
  fi

  chown -R www-data:www-data $FOLDER/.blueprint/data/extensions/$identifier
  chmod --silent -R +x .blueprint/data/extensions/* 2> /dev/null

  if [[ ( $flags == *"hasInstallScript,"* ) || ( $flags == *"hasInstallScript" ) ]]; then
    log_yellow "[WARNING] This extension uses a custom installation script, proceed with caution."
    chmod +x .blueprint/data/extensions/$identifier/install.sh
    bash .blueprint/data/extensions/$identifier/install.sh
  fi

  if [[ $DUPLICATE != "y" ]]; then
    echo $identifier"," >> .blueprint/data/internal/db/installed_extensions
    log_bright "[INFO] Added '$identifier' to the list of installed extensions."
  fi

  if [[ $YARN == "y" ]]; then 
    log_bright "[INFO] Rebuilding panel.."
    yarn run build:production
  fi

  if [[ $DUPLICATE == "y" ]]; then
    log_green "\n\n[SUCCESS] $identifier should now be updated. If something didn't work as expected, please let us know at ptero.shop/issue."
  else
    log_green "\n\n[SUCCESS] $identifier should now be installed. If something didn't work as expected, please let us know at ptero.shop/issue."
  fi
  if [[ $dev != true ]]; then
    sendTelemetry "FINISH_EXTENSION_INSTALLATION" > /dev/null
  fi
fi

# -r, -remove
if [[ ( $2 == "-r" ) || ( $2 == "-remove" ) ]]; then VCMD="y"
  if [[ $(expr $# - 2) != 1 ]]; then quit_red "[FATAL] Expected 1 argument but got $(expr $# - 2).";fi
  
  # Check if the extension is installed.
  if [[ $(cat .blueprint/data/internal/db/installed_extensions) != *"$identifier,"* ]]; then
    quit_red "[FATAL] '$3' is not installed."
  fi

  if [[ -f ".blueprint/data/extensions/$3/.store/conf.yml" ]]; then 
    eval $(parse_yaml .blueprint/data/extensions/$3/.store/conf.yml conf_)
    # Add aliases for config values to make working with them easier.
    name="$conf_info_name";    
    identifier="$conf_info_identifier"
    description="$conf_info_description"
    flags="$conf_info_flags"
    version="$conf_info_version"
    target="$conf_info_target"
    author="$conf_info_author"
    icon="$conf_info_icon"
    website="$conf_info_website"; #(optional)

    admin_view="$conf_admin_view"
    admin_controller="$conf_admin_controller"; #(optional)
    admin_css="$conf_admin_css"; #(optional)
    admin_wrapper="$conf_admin_wrapper"; #(optional)

    dashboard_wrapper="$conf_dashboard_wrapper"; #(optional)
    dashboard_css="$conf_dashboard_css"; #(optional)

    data_directory="$conf_data_directory"; #(optional)
    data_public="$conf_data_public"; #(optional)

    database_migrations="$conf_database_migrations"; #(optional)
  else 
    quit_red "[FATAL] Backup conf.yml could not be found."
  fi

  log_bright "[INFO] Checking dependencies.."
  depend

  log_blue "[INPUT] Are you sure you want to continue? Some extension files might not be removed as Blueprint does not keep track of them. (y/N)"
  read YN
  if [[ ( $YN == "n"* ) || ( $YN == "N"* ) || ( $YN == "" ) ]]; then log_bright "[INFO] Extension removal cancelled.";exit 1;fi

  # Remove admin button 
  log_bright "[INFO] Removing admin button.."
  OLDBUTTON_RESULT=$(cat .blueprint/data/extensions/$identifier/.store/build/button.blade.php)
  sed -i "s~$OLDBUTTON_RESULT~~g" resources/views/admin/extensions.blade.php

  # Remove admin routes 
  log_bright "[INFO] Removing admin routes.."
  OLDROUTE_RESULT=$(sed ':a;N;$!ba;s/\n/___NEWLINE___/g' .blueprint/data/extensions/$identifier/.store/build/route.php) # Read the contents of route.php into the variable, replacing \n with a placeholder string
  sed -i "s#$(echo "$OLDROUTE_RESULT" | sed 's/[\/&]/\\&/g')##g" routes/admin.php # Perform the sed operation, using the placeholder string as the delimiter
  OLDROUTE_RESULT=$(echo "$OLDROUTE_RESULT" | sed 's/___NEWLINE___/\n/g') # Restore the original newlines in the $OLDROUTE_RESULT variable

  # Remove admin view
  log_bright "[INFO] Removing admin view.."
  rm -R resources/views/admin/extensions/$identifier

  # Remove admin controller
  log_bright "[INFO] Removing admin controller.."
  rm -R app/Http/Controllers/Admin/Extensions/$identifier

  # Remove admin css
  if [[ $admin_css != "" ]]; then
    log_bright "[INFO] Removing admin css.."
    updateCacheReminder
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" public/themes/pterodactyl/css/pterodactyl.css
    sed -i "s~@import url(/assets/extensions/$identifier/$identifier.style.css);~~g" public/themes/pterodactyl/css/pterodactyl.css; #this removes changes made in older versions of blueprint
  fi

  # Remove admin wrapper
  if [[ $admin_wrapper != "" ]]; then 
    log_bright "[INFO] Removing admin wrapper.."
    sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" resources/views/layouts/admin.blade.php
  fi

  # Remove dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then 
    log_bright "[INFO] Removing dashboard wrapper.."
    sed -n -i "/<!--␀$identifier:start␀-->/{p; :a; N; /<!--␀$identifier:stop␀-->/!ba; s/.*\n//}; p" resources/views/templates/wrapper.blade.php
  fi

  # Remove dashboard css
  if [[ $dashboard_css != "" ]]; then
    log_bright "[INFO] Removing dashboard css.."
    sed -i "s~@import url($identifier.css);~~g" resources/scripts/css/extensions.css
    YARN="y"
  fi

  # Remove public folder
  if [[ $data_public != "" ]]; then 
    log_bright "[INFO] Removing public folder.."
    rm -R public/extensions/$identifier
  fi

  # Remove assets folder
  log_bright "[INFO] Removing assets.."
  rm -R public/assets/extensions/$identifier

  # Remove data folder
  log_bright "[INFO] Removing data folder.."
  rm -R .blueprint/data/extensions/$identifier
  
  # Remove from installed list
  log_bright "[INFO] Removing extension from installed extensions list.."
  sed -i "s~$identifier,~~g" .blueprint/data/internal/db/installed_extensions

  # Rebuild panel
  if [[ $YARN == "y" ]]; then
    log_bright "[INFO] Rebuilding panel assets.."
    yarn run build:production
  fi

  log_green "[SUCCESS] '$identifier' has been removed from your panel. Please note that some files might be left behind."
fi


# help, -help, --help 
if [[ ( $2 == "help" ) || ( $2 == "-help" ) || ( $2 == "--help" ) ]]; then VCMD="y"

  if [[ $(cat .blueprint/data/internal/db/developer) == "true"* ]]; then
    help_dev_status=""
    help_dev_primary="\e[34;1m"
    help_dev_secondary="\e[34m"
  else 
    help_dev_status=" (disabled)"
    help_dev_primary="\x1b[37;1m"
    help_dev_secondary="\x1b[37;1m"
  fi

  echo -e "
\x1b[34;1mExtensions\x1b[0m\x1b[34m
  -install [name]      -i  install/update a blueprint extension
  -remove [name]       -r  remove a blueprint extension
  \x1b[0m
  
${help_developer_primary}Developer$help_dev_status\x1b[0m${help_developer_secondary}
  -init                    initialize development files
  -build                   install/update your development files
  -export                  export your development files
  \x1b[0m
  
\x1b[34;1mMisc\x1b[0m\x1b[34m
  -version             -v  returns the blueprint version
  \x1b[0m
  
\x1b[34;1mAdvanced\x1b[0m\x1b[34m
  -upgrade (dev)           update/reset to a newer (source) version
  -rerun-install           rerun the blueprint installation script
  \x1b[0m
  "
fi


# -v, -version
if [[ ( $2 == "-v" ) || ( $2 == "-version" ) ]]; then VCMD="y"
  echo -e $VERSION
fi


# -init
if [[ $2 == "-init" ]]; then VCMD="y"
  if [[ $(cat .blueprint/data/internal/db/developer) != "true"* ]]; then quit_red "[FATAL] Developer mode is not enabled.";exit 1;fi

  # To prevent accidental wiping of your dev directory, you are unable to initialize another extension
  # until you wipe the contents of the .blueprint/dev directory.
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    quit_red "[FATAL] Your development directory contains files. To protect you against accidental data loss, you are unable to initialize another extension unless you clear your .blueprint/dev folder."
  fi

  ask_name() {
    log_blue "[INPUT] Name (Generic Extension):"
    read ASKNAME

    REDO_NAME=false

    # Name should not be empty
    if [[ $ASKNAME == "" ]]; then 
      log_red "[FATAL] Name should not be empty."
      REDO_NAME=true
    fi

    if [[ $REDO_NAME == true ]]; then
      # Ask again if response does not pass validation.
      ask_name
    fi
  }

  ask_identifier() {
    log_blue "[INPUT] Identifier (genericextension):"
    read ASKIDENTIFIER

    REDO_IDENTIFIER=false

    # Identifier should not be empty
    if [[ $ASKIDENTIFIER == "" ]]; then
      log_red "[FATAL] Identifier should not be empty."
      REDO_IDENTIFIER=true
    fi
  
    # Identifier should be a-z.
    if [[ $ASKIDENTIFIER =~ [a-z] ]]; then
      echo ok > /dev/null
    else 
      log_red "[FATAL] Identifier should only contain a-z characters."
      REDO_IDENTIFIER=true
    fi

    if [[ $REDO_IDENTIFIER == true ]]; then
      # Ask again if response does not pass validation.
      ask_identifier
    fi
  }

  ask_description() {
    log_blue "[INFO] Description (My awesome description):"
    read ASKDESCRIPTION

    REDO_DESCRIPTION=false

    # Description should not be empty
    if [[ $ASKDESCRIPTION == "" ]]; then
      log_red "[FATAL] Description should not be empty."
      REDO_DESCRIPTION=true
    fi

    if [[ $REDO_DESCRIPTION == true ]]; then
      # Ask again if response does not pass validation.
      ask_description
    fi
  }

  ask_version() {
    log_blue "[INPUT] Version (indev):"
    read ASKVERSION

    REDO_VERSION=false

    # Version should not be empty
    if [[ $ASKVERSION == "" ]]; then
      log_red "[FATAL] Version should not be empty."
      REDO_VERSION=true
    fi

    if [[ $REDO_VERSION == true ]]; then
      # Ask again if response does not pass validation.
      ask_version
    fi
  }

  ask_author() {
    log_blue "[INPUT] Author (prplwtf):"
    read ASKAUTHOR

    REDO_AUTHOR=false

    # Author should not be empty
    if [[ $ASKAUTHOR == "" ]]; then
      log_red "[FATAL] Author should not be empty."
      REDO_AUTHOR=true
    fi

    if [[ $REDO_AUTHOR == true ]]; then
      # Ask again if response does not pass validation.
      ask_author
    fi
  }

  ask_name
  ask_identifier
  ask_description
  ask_version
  ask_author

  log_bright "[INFO] Copying init defaults to tmp directory.."
  mkdir -p .blueprint/tmp/init
  cp -R .blueprint/data/internal/build/init/* .blueprint/tmp/init/

  log_bright "[INFO] Applying variables.."
  sed -i "s~␀name␀~$ASKNAME~g" .blueprint/tmp/init/conf.yml; #NAME
  sed -i "s~␀identifier␀~$ASKIDENTIFIER~g" .blueprint/tmp/init/conf.yml; #IDENTIFIER
  sed -i "s~␀description␀~$ASKDESCRIPTION~g" .blueprint/tmp/init/conf.yml; #DESCRIPTION
  sed -i "s~␀ver␀~$ASKVERSION~g" .blueprint/tmp/init/conf.yml; #VERSION
  sed -i "s~␀author␀~$ASKAUTHOR~g" .blueprint/tmp/init/conf.yml; #AUTHOR

  icnNUM=$(expr 1 + $RANDOM % 6)
  cp .blueprint/assets/defaultExtensionLogo$icnNUM.jpg .blueprint/tmp/init/assets/logo.jpg
  sed -i "s~␀version␀~$VERSION~g" .blueprint/tmp/init/conf.yml

  # Return files to folder.
  log_bright "[INFO] Copying output to dev directory."
  cp -R .blueprint/tmp/init/* .blueprint/dev/

  # Remove tmp files.
  log_bright "[INFO] Purging tmp files."
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  log_green "[SUCCESS] Your extension files have been generated and exported to '.blueprint/dev'."
fi


# -build
if [[ $2 == "-build" ]]; then VCMD="y"
  if [[ $(cat .blueprint/data/internal/db/developer) != "true"* ]]; then quit_red "[FATAL] Developer mode is not enabled.";exit 1;fi

  if [[ ! -n $(find .blueprint/dev -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    quit_red "[FATAL] You do not have any development files."
  fi
  log_bright "[INFO] Installing development extension files.."
  blueprint -i test␀
  log_bright "[INFO] Extension installation ends here, if there are any errors during installation, fix them and try again."
  sendTelemetry "BUILD_DEVELOPMENT_EXTENSION" > /dev/null
fi


# -export
if [[ $2 == "-export" ]]; then VCMD="y"
  if [[ $(cat .blueprint/data/internal/db/developer) != "true"* ]]; then quit_red "[FATAL] Developer mode is not enabled.";exit 1;fi

  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    echo "ok" > /dev/null
  else 
    quit_red "[FATAL] You do not have any development files."
  fi

  log_bright "[INFO] Exporting extension files located in '.blueprint/dev'."

  cd .blueprint
  eval $(parse_yaml dev/conf.yml conf_); identifier="$conf_info_identifier"
  cp -R dev/* tmp/
  cd tmp
  zip -r extension.zip *
  cd $FOLDER
  cp .blueprint/tmp/extension.zip $identifier.blueprint
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  # This will be replaced with a success/fail check in the future.
  log_bright "[INFO] Export finished."
fi


# -rerun-install
if [[ $2 == "-rerun-install"  ]]; then VCMD="y"
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n"
  dbRemove "blueprint.setupFinished"
  cd $FOLDER
  bash blueprint.sh
fi


# -upgrade
if [[ $2 == "-upgrade" ]]; then VCMD="y"
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n"

  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    quit_red "[FATAL] Your development directory contains files. To protect you against accidental data loss, you are unable to upgrade unless you clear your .blueprint/dev folder."
  fi

  if [[ $@ == *"dev"* ]]; then
    log_blue "[INPUT] Upgrading to the latest dev build will update Blueprint to an unstable work-in-progress preview of the next version. Continue? (y/N)"
    read YN1
    if [[ ( $YN1 == "n"* ) || ( $YN1 == "N"* ) || ( $YN1 == "" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi
  fi
  log_blue "[INPUT] Upgrading will wipe your .blueprint folder and will overwrite your extensions. Continue? (y/N)"
  read YN2
  if [[ ( $YN2 == "n"* ) || ( $YN2 == "N"* ) || ( $YN2 == "" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi
  log_blue "[INPUT] This is the last warning before upgrading/wiping Blueprint. Type 'continue' to continue, all other input will be taken as 'no'."
  read YN3
  if [[ $YN3 != "continue" ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi

  log_bright "[INFO] Blueprint is upgrading.. Please do not turn off your machine."
  cp blueprint.sh .blueprint.sh.bak
  if [[ $@ == *"dev"* ]]; then
    bash tools/update.sh $FOLDER dev
  else
    bash tools/update.sh $FOLDER
  fi
  if [[ -n $(find tools/tmp -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    rm -R tools/tmp/*
  fi
  chmod +x blueprint.sh
  _FOLDER="$FOLDER" bash blueprint.sh
  bash blueprint.sh --post-upgrade
  log_bright "[INFO] Bash might spit out some errors from here on out. EOF, command not found and syntax errors are expected behaviour."
  log_blue "[INPUT] Do you want to migrate your database? (Y/n)"
  read YN4
  if [[ ( $YN4 == "y" ) || ( $YN4 == "Y" ) || ( $YN4 == "" ) ]]; then 
    log_bright "[INFO] Running database migrations.."
    php artisan migrate --force
  else
    log_bright "[INFO] Database migrations have been skipped."
  fi

  # Post-upgrade checks.
  log_bright "[INFO] Running post-upgrade checks.."
  score=0

  if dbValidate "blueprint.setupFinished"; then
    score=$((score+1))
  else
    log_yellow "[WARNING] 'blueprint.setupFinished' could not be found."
  fi

  # Finalize upgrade.
  if [[ $score == 1 ]]; then
    log_green "[SUCCESS] Blueprint has upgraded successfully."
    rm .blueprint.sh.bak
    exit 1
  elif [[ $score == 0 ]]; then
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
if [[ $VCMD != "y" && $1 == "-bash" ]]; then
  # This is logged as a "fatal" error since it's something that is making Blueprint run unsuccessfully.
  quit_red "[FATAL] '$2' is not a valid command or argument. Use argument '-help' for a list of commands."
fi
