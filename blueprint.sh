#!/bin/bash

# ptero.shop
# github.com/teamblueprint/main
# prpl.wtf

# This should allow Blueprint to run in docker. Please note that changing the $FOLDER variable after running
# the Blueprint installation script will not change anything in any files besides blueprint.sh.
  FOLDER="pterodactyl"

if [[ -f ".dockerenv" ]]; then
  DOCKER="y";
  FOLDER="html"
fi;

# If the fallback version below does not match your downloaded version, please let us know.
  VER_FALLBACK="alpha-5KB";

# This will be automatically replaced by some marketplaces, if not, $VER_FALLBACK will be used as fallback.
  PM_VERSION="([(pterodactylmarket_version)])";

if [[ -d "/var/www/$FOLDER/blueprint" ]]; then mv /var/www/$FOLDER/blueprint /var/www/$FOLDER/.blueprint; fi;

if [[ $PM_VERSION == "([(pterodactylmarket""_version)])" ]]; then
  # This runs when the placeholder has not changed, indicating an issue with PterodactylMarket
  # or Blueprint being installed from other sources.
  if [[ ! -f "/var/www/$FOLDER/.blueprint/.storage/versionschemefix.flag" ]]; then
    sed -E -i "s*&bp.version&*$VER_FALLBACK*g" app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -E -i "s*@version*$VER_FALLBACK*g" public/extensions/blueprint/index.html;
    touch /var/www/$FOLDER/.blueprint/.storage/versionschemefix.flag;
  fi;
  
  VERSION=$VER_FALLBACK;
elif [[ $PM_VERSION != "([(pterodactylmarket""_version)])" ]]; then
  # This runs in case it is possible to use the PterodactylMarket placeholder instead of the
  # fallback version.
  if [[ ! -f "/var/www/$FOLDER/.blueprint/.storage/versionschemefix.flag" ]]; then
    sed -E -i "s*&bp.version&*$PM_VERSION*g" app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -E -i "s*@version*$PM_VERSION*g" public/extensions/blueprint/index.html;
    touch /var/www/$FOLDER/.blueprint/.storage/versionschemefix.flag;
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
if [[ "$1" == *"-exec"* ]]; then
  # Update the telemetry id to argument.
  if [[ $2 == "key" ]]; then
    echo "$3" > .blueprint/.storage/telemetry_id;
  fi;
  exit 1;
fi;

# Function that exits the script after logging a "red" message.
quit_red() {
  log_red "${1}";
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
      log "  ██\n██  ██\n  ████\n";
      if [[ $DOCKER == "y" ]]; then
        log_yellow "[WARNING] While running Blueprint with docker is supported, you may run into some issues. Report problems you find at ptero.shop/issue.";
      fi;
    fi;

    # Update folder placeholder on PlaceholderService and admin layout.
    sed -i "s!&bp.folder&!$FOLDER!g" /var/www/$FOLDER/app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -i "s!&bp.folder&!$FOLDER!g" /var/www/$FOLDER/resources/views/layouts/admin.blade.php;

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

    # Remove placeholder .hello.txt file in .development.
    log_bright "[INFO] rm .blueprint/.development/.hello.txt";
    rm .blueprint/.development/.hello.txt;

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
    mkdir .blueprint/.storage/tmp/dev;
    cp -R .blueprint/.development/* .blueprint/.storage/tmp/dev/;
  else
    dev=false;
    n=$3;
    FILE=$n".blueprint"
    if [[ ! -f "$FILE" ]]; then quit_red "[FATAL] $FILE could not be found.";fi;

    ZIP=$n".zip";
    cp $FILE .blueprint/.storage/tmp/$ZIP;
    cd .blueprint/.storage/tmp;
    unzip $ZIP;
    rm $ZIP;
    if [[ ! -f "$n/*" ]]; then
      cd ..;
      rm -R tmp;
      mkdir tmp;
      cd tmp;

      mkdir ./$n;
      cp ../../../$FILE ./$n/$ZIP;
      cd $n;
      unzip $ZIP;
      rm $ZIP;
      cd ..;
    fi;
  fi;

  # Return to the Pterodactyl installation folder.
  cd /var/www/$FOLDER;

  # Get all strings from the conf.yml file and make them accessible as variables.
  eval $(parse_yaml .blueprint/.storage/tmp/$n/conf.yml)

  # Add aliases for the info config values to make working with them easier.
  name=$info_name;
  identifier=$info_identifier;
  description=$info_description;
  flags=$info_flags;
  version=$info_version;
  target=$info_target;
  author=$info_author;
  icon=$info_icon;
  website=$info_website;# (optional)

  if [[ $website != "" ]]; then
    if [[ $website != "https://"* ]]; then
      if [[ $website != "http://"* ]]; then
        website="http://"$info_website;
      fi;
    fi;
  fi;

  if [[ $dev ]]; then
    mv .blueprint/.storage/tmp/$n .blueprint/.storage/tmp/$identifier;
    n=$identifier;
  fi;

  if [[ $flags != *"-placeholders.skip;"* ]]; then
    DIR=.blueprint/.storage/tmp/$n/*;

    if [[ $flags == *"-disable_az_placeholders;"* ]]; then
      SKIPAZPLACEHOLDERS=true;
      log_bright "[INFO] A-Z placeholders will be skipped due to the '-disable_az_placeholders;' flag.";
    else
      SKIPAZPLACEHOLDERS=false;
    fi;

    for f in $(find $DIR -type f -exec echo {} \;); do
      sed -i "s~\^#version#\^~$version~g" $f;
      sed -i "s~\^#author#\^~$author~g" $f;
      sed -i "s~\^#identifier#\^~$identifier~g" $f;
      sed -i "s~\^#path#\^~/var/www/$FOLDER~g" $f;
      sed -i "s~\^#datapath#\^~/var/www/$FOLDER/.blueprint/.storage/extensiondata/$identifier~g" $f;

      if [[ $SKIPAZPLACEHOLDERS != true ]]; then
        sed -i "s~bpversionreplace~$version~g" $f;
        sed -i "s~bpauthorreplace~$author~g" $f;
        sed -i "s~bpidentifierreplace~$identifier~g" $f;
        sed -i "s~bppathreplace~/var/www/$FOLDER~g" $f;
        sed -i "s~bpdatapathreplace~/var/www/$FOLDER/.blueprint/.storage/extensiondata/$identifier~g" $f;
      fi;

      log_bright "[INFO] Done placeholders in '$f'.";
    done;

  else log_bright "[INFO] Placeholders will be skipped due to the '-placeholders.skip;' flag."; fi;

  if [[ $name == "" ]]; then rm -R .blueprint/.storage/tmp/$n;                 quit_red "[FATAL] 'info_name' is a required configuration option.";fi;
  if [[ $identifier == "" ]]; then rm -R .blueprint/.storage/tmp/$n;           quit_red "[FATAL] 'info_identifier' is a required configuration option.";fi;
  if [[ $description == "" ]]; then rm -R .blueprint/.storage/tmp/$n;          quit_red "[FATAL] 'info_description' is a required configuration option.";fi;
  if [[ $version == "" ]]; then rm -R .blueprint/.storage/tmp/$n;              quit_red "[FATAL] 'info_version' is a required configuration option.";fi;
  if [[ $target == "" ]]; then rm -R .blueprint/.storage/tmp/$n;               quit_red "[FATAL] 'info_target' is a required configuration option.";fi;
  if [[ $icon == "" ]]; then rm -R .blueprint/.storage/tmp/$n;                 quit_red "[FATAL] 'info_icon' is a required configuration option.";fi;

  if [[ $admin_controller == "" ]]; then                                     log_bright "[INFO] Admin controller field left blank, using default controller instead..";
    controller_type="default";else controller_type="custom";fi;
  if [[ $admin_view == "" ]]; then rm -R .blueprint/.storage/tmp/$n;           quit_red "[FATAL] 'admin_view' is a required configuration option.";fi;
  if [[ $target != $VERSION ]]; then                                         log_yellow "[WARNING] This extension is built for version $target, but your version is $VERSION.";fi;
  if [[ $identifier != $n ]]; then rm -R .blueprint/.storage/tmp/$n;           quit_red "[FATAL] The extension file name must be the same as your identifier. (example: identifier.blueprint)";fi;
  if [[ $identifier == "blueprint" ]]; then rm -R .blueprint/.storage/tmp/$n;  quit_red "[FATAL] Extensions can not have the identifier 'blueprint'.";fi;

  if [[ $identifier =~ [a-z] ]]; then                                        log_bright "[INFO] Identifier a-z checks passed.";
  else rm -R .blueprint/.storage/tmp/$n;                                       quit_red "[FATAL] The extension identifier should be lowercase and only contain characters a-z.";fi;
  if [[ ! -f ".blueprint/.storage/tmp/$n/$icon" ]]; then
    rm -R .blueprint/.storage/tmp/$n;                                          quit_red "[FATAL] The 'info_icon' path points to a file that does not exist.";fi;

  if [[ $database_migrations != "" ]]; then
    cp -R .blueprint/.storage/tmp/$n/$database_migrations/* database/migrations/ 2> /dev/null;
  fi;

  if [[ $css != "" ]]; then
    INJECTCSS="y";
  fi;

  if [[ $admin_requests != "" ]]; then
    mkdir app/Http/Requests/Admin/Extensions/$identifier;
    cp -R .blueprint/.storage/tmp/$n/$admin_requests/* app/Http/Requests/Admin/Extensions/$identifier/ 2> /dev/null;
  fi;

  if [[ $data_public != "" ]]; then
    mkdir public/extensions/$identifier;
    cp -R .blueprint/.storage/tmp/$n/$data_public/* public/extensions/$identifier/ 2> /dev/null;
  fi;

  cp -R .blueprint/.storage/defaults/extensions/admin.default .blueprint/.storage/defaults/extensions/admin.default.bak 2> /dev/null;
  if [[ $admin_controller == "" ]]; then # use default controller when admin_controller is left blank
    cp -R .blueprint/.storage/defaults/extensions/controller.default .blueprint/.storage/defaults/extensions/controller.default.bak 2> /dev/null;
  fi;
  cp -R .blueprint/.storage/defaults/extensions/route.default .blueprint/.storage/defaults/extensions/route.default.bak 2> /dev/null;
  cp -R .blueprint/.storage/defaults/extensions/button.default .blueprint/.storage/defaults/extensions/button.default.bak 2> /dev/null;

  mkdir .blueprint/.storage/extensiondata/$identifier;
  if [[ $data_directory != "" ]]; then
    cp -R .blueprint/.storage/tmp/$n/$data_directory/* .blueprint/.storage/extensiondata/$identifier/;
  fi;

  mkdir public/assets/extensions/$identifier;
  cp .blueprint/.storage/tmp/$n/$icon public/assets/extensions/$identifier/icon.jpg;
  ICON="/assets/extensions/$identifier/icon.jpg";
  CONTENT=$(cat .blueprint/.storage/tmp/$n/$admin_view);

  if [[ $INJECTCSS == "y" ]]; then
    sed -i "s!/* blueprint reserved line */!/* blueprint reserved line */\n@import url(/assets/extensions/$identifier/$identifier.style.css);!g" public/themes/pterodactyl/css/pterodactyl.css;
    cp -R .blueprint/.storage/tmp/$n/$css/* public/assets/extensions/$identifier/$identifier.style.css 2> /dev/null;
  fi;

  if [[ $name == *"~"* ]]; then log_yellow "[WARNING] 'name' contains '~' and may result in an error.";fi;
  if [[ $description == *"~"* ]]; then log_yellow "[WARNING] 'description' contains '~' and may result in an error.";fi;
  if [[ $version == *"~"* ]]; then log_yellow "[WARNING] 'version' contains '~' and may result in an error.";fi;
  if [[ $CONTENT == *"~"* ]]; then log_yellow "[WARNING] 'CONTENT' contains '~' and may result in an error.";fi;
  if [[ $ICON == *"~"* ]]; then log_yellow "[WARNING] 'ICON' contains '~' and may result in an error.";fi;
  if [[ $identifier == *"~"* ]]; then log_yellow "[WARNING] 'identifier' contains '~' and may result in an error.";fi;

  sed -i "s~␀title␀~$name~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
  sed -i "s~␀name␀~$name~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
  sed -i "s~␀name␀~$name~g" .blueprint/.storage/defaults/extensions/button.default.bak;

  sed -i "s~␀description␀~$description~g" .blueprint/.storage/defaults/extensions/admin.default.bak;

  sed -i "s~␀version␀~$version~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
  sed -i "s~␀version␀~$version~g" .blueprint/.storage/defaults/extensions/button.default.bak;

  sed -i "s~␀icon␀~$ICON~g" .blueprint/.storage/defaults/extensions/admin.default.bak;

  if [[ $website != "" ]]; then
    sed -i "s~␀website␀~$website~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
    sed -i "s~<!--websitecomment␀ ~~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
    sed -i "s~ ␀websitecomment-->~~g" .blueprint/.storage/defaults/extensions/admin.default.bak;
  fi;

  echo -e "$CONTENT\n@endsection" >> .blueprint/.storage/defaults/extensions/admin.default.bak;


  if [[ $admin_controller == "" ]]; then
    sed -i "s~␀id␀~$identifier~g" .blueprint/.storage/defaults/extensions/controller.default.bak;
  fi;
  sed -i "s~␀id␀~$identifier~g" .blueprint/.storage/defaults/extensions/route.default.bak;
  sed -i "s~␀id␀~$identifier~g" .blueprint/.storage/defaults/extensions/button.default.bak;

  ADMINVIEW_RESULT=$(cat .blueprint/.storage/defaults/extensions/admin.default.bak);
  ADMINROUTE_RESULT=$(cat .blueprint/.storage/defaults/extensions/route.default.bak);
  ADMINBUTTON_RESULT=$(cat .blueprint/.storage/defaults/extensions/button.default.bak);
  if [[ $admin_controller == "" ]]; then
    ADMINCONTROLLER_RESULT=$(cat .blueprint/.storage/defaults/extensions/controller.default.bak);
  fi;
  ADMINCONTROLLER_NAME=$identifier"ExtensionController.php";

  mkdir resources/views/admin/extensions/$identifier;
  touch resources/views/admin/extensions/$identifier/index.blade.php;
  echo $ADMINVIEW_RESULT > resources/views/admin/extensions/$identifier/index.blade.php;

  mkdir app/Http/Controllers/Admin/Extensions/$identifier;
  touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;

  if [[ $admin_controller == "" ]]; then
    echo $ADMINCONTROLLER_RESULT > app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
  else
    cp .blueprint/.storage/tmp/$n/$admin_controller app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
  fi;

  if [[ $admin_controller != "" ]]; then
    cp .blueprint/.storage/tmp/$n/$admin_controller app/Http/Controllers/Admin/Extensions/$identifier/${identifier}ExtensionController.php;
  fi;

  echo $ADMINROUTE_RESULT >> routes/admin.php;

  sed -i "s~<!--␀replace␀-->~$ADMINBUTTON_RESULT\n<!--␀replace␀-->~g" resources/views/admin/extensions.blade.php;

  rm .blueprint/.storage/defaults/extensions/admin.default.bak;
  if [[ $admin_controller == "" ]]; then
    rm .blueprint/.storage/defaults/extensions/controller.default.bak;
  fi;
  rm .blueprint/.storage/defaults/extensions/route.default.bak;
  rm .blueprint/.storage/defaults/extensions/button.default.bak;
  rm -R .blueprint/.storage/tmp/$n;

  if [[ $database_migrations != "" ]]; then
    log_bright "[INFO] This extension comes with migrations. If you get prompted, answer 'yes'.\n";
    php artisan migrate;
  fi;

  chmod -R +x .blueprint/.storage/extensiondata/$identifier/*;

  if [[ $flags == *"-run.afterinstall;"* ]]; then
    log_yellow "[WARNING] This extension uses a custom installation script, proceed with caution."
    bash .blueprint/.storage/extensiondata/$identifier/install.sh;
  fi;

  log_green "\n\n[SUCCESS] $identifier should now be installed. If something didn't work as expected, please let us know at ptero.shop/issue.";
  if [[ $dev != true ]]; then
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
  echo "Name (Generic Extension):";             read ASKNAME;
  echo "Identifier (genericextension):";        read ASKIDENTIFIER;
  echo "Description (My awesome description):"; read ASKDESCRIPTION;
  echo "Version (indev):";                      read ASKVERSION;
  echo "Author (prplwtf):";                     read ASKAUTHOR;

  log_bright "[INFO] Running validation checks..";
  if [[ $ASKIDENTIFIER =~ [a-z] ]]; then log_bright "[INFO] Identifier a-z checks passed." > /dev/null;
  else quit_red "[FATAL] Identifier should only contain a-z characters.";fi;

  log_bright "[INFO] Copying init defaults to tmp directory..";
  mkdir .blueprint/.storage/tmp/init;
  cp -R .blueprint/.storage/defaults/init/* .blueprint/.storage/tmp/init/;

  log_bright "[INFO] Applying variables.."
  sed -i "s~␀name␀~$ASKNAME~g" .blueprint/.storage/tmp/init/conf.yml; #NAME
  sed -i "s~␀identifier␀~$ASKIDENTIFIER~g" .blueprint/.storage/tmp/init/conf.yml; #IDENTIFIER
  sed -i "s~␀description␀~$ASKDESCRIPTION~g" .blueprint/.storage/tmp/init/conf.yml; #DESCRIPTION
  sed -i "s~␀ver␀~$ASKVERSION~g" .blueprint/.storage/tmp/init/conf.yml; #VERSION
  sed -i "s~␀author␀~$ASKAUTHOR~g" .blueprint/.storage/tmp/init/conf.yml; #AUTHOR

  icnNUM=$(expr 1 + $RANDOM % 4);
  sed -i "s~␀num␀~$icnNUM~g" .blueprint/.storage/tmp/init/conf.yml;
  sed -i "s~␀version␀~$VERSION~g" .blueprint/.storage/tmp/init/conf.yml;

  # Return files to folder.
  log_bright "[INFO] Copying output to .development directory."
  cp -R .blueprint/.storage/tmp/init/* .blueprint/.development/;

  # Remove tmp files.
  log_bright "[INFO] Purging tmp files."
  rm -R .blueprint/.storage/tmp;
  mkdir .blueprint/.storage/tmp;

  log_green "[SUCCESS] Your extension files have been generated and exported to '.blueprint/.development'.";
fi;

# -build, -test
if [[ ( $2 == "-build" ) || ( $2 == "-test" ) ]]; then
  if [[ $2 == "-test" ]]; then
    quit_red "[FATAL] -test has been removed in alpha-T0R and up, please use -build instead.";
  fi
  log_bright "[INFO] Installing development extension files..";
  blueprint -i test␀;
  log_bright "[INFO] Extension installation ends here, if there are any errors during installation, fix them and try again.";
  sendTelemetry "BUILD_DEVELOPMENT_EXTENSION" > /dev/null;
fi;

# -export
if [[ $2 == "-export" ]]; then
  log_bright "[INFO] Exporting extension files located in '.blueprint/.development'.";

  cd .blueprint
  eval $(parse_yaml .development/conf.yml); identifier=$info_identifier;
  cp -R .development/* .storage/tmp/;
  cd .storage/tmp;
  zip -r extension.zip *;
  cd /var/www/$FOLDER;
  cp .blueprint/.storage/tmp/extension.zip $identifier.blueprint;
  rm -R .blueprint/.storage/tmp;
  mkdir .blueprint/.storage/tmp;

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
  
  if [[ $3 == "dev" ]]; then
    log_yellow "[WARNING] Upgrading to the latest dev build will update Blueprint to an unstable work-in-progress preview of the next version. Continue? (y/N)";
    read YN1;
    if [[ ( $YN1 != "y" ) && ( $YN1 != "Y" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;
  fi;
  log_yellow "[WARNING] Upgrading will wipe your .blueprint folder and will overwrite your extensions. Continue? (y/N)";
  read YN2;
  if [[ ( $YN2 != "y" ) && ( $YN2 != "Y" ) ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;
  log_yellow "[WARNING] This is the last warning before upgrading/wiping Blueprint. Type 'continue' to continue, all other input will be taken as 'no'.";
  read YN3;
  if [[ $YN3 != "continue" ]]; then log_bright "[INFO] Upgrade cancelled.";exit 1;fi;

  log_bright "[INFO] Blueprint is upgrading.. Please do not turn off your machine.";
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
  log_bright "[INFO] Database migrations are skipped when upgrading, run them anyways? (Y/n)";
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
  elif [[ $score == 0 ]]; then
    log_red "[FATAL] Upgrading has failed."
  else
    log_yellow "[WARNING] Some post-upgrade checks have failed."
  fi;
fi;
