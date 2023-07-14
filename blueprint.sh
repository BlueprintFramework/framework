#!/bin/bash

# ptero.shop
# github.com/teamblueprint/main
# prpl.wtf

# This should allow Blueprint to run in docker. Please note that changing the $FOLDER variable after running
# the Blueprint installation script will not change anything in any files besides blueprint.sh.
  FOLDER="pterodactyl"

# Check for panels that are using Docker.
if [[ -f ".dockerenv" ]]; then
  DOCKER="y";
  FOLDER="html"
else
  DOCKER="n";
fi;

# If the fallback version below does not match your downloaded version, please let us know.
  VER_FALLBACK="alpha-A9X";

# This will be automatically replaced by some marketplaces, if not, $VER_FALLBACK will be used as fallback.
  PM_VERSION="([(pterodactylmarket_version)])";

if [[ -d "/var/www/$FOLDER/blueprint" ]]; then mv /var/www/$FOLDER/blueprint /var/www/$FOLDER/.blueprint; fi;

if [[ $PM_VERSION == "([(pterodactylmarket""_version)])" ]]; then
  # This runs when the placeholder has not changed, indicating an issue with PterodactylMarket
  # or Blueprint being installed from other sources.
  if [[ ! -f "/var/www/$FOLDER/.blueprint/data/internal/db/version" ]]; then
    sed -E -i "s*&bp.version&*$VER_FALLBACK*g" app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -E -i "s*@version*$VER_FALLBACK*g" public/extensions/blueprint/index.html;
    touch /var/www/$FOLDER/.blueprint/data/internal/db/version;
  fi;
  
  VERSION=$VER_FALLBACK;
elif [[ $PM_VERSION != "([(pterodactylmarket""_version)])" ]]; then
  # This runs in case it is possible to use the PterodactylMarket placeholder instead of the
  # fallback version.
  if [[ ! -f "/var/www/$FOLDER/.blueprint/data/internal/db/version" ]]; then
    sed -E -i "s*&bp.version&*$PM_VERSION*g" app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -E -i "s*@version*$PM_VERSION*g" public/extensions/blueprint/index.html;
    touch /var/www/$FOLDER/.blueprint/data/internal/db/version;
  fi;

  VERSION=$PM_VERSION;
fi;

# Fix for Blueprint's bash database to work with docker and custom folder installations.
sed -i "s!&bp.folder&!$FOLDER!g" /var/www/$FOLDER/.blueprint/lib/db.sh;

cd /var/www/$FOLDER; # Automatically navigate to the Pterodactyl directory when running the script.
# Import libraries.
source .blueprint/lib/bash_colors.sh;
source .blueprint/lib/parse_yaml.sh;
source .blueprint/lib/db.sh;
source .blueprint/lib/telemetry.sh;

# -exec
if [[ "$1" == "-exec" ]]; then

  # Quoteless arguments.
  # There should be an easier way to do this and will be added in the future.
  ql1=$(echo "$1" | tr -d "'\\\n\r;");ql2=$(echo "$2" | tr -d "'\\\n\r;");ql3=$(echo "$3" | tr -d "'\\\n\r;");ql4=$(echo "$4" | tr -d "'\\\n\r;");ql5=$(echo "$5" | tr -d "'\\\n\r;");

  # Update the telemetry id to argument.
  if [[ $ql2 == "key" ]]; then
    echo "$ql3" > .blueprint/data/internal/db/telemetry_id;
    echo Command executed.;
    exit 1;
  fi;

  echo Command not found.;
  exit 1;
fi;

# Function that exits the script after logging a "red" message.
quit_red() {
  log_red "${$1}";
  mkdir .blueprint/tmp > /dev/null;
  exit 1;
};

# Adds the "blueprint" command to the /usr/local/bin directory and configures the correct permissions for it.
touch /usr/local/bin/blueprint > /dev/null;
echo -e "#!/bin/bash\nbash /var/www/$FOLDER/blueprint.sh -bash \$@;" > /usr/local/bin/blueprint;
chmod u+x /var/www/$FOLDER/blueprint.sh > /dev/null;
chmod u+x /usr/local/bin/blueprint > /dev/null;

if [[ $1 != "-bash" ]]; then
  if dbValidate "blueprint.setupFinished"; then
    log_yellow "[WARNING] This command only works if you have yet to install Blueprint. Run 'blueprint (cmd) [arg]' instead.";
    exit 1;
  else
    # Only run if Blueprint is not in the process of upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log "  ██\n██  ██\n  ████\n"; # Blueprint logo made out of unicode icons.
      if [[ $DOCKER == "y" ]]; then
        log_yellow "[WARNING] While running Blueprint with docker is supported, you may run into some issues. Report problems you find at ptero.shop/issue.";
      fi;
    fi;

    # Update folder placeholder on PlaceholderService and admin layout.
    log_bright "[INFO] /var/www/$FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php";
    sed -i "s!&bp.folder&!$FOLDER!g" /var/www/$FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php;
    log_bright "[INFO] /var/www/$FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php";
    sed -i "s!&bp.folder&!$FOLDER!g" /var/www/$FOLDER/resources/views/layouts/admin.blade.php;

    # Copy "Blueprint" extension page logo from assets.
    log_bright "[INFO] cp /var/www/$FOLDER/.blueprint/assets/logo.jpg /var/www/$FOLDER/public/assets/extensions/blueprint/logo.jpg;";
    cp /var/www/$FOLDER/.blueprint/assets/logo.jpg /var/www/$FOLDER/public/assets/extensions/blueprint/logo.jpg;

    # Put application into maintenance.
    log_bright "[INFO] php artisan down";
    php artisan down;

    # Inject custom Blueprint css into Pterodactyl's admin panel.
    log_bright "[INFO] /var/www/$FOLDER/public/themes/pterodactyl/css/pterodactyl.css";
    sed -i "s!@import 'checkbox.css';!@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);\n/* blueprint reserved line */!g" /var/www/$FOLDER/public/themes/pterodactyl/css/pterodactyl.css;


    # Clear view cache.
    log_bright "[INFO] php artisan view:clear";
    php artisan view:clear;


    # Clear PHP config. Not sure what this does yet, but I know it fixes some strange problems.
    log_bright "[INFO] php artisan config:clear";
    php artisan config:clear;


    # Run migrations if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_bright "[INFO] php artisan migrate";
      log_yellow "[WARNING] Answering 'no' or 'n' to the following prompt may result into problems with Blueprint."
      php artisan migrate;
    fi;


    # Make sure all files have correct permissions.
    log_bright "[INFO] chown -R www-data:www-data /var/www/$FOLDER/*";
    chown -R www-data:www-data /var/www/$FOLDER/*;

    # Make sure all .files have the correct permissions as well.
    log_bright "[INFO] chown -R www-data:www-data /var/www/$FOLDER/.*";
    chown -R www-data:www-data /var/www/$FOLDER/.*;

    # Remove placeholder README.md files.
    log_bright "[INFO] rm -R /var/www/$FOLDER/.blueprint/dev/*";
    rm -R /var/www/$FOLDER/.blueprint/dev/*;
    log_bright "[INFO] rm -R /var/www/$FOLDER/.blueprint/data/extensions/*";
    rm -R /var/www/$FOLDER/.blueprint/data/extensions/*;
    log_bright "[INFO] rm /var/www/$FOLDER/tools/tmp/README.md";
    rm /var/www/$FOLDER/tools/tmp/README.md > /dev/null;

    # Put application into production.
    log_bright "[INFO] php artisan up";
    php artisan up;

    # Only show donate + success message if Blueprint is not upgrading.
    if [[ $1 != "--post-upgrade" ]]; then
      log_bright "[INFO] Blueprint is completely open source and free. Please consider supporting us on \"ptero.shop/donate\".";
      sleep 2;
      log_green "\n\n[SUCCESS] Blueprint should now be installed. If something didn't work as expected, please let us know at ptero.shop/issue.";
    fi;

    dbAdd "blueprint.setupFinished";
    # Let the panel know the user has finished installation.
    sed -i "s!NOTINSTALLED!INSTALLED!g" /var/www/$FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php;
    exit 1;
  fi;
fi;

# -i, -install
if [[ ( $2 == "-i" ) || ( $2 == "-install" ) ]]; then
  if [[ $(expr $# - 2) != 1 ]]; then quit_red "[FATAL] Expected 1 argument but got $(expr $# - 2).";fi;
  if [[ $3 == "test␀" ]]; then
    dev=true;
    n="dev";
    mkdir .blueprint/tmp/dev;
    cp -R .blueprint/dev/* .blueprint/tmp/dev/;
  else
    dev=false;
    n=$3;
    FILE=$n".blueprint";
    if [[ ! -f "$FILE" ]]; then quit_red "[FATAL] $FILE could not be found.";fi;

    ZIP=$n".zip";
    cp $FILE .blueprint/tmp/$ZIP;
    cd .blueprint/tmp;
    unzip $ZIP;
    rm $ZIP;
    if [[ ! -f "$n/*" ]]; then
      cd ..;
      rm -R tmp;
      mkdir tmp;
      cd tmp;

      mkdir ./$n;
      cp ../../$FILE ./$n/$ZIP;
      cd $n;
      unzip $ZIP;
      rm $ZIP;
      cd ..;
    fi;
  fi;

  # Return to the Pterodactyl installation folder.
  cd /var/www/$FOLDER;

  # Get all strings from the conf.yml file and make them accessible as variables.
  eval $(parse_yaml .blueprint/tmp/$n/conf.yml conf_)

  # Add aliases for config values to make working with them easier.
  name=$conf_info_name;
  identifier=$conf_info_identifier;
  description=$conf_info_description;
  flags=$conf_info_flags;
  version=$conf_info_version;
  target=$conf_info_target;
  author=$conf_info_author;
  icon=$conf_info_icon;
  website=$conf_info_website; #(optional)

  admin_view=$conf_admin_view;
  admin_controller=$conf_admin_controller; #(optional)
  admin_css=$conf_admin_css; #(optional)

  dashboard_wrapper=$conf_dashboard_wrapper; #(optional)

  data_directory=$conf_data_directory; #(optional)
  data_public=$conf_data_public; #(optional)

  database_migrations=$conf_database_migrations; #(optional)

  if [[ ( $icon == "/"*                ) || ( $icon == "."*                ) || ( $icon == *"\n"*                ) ]] ||
     [[ ( $admin_view == "/"*          ) || ( $admin_view == "."*          ) || ( $admin_view == *"\n"*          ) ]] ||
     [[ ( $admin_controller == "/"*    ) || ( $admin_controller == "."*    ) || ( $admin_controller == *"\n"*    ) ]] ||
     [[ ( $admin_css == "/"*           ) || ( $admin_css == "."*           ) || ( $admin_css == *"\n"*           ) ]] ||
     [[ ( $data_directory == "/"*      ) || ( $data_directory == "."*      ) || ( $data_directory == *"\n"*      ) ]] ||
     [[ ( $data_public == "/"*         ) || ( $data_public == "."*         ) || ( $data_public == *"\n"*         ) ]] ||
     [[ ( $database_migrations == "/"* ) || ( $database_migrations == "."* ) || ( $database_migrations == *"\n"* ) ]]; then
    rm -R .blueprint/tmp/$n;
    quit_red "[FATAL] Extension has failed security checks, halting installation.";
  fi;

  if [[ $website != "" ]]; then
    if [[ $website != "https://"* ]]; then
      if [[ $website != "http://"* ]]; then
        website="http://"$info_website;
      fi;
    fi;
  fi;

  if [[ $dev == true ]]; then
    mv .blueprint/tmp/$n .blueprint/tmp/$identifier;
    n=$identifier;
  fi;

  if [[ ( $flags != *"ignorePlaceholders,"* ) && ( $flags != *"ignorePlaceholders" ) ]]; then
    DIR=.blueprint/tmp/$n/*;

    if [[ ( $flags == *"ignoreAlphabetPlaceholders,"* ) || ( $flags == *"ignoreAlphabetPlaceholders" ) ]]; then
      SKIPAZPLACEHOLDERS=true;
      log_bright "[INFO] Alphabet placeholders will be skipped due to the 'ignoreAlphabetPlaceholders' flag.";
    else
      SKIPAZPLACEHOLDERS=false;
    fi;

    for f in $(find $DIR -type f -exec echo {} \;); do
      sed -i "s~\^#version#\^~$version~g" $f;
      sed -i "s~\^#author#\^~$author~g" $f;
      sed -i "s~\^#identifier#\^~$identifier~g" $f;
      sed -i "s~\^#path#\^~/var/www/$FOLDER~g" $f;
      sed -i "s~\^#datapath#\^~/var/www/$FOLDER/.blueprint/data/extensions/$identifier~g" $f;

      if [[ $SKIPAZPLACEHOLDERS != true ]]; then
        sed -i "s~__version__~$version~g" $f;
        sed -i "s~__author__~$author~g" $f;
        sed -i "s~__identifier__~$identifier~g" $f;
        sed -i "s~__path__~/var/www/$FOLDER~g" $f;
        sed -i "s~__datapath__~/var/www/$FOLDER/.blueprint/data/extensions/$identifier~g" $f;
      fi;

      log_bright "[INFO] Done placeholders in '$f'.";
    done;

  else log_bright "[INFO] Placeholders will be skipped due to the 'ignorePlaceholders' flag."; fi;

  if [[ $name == "" ]]; then rm -R .blueprint/tmp/$n;                 quit_red "[FATAL] 'info_name' is a required configuration option.";fi;
  if [[ $identifier == "" ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] 'info_identifier' is a required configuration option.";fi;
  if [[ $description == "" ]]; then rm -R .blueprint/tmp/$n;          quit_red "[FATAL] 'info_description' is a required configuration option.";fi;
  if [[ $version == "" ]]; then rm -R .blueprint/tmp/$n;              quit_red "[FATAL] 'info_version' is a required configuration option.";fi;
  if [[ $target == "" ]]; then rm -R .blueprint/tmp/$n;               quit_red "[FATAL] 'info_target' is a required configuration option.";fi;
  if [[ $icon == "" ]]; then rm -R .blueprint/tmp/$n;                 quit_red "[FATAL] 'info_icon' is a required configuration option.";fi;

  if [[ $admin_controller == "" ]]; then                            log_bright "[INFO] Admin controller field left blank, using default controller instead..";
    controller_type="default";else controller_type="custom";fi;
  if [[ $admin_view == "" ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] 'admin_view' is a required configuration option.";fi;
  if [[ $target != $VERSION ]]; then                                log_yellow "[WARNING] This extension is built for version $target, but your version is $VERSION.";fi;
  if [[ $identifier != $n ]]; then rm -R .blueprint/tmp/$n;           quit_red "[FATAL] The extension file name must be the same as your identifier. (example: identifier.blueprint)";fi;
  if [[ $identifier == "blueprint" ]]; then rm -R .blueprint/tmp/$n;  quit_red "[FATAL] Extensions can not have the identifier 'blueprint'.";fi;

  if [[ $identifier =~ [a-z] ]]; then                               log_bright "[INFO] Identifier a-z checks passed.";
  else rm -R .blueprint/tmp/$n;                                       quit_red "[FATAL] The extension identifier should be lowercase and only contain characters a-z.";fi;
  if [[ ! -f ".blueprint/tmp/$n/$icon" ]]; then
    rm -R .blueprint/tmp/$n;                                          quit_red "[FATAL] The 'info_icon' path points to a file that does not exist.";fi;

  if [[ $database_migrations != "" ]]; then
    cp -R .blueprint/tmp/$n/$database_migrations/* database/migrations/ 2> /dev/null;
  fi;

  if [[ $css != "" ]]; then
    INJECTCSS="y";
  fi;

  if [[ $admin_requests != "" ]]; then
    log_yellow "[WARNING] Admin requests are deprecated. Use them in your controller instead.";
  fi;

  if [[ $data_public != "" ]]; then
    mkdir public/extensions/$identifier;
    cp -R .blueprint/tmp/$n/$data_public/* public/extensions/$identifier/ 2> /dev/null;
  fi;

  cp -R .blueprint/data/internal/build/extensions/admin.blade.php .blueprint/data/internal/build/extensions/admin.blade.php.bak 2> /dev/null;
  if [[ $admin_controller == "" ]]; then # use default controller when admin_controller is left blank
    cp -R .blueprint/data/internal/build/extensions/controller.php .blueprint/data/internal/build/extensions/controller.php.bak 2> /dev/null;
  fi;
  cp -R .blueprint/data/internal/build/extensions/route.php .blueprint/data/internal/build/extensions/route.php.bak 2> /dev/null;
  cp -R .blueprint/data/internal/build/extensions/button.blade.php .blueprint/data/internal/build/extensions/button.blade.php.bak 2> /dev/null;

  # Start creating data directory.
  mkdir .blueprint/data/extensions/$identifier;
  mkdir .blueprint/data/extensions/$identifier/.store;
  
  cp .blueprint/tmp/$n/conf.yml .blueprint/data/extensions/$identifier/.store/conf.yml; #backup conf.yml
  
  if [[ $data_directory != "" ]]; then
    cp -R .blueprint/tmp/$n/$data_directory/* .blueprint/data/extensions/$identifier/;
  fi;
  # End creating data directory.

  mkdir public/assets/extensions/$identifier;
  cp .blueprint/tmp/$n/$icon public/assets/extensions/$identifier/icon.jpg;
  ICON="/assets/extensions/$identifier/icon.jpg";
  CONTENT=$(cat .blueprint/tmp/$n/$admin_view);

  if [[ $INJECTCSS == "y" ]]; then
    sed -i "s!/* blueprint reserved line */!/* blueprint reserved line */\n@import url(/assets/extensions/$identifier/$identifier.style.css);!g" public/themes/pterodactyl/css/pterodactyl.css;
    cp -R .blueprint/tmp/$n/$css/* public/assets/extensions/$identifier/$identifier.style.css 2> /dev/null;
  fi;

  if [[ $name == *"~"* ]]; then log_yellow "[WARNING] 'name' contains '~' and may result in an error.";fi;
  if [[ $description == *"~"* ]]; then log_yellow "[WARNING] 'description' contains '~' and may result in an error.";fi;
  if [[ $version == *"~"* ]]; then log_yellow "[WARNING] 'version' contains '~' and may result in an error.";fi;
  if [[ $CONTENT == *"~"* ]]; then log_yellow "[WARNING] 'CONTENT' contains '~' and may result in an error.";fi;
  if [[ $ICON == *"~"* ]]; then log_yellow "[WARNING] 'ICON' contains '~' and may result in an error.";fi;
  if [[ $identifier == *"~"* ]]; then log_yellow "[WARNING] 'identifier' contains '~' and may result in an error.";fi;

  sed -i "s~␀title␀~$name~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
  sed -i "s~␀name␀~$name~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
  sed -i "s~␀name␀~$name~g" .blueprint/data/internal/build/extensions/button.blade.php.bak;

  sed -i "s~␀description␀~$description~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;

  sed -i "s~␀version␀~$version~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
  sed -i "s~␀version␀~$version~g" .blueprint/data/internal/build/extensions/button.blade.php.bak;

  sed -i "s~␀icon␀~$ICON~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;

  if [[ $website != "" ]]; then
    sed -i "s~␀website␀~$website~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
    sed -i "s~<!--websitecomment␀ ~~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
    sed -i "s~ ␀websitecomment-->~~g" .blueprint/data/internal/build/extensions/admin.blade.php.bak;
  fi;

  echo -e "$CONTENT\n@endsection" >> .blueprint/data/internal/build/extensions/admin.blade.php.bak;


  if [[ $admin_controller == "" ]]; then
    sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/controller.php.bak;
  fi;
  sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/route.php.bak;
  sed -i "s~␀id␀~$identifier~g" .blueprint/data/internal/build/extensions/button.blade.php.bak;

  ADMINVIEW_RESULT=$(cat .blueprint/data/internal/build/extensions/admin.blade.php.bak);
  ADMINROUTE_RESULT=$(cat .blueprint/data/internal/build/extensions/route.php.bak);
  ADMINBUTTON_RESULT=$(cat .blueprint/data/internal/build/extensions/button.blade.php.bak);
  if [[ $admin_controller == "" ]]; then
    ADMINCONTROLLER_RESULT=$(cat .blueprint/data/internal/build/extensions/controller.php.bak);
  fi;
  ADMINCONTROLLER_NAME=$identifier"ExtensionController.php";

  mkdir resources/views/admin/extensions/$identifier;
  touch resources/views/admin/extensions/$identifier/index.blade.php;
  echo $ADMINVIEW_RESULT > resources/views/admin/extensions/$identifier/index.blade.php;

  mkdir app/Http/Controllers/Admin/Extensions/$identifier;
  touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;

  if [[ $admin_controller == "" ]]; then
    touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
    echo $ADMINCONTROLLER_RESULT > app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
  else
    cp .blueprint/tmp/$n/$admin_controller app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
  fi;

  echo $ADMINROUTE_RESULT >> routes/admin.php;

  sed -i "s~<!--␀replace␀-->~$ADMINBUTTON_RESULT\n<!--␀replace␀-->~g" resources/views/admin/extensions.blade.php;

  # insert "dashboard_wrapper" into wrapper.blade.php
  if [[ $dashboard_wrapper != "" ]]; then
    cp .blueprint/tmp/$n/$dashboard_wrapper .blueprint/tmp/$n/$dashboard_wrapper.bak;
    sed -i '/<!-- dashboard:header-bottom -->/r .blueprint/tmp/'"$n"'/'"$dashboard_wrapper.bak"'\' resources/views/templates/wrapper.blade.php;
  fi;

  rm .blueprint/data/internal/build/extensions/admin.blade.php.bak;
  if [[ $admin_controller == "" ]]; then
    rm .blueprint/data/internal/build/extensions/controller.php.bak;
  fi;
  rm .blueprint/data/internal/build/extensions/route.php.bak;
  rm .blueprint/data/internal/build/extensions/button.blade.php.bak;
  rm -R .blueprint/tmp/$n;

  if [[ $database_migrations != "" ]]; then
    log_bright "[INFO] This extension comes with migrations. If you get prompted, answer 'yes'.\n";
    php artisan migrate;
  fi;

  chmod -R +x .blueprint/data/extensions/$identifier/*;

  if [[ ( $flags == *"hasInstallScript,"* ) || ( $flags == *"hasInstallScript" ) ]]; then
    log_yellow "[WARNING] This extension uses a custom installation script, proceed with caution.";
    bash .blueprint/data/extensions/$identifier/install.sh;
  fi;

  log_green "\n\n[SUCCESS] $identifier should now be installed. If something didn't work as expected, please let us know at ptero.shop/issue.";
  if [[ $dev == false ]]; then
    sendTelemetry "FINISH_EXTENSION_INSTALLATION" > /dev/null;
  fi;
fi;

# help, -help, --help 
if [[ ( $2 == "help" ) || ( $2 == "-help" ) || ( $2 == "--help" ) ]]; then
   echo -e " -install [name]          install a blueprint extension""
"           "-version                 get the current blueprint version""
"           "-init                    initialize extension development files""
"           "-build                   run an installation on your extension development files""
"           "-export                  export your extension development files""
"           "-runinstall              rerun the blueprint installation script (advanced)""
"           "-upgrade (dev)           update/reset to a newer pre-release version (advanced)";
fi;

# -v, -version
if [[ ( $2 == "-v" ) || ( $2 == "-version" ) ]]; then
  echo -e $VERSION;
fi;

# -init
if [[ $2 == "-init" ]]; then

  ask_name() {
    log_blue "[INPUT] Name (Generic Extension):";
    read ASKNAME;

    REDO_NAME=false;

    # Name should not be empty
    if [[ $ASKNAME == "" ]]; then 
      log_red "[FATAL] Name should not be empty.";
      REDO_NAME=true;
    fi;

    if [[ $REDO_NAME == true ]]; then
      ask_name;
    fi;
  };

  ask_identifier() {
    log_blue "[INPUT] Identifier (genericextension):";
    read ASKIDENTIFIER;

    REDO_IDENTIFIER=false;

    # Identifier should not be empty
    if [[ $ASKIDENTIFIER == "" ]]; then
      log_red "[FATAL] Identifier should not be empty.";
      REDO_IDENTIFIER=true;
    fi;
  
    # Identifier should be a-z.
    if [[ $ASKIDENTIFIER =~ [a-z] ]]; then
      echo ok > /dev/null;
    else 
      log_red "[FATAL] Identifier should only contain a-z characters.";
      REDO_IDENTIFIER=true;
    fi;

    if [[ $REDO_IDENTIFIER == true ]]; then
      ask_identifier;
    fi;
  };

  ask_description() {
    log_blue "[INFO] Description (My awesome description):";
    read ASKDESCRIPTION;

    REDO_DESCRIPTION=false;

    # Description should not be empty
    if [[ $ASKDESCRIPTION == "" ]]; then
      log_red "[FATAL] Description should not be empty.";
      REDO_DESCRIPTION=true;
    fi;

    if [[ $REDO_DESCRIPTION == true ]]; then
      ask_description;
    fi;
  };

  ask_version() {
    log_blue "[INPUT] Version (indev):";
    read ASKVERSION;

    REDO_VERSION=false;

    # Version should not be empty
    if [[ $ASKVERSION == "" ]]; then
      log_red "[FATAL] Version should not be empty.";
      REDO_VERSION=true;
    fi;

    if [[ $REDO_VERSION == true ]]; then
      ask_version;
    fi;
  };

  ask_author() {
    log_blue "[INPUT] Author (prplwtf):";
    read ASKAUTHOR;

    REDO_AUTHOR=false;

    # Author should not be empty
    if [[ $ASKAUTHOR == "" ]]; then
      log_red "[FATAL] Author should not be empty.";
      REDO_AUTHOR=true;
    fi;

    if [[ $REDO_AUTHOR == true ]]; then
      ask_author;
    fi;
  };

  ask_name;
  ask_identifier;
  ask_description;
  ask_version;
  ask_author;

  log_bright "[INFO] Copying init defaults to tmp directory..";
  mkdir .blueprint/tmp/init;
  cp -R .blueprint/data/internal/build/init/* .blueprint/tmp/init/;

  log_bright "[INFO] Applying variables.."
  sed -i "s~␀name␀~$ASKNAME~g" .blueprint/tmp/init/conf.yml; #NAME
  sed -i "s~␀identifier␀~$ASKIDENTIFIER~g" .blueprint/tmp/init/conf.yml; #IDENTIFIER
  sed -i "s~␀description␀~$ASKDESCRIPTION~g" .blueprint/tmp/init/conf.yml; #DESCRIPTION
  sed -i "s~␀ver␀~$ASKVERSION~g" .blueprint/tmp/init/conf.yml; #VERSION
  sed -i "s~␀author␀~$ASKAUTHOR~g" .blueprint/tmp/init/conf.yml; #AUTHOR

  icnNUM=$(expr 1 + $RANDOM % 4);
  sed -i "s~␀num␀~$icnNUM~g" .blueprint/tmp/init/conf.yml;
  sed -i "s~␀version␀~$VERSION~g" .blueprint/tmp/init/conf.yml;

  # Return files to folder.
  log_bright "[INFO] Copying output to dev directory."
  cp -R .blueprint/tmp/init/* .blueprint/dev/;

  # Remove tmp files.
  log_bright "[INFO] Purging tmp files."
  rm -R .blueprint/tmp;
  mkdir .blueprint/tmp;

  log_green "[SUCCESS] Your extension files have been generated and exported to '.blueprint/dev'.";
fi;

# -build
if [[ $2 == "-build" ]]; then
  log_bright "[INFO] Installing development extension files..";
  blueprint -i test␀;
  log_bright "[INFO] Extension installation ends here, if there are any errors during installation, fix them and try again.";
  sendTelemetry "BUILD_DEVELOPMENT_EXTENSION" > /dev/null;
fi;

# -export
if [[ $2 == "-export" ]]; then
  log_bright "[INFO] Exporting extension files located in '.blueprint/dev'.";

  cd .blueprint
  eval $(parse_yaml dev/conf.yml conf_); identifier=$conf_info_identifier;
  cp -R dev/* tmp/;
  cd tmp;
  zip -r extension.zip *;
  cd /var/www/$FOLDER;
  cp .blueprint/tmp/extension.zip $identifier.blueprint;
  rm -R .blueprint/tmp;
  mkdir .blueprint/tmp;

  # This will be replaced with a success/fail check in the future.
  log_bright "[INFO] Export finished.";
fi;

# -runinstall
if [[ $2 == "-runinstall"  ]]; then
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n"
  dbRemove "blueprint.setupFinished";
  cd /var/www/$FOLDER;
  bash blueprint.sh;
fi;

# -upgrade
if [[ $2 == "-upgrade" ]]; then
  log_yellow "[WARNING] This is an advanced feature, only proceed if you know what you are doing.\n";

  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name "README.md" -print -quit) ]]; then
    quit_red "[FATAL] Your development directory contains files. To protect you against accidental data loss, you are unable to upgrade unless you clear your .blueprint/dev folder.";
  fi;

  if [[ $3 == "dev" ]]; then
    log_blue "[INPUT] Upgrading to the latest dev build will update Blueprint to an unstable work-in-progress preview of the next version. Continue? (y/N)";
    read YN1;
    if [[ ( $YN1 != "y" ) && ( $YN1 != "Y" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;
  fi;
  log_blue "[INPUT] Upgrading will wipe your .blueprint folder and will overwrite your extensions. Continue? (y/N)";
  read YN2;
  if [[ ( $YN2 != "y" ) && ( $YN2 != "Y" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;
  log_blue "[INPUT] This is the last warning before upgrading/wiping Blueprint. Type 'continue' to continue, all other input will be taken as 'no'.";
  read YN3;
  if [[ $YN3 != "continue" ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;

  log_bright "[INFO] Blueprint is upgrading.. Please do not turn off your machine.";
  cp blueprint.sh .blueprint.sh.bak;
  if [[ $3 == "dev" ]]; then
    bash tools/update.sh /var/www/$FOLDER dev
  else
    bash tools/update.sh /var/www/$FOLDER
  fi;
  rm -R tools/tmp/*;
  log_bright "[INFO] Files have been upgraded, running installation script..";
  chmod +x blueprint.sh;
  bash blueprint.sh --post-upgrade;
  log_bright "[INFO] Bash might spit out some errors from here on out. EOF, command not found and syntax errors are expected behaviour.";
  log_blue "[INPUT] Database migrations are skipped when upgrading, run them anyways? (Y/n)";
  read YN4;
  if [[ ( $YN4 == "y" ) || ( $YN4 == "Y" ) ]]; then 
    log_bright "[INFO] Running database migrations..";
    php artisan migrate;
  else
    log_bright "[INFO] Database migrations have been skipped.";
  fi;

  log_bright "[INFO] Running post-upgrade checks..";
  score=0;

  if dbValidate "blueprint.setupFinished"; then
    score=$((score+1));
  else
    log_yellow "[WARNING] 'blueprint.setupFinished' could not be found.";
  fi;

  if [[ $score == 1 ]]; then
    log_green "[SUCCESS] Blueprint has upgraded successfully.";
    rm .blueprint.sh.bak;
    exit 1;
  elif [[ $score == 0 ]]; then
    log_red "[FATAL] All checks have failed.";
    rm blueprint.sh;
    mv .blueprint.sh.bak;
    exit 1;
  else
    log_yellow "[WARNING] Some post-upgrade checks have failed.";
    rm blueprint.sh;
    mv .blueprint.sh.bak;
    exit 1;
  fi;
fi;
