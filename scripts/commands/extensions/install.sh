#!/bin/bash

InstallExtension() {
  # The following code does some magic to allow for extensions with a
  # different root folder structure than expected by Blueprint.
  if [[ $1 == "[developer-build]" ]]; then
    dev=true
    n="dev"
    mkdir -p ".blueprint/tmp/dev"
    cp -R ".blueprint/dev/"* ".blueprint/tmp/dev/"
  else
    PRINT INFO "\x1b[34;mInstalling $1...\x1b[0m \x1b[37m($current/$total)\x1b[0m"
    dev=false
    n="$1"

    if [[ $n == *".blueprint" ]]; then n="${n::-10}";fi
    FILE="${n}.blueprint"

    if [[ ! -f "$FILE" ]]; then PRINT FATAL "$FILE could not be found or detected.";return 2;fi

    ZIP="${n}.zip"
    cp "$FILE" ".blueprint/tmp/$ZIP"
    cd ".blueprint/tmp" || cdhalt
    unzip -o -qq "$ZIP"
    rm "$ZIP"
    if [[ ! -f "$n/*" ]]; then
      cd ".." || cdhalt
      rm -R "tmp"
      mkdir -p "tmp"
      cd "tmp" || cdhalt

      mkdir -p "./$n"
      cp "../../$FILE" "./$n/$ZIP"
      cd "$n" || cdhalt
      unzip -o -qq "$ZIP"
      rm "$ZIP"
      cd ".." || cdhalt
    fi
  fi

  ((PROGRESS_NOW++))

  # Return to the Pterodactyl installation folder.
  cd "$FOLDER" || cdhalt

  # Get all strings from the conf.yml file and make them accessible as variables.
  if [[ ! -f ".blueprint/tmp/$n/conf.yml" ]]; then
    # Quit if the extension doesn't have a conf.yml file.
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension configuration file not found or detected."
    return 1
  fi

  eval "$(parse_yaml .blueprint/tmp/"${n}"/conf.yml conf_)"

  # Add aliases for config values to make working with them easier.
  local name="${conf_info_name//&/\\&}"
  local identifier="${conf_info_identifier//&/\\&}"
  local description="${conf_info_description//&/\\&}"
  local flags="${conf_info_flags//&/\\&}" #(optional)
  local version="${conf_info_version//&/\\&}"
  local target="${conf_info_target//&/\\&}"
  local author="${conf_info_author//&/\\&}" #(optional)
  local icon="${conf_info_icon//&/\\&}" #(optional)
  local website="${conf_info_website//&/\\&}"; #(optional)

  local admin_view="$conf_admin_view"
  local admin_controller="$conf_admin_controller"; #(optional)
  local admin_css="$conf_admin_css"; #(optional)
  local admin_wrapper="$conf_admin_wrapper"; #(optional)

  local dashboard_css="$conf_dashboard_css"; #(optional)
  local dashboard_wrapper="$conf_dashboard_wrapper"; #(optional)
  local dashboard_components="$conf_dashboard_components"; #(optional)

  local data_directory="$conf_data_directory"; #(optional)
  local data_public="$conf_data_public"; #(optional)
  local data_console="$conf_data_console"; #(optional)

  local requests_views="$conf_requests_views"; #(optional)
  local requests_app="$conf_requests_app"; #(optional)
  local requests_routers="$conf_requests_routers"; #(optional)
  local requests_routers_application="$conf_requests_routers_application"; #(optional)
  local requests_routers_client="$conf_requests_routers_client"; #(optional)
  local requests_routers_web="$conf_requests_routers_web"; #(optional)

  local database_migrations="$conf_database_migrations"; #(optional)

  ((PROGRESS_NOW++))

  # assign config aliases
  if [[ $requests_routers_application == "" ]] \
  && [[ $requests_routers_client      == "" ]] \
  && [[ $requests_routers_web         == "" ]] \
  && [[ $requests_routers             != "" ]]; then
    local requests_routers_web="$requests_routers"
  fi
  if [[ $conf_requests_controllers != "" ]]; then
    local requests_app="$conf_requests_controllers"
    PRINT WARNING "Config value 'requests_controllers' is deprecated, use 'requests_app' instead."
  fi

  ((PROGRESS_NOW++))

  # "prevent" folder "escaping"
  if [[ ( $icon                         == "/"* ) || ( $icon                         == *"/.."* ) || ( $icon                         == *"../"* ) || ( $icon                         == *"/../"* ) || ( $icon                         == *"~"* ) || ( $icon                         == *"\\"* ) ]] \
  || [[ ( $admin_view                   == "/"* ) || ( $admin_view                   == *"/.."* ) || ( $admin_view                   == *"../"* ) || ( $admin_view                   == *"/../"* ) || ( $admin_view                   == *"~"* ) || ( $admin_view                   == *"\\"* ) ]] \
  || [[ ( $admin_controller             == "/"* ) || ( $admin_controller             == *"/.."* ) || ( $admin_controller             == *"../"* ) || ( $admin_controller             == *"/../"* ) || ( $admin_controller             == *"~"* ) || ( $admin_controller             == *"\\"* ) ]] \
  || [[ ( $admin_css                    == "/"* ) || ( $admin_css                    == *"/.."* ) || ( $admin_css                    == *"../"* ) || ( $admin_css                    == *"/../"* ) || ( $admin_css                    == *"~"* ) || ( $admin_css                    == *"\\"* ) ]] \
  || [[ ( $admin_wrapper                == "/"* ) || ( $admin_wrapper                == *"/.."* ) || ( $admin_wrapper                == *"../"* ) || ( $admin_wrapper                == *"/../"* ) || ( $admin_wrapper                == *"~"* ) || ( $admin_wrapper                == *"\\"* ) ]] \
  || [[ ( $dashboard_css                == "/"* ) || ( $dashboard_css                == *"/.."* ) || ( $dashboard_css                == *"../"* ) || ( $dashboard_css                == *"/../"* ) || ( $dashboard_css                == *"~"* ) || ( $dashboard_css                == *"\\"* ) ]] \
  || [[ ( $dashboard_wrapper            == "/"* ) || ( $dashboard_wrapper            == *"/.."* ) || ( $dashboard_wrapper            == *"../"* ) || ( $dashboard_wrapper            == *"/../"* ) || ( $dashboard_wrapper            == *"~"* ) || ( $dashboard_wrapper            == *"\\"* ) ]] \
  || [[ ( $dashboard_components         == "/"* ) || ( $dashboard_components         == *"/.."* ) || ( $dashboard_components         == *"../"* ) || ( $dashboard_components         == *"/../"* ) || ( $dashboard_components         == *"~"* ) || ( $dashboard_components         == *"\\"* ) ]] \
  || [[ ( $data_directory               == "/"* ) || ( $data_directory               == *"/.."* ) || ( $data_directory               == *"../"* ) || ( $data_directory               == *"/../"* ) || ( $data_directory               == *"~"* ) || ( $data_directory               == *"\\"* ) ]] \
  || [[ ( $data_public                  == "/"* ) || ( $data_public                  == *"/.."* ) || ( $data_public                  == *"../"* ) || ( $data_public                  == *"/../"* ) || ( $data_public                  == *"~"* ) || ( $data_public                  == *"\\"* ) ]] \
  || [[ ( $data_console                 == "/"* ) || ( $data_console                 == *"/.."* ) || ( $data_console                 == *"../"* ) || ( $data_console                 == *"/../"* ) || ( $data_console                 == *"~"* ) || ( $data_console                 == *"\\"* ) ]] \
  || [[ ( $requests_views               == "/"* ) || ( $requests_views               == *"/.."* ) || ( $requests_views               == *"../"* ) || ( $requests_views               == *"/../"* ) || ( $requests_views               == *"~"* ) || ( $requests_views               == *"\\"* ) ]] \
  || [[ ( $requests_app                 == "/"* ) || ( $requests_app                 == *"/.."* ) || ( $requests_app                 == *"../"* ) || ( $requests_app                 == *"/../"* ) || ( $requests_app                 == *"~"* ) || ( $requests_app                 == *"\\"* ) ]] \
  || [[ ( $requests_routers_application == "/"* ) || ( $requests_routers_application == *"/.."* ) || ( $requests_routers_application == *"../"* ) || ( $requests_routers_application == *"/../"* ) || ( $requests_routers_application == *"~"* ) || ( $requests_routers_application == *"\\"* ) ]] \
  || [[ ( $requests_routers_client      == "/"* ) || ( $requests_routers_client      == *"/.."* ) || ( $requests_routers_client      == *"../"* ) || ( $requests_routers_client      == *"/../"* ) || ( $requests_routers_client      == *"~"* ) || ( $requests_routers_client      == *"\\"* ) ]] \
  || [[ ( $requests_routers_web         == "/"* ) || ( $requests_routers_web         == *"/.."* ) || ( $requests_routers_web         == *"../"* ) || ( $requests_routers_web         == *"/../"* ) || ( $requests_routers_web         == *"~"* ) || ( $requests_routers_web         == *"\\"* ) ]] \
  || [[ ( $database_migrations          == "/"* ) || ( $database_migrations          == *"/.."* ) || ( $database_migrations          == *"../"* ) || ( $database_migrations          == *"/../"* ) || ( $database_migrations          == *"~"* ) || ( $database_migrations          == *"\\"* ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Config file paths cannot escape the extension bundle."
    return 1
  fi

  ((PROGRESS_NOW++))

  # prevent potentional problems during installation due to wrongly defined folders
  if [[ ( $dashboard_components == *"/" ) ]] \
  || [[ ( $data_directory == *"/"       ) ]] \
  || [[ ( $data_public == *"/"          ) ]] \
  || [[ ( $data_console == *"/"         ) ]] \
  || [[ ( $requests_views == *"/"       ) ]] \
  || [[ ( $requests_app == *"/"         ) ]] \
  || [[ ( $database_migrations == *"/"  ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Directory paths in conf.yml should not end with a slash."
    return 1
  fi

  ((PROGRESS_NOW++))

  # check if extension still has placeholder values
  if [[ ( $name    == "[name]" ) || ( $identifier == "[identifier]" ) || ( $description == "[description]" ) ]] \
  || [[ ( $version == "[ver]"  ) || ( $target     == "[version]"    ) || ( $author      == "[author]"      ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension contains placeholder values which need to be replaced."
    return 1
  fi

  ((PROGRESS_NOW++))

  # Detect if extension is already installed and prepare the upgrading process.
  if [[ $(cat .blueprint/extensions/blueprint/private/db/installed_extensions) == *"$identifier,"* ]]; then
    PRINT INFO "Switching to update process as extension has already been installed."

    if [[ ! -d ".blueprint/extensions/$identifier/private/.store" ]]; then
      rm -R ".blueprint/tmp/$n"
      PRINT FATAL "Upgrading extension has failed due to missing essential .store files."
      return 1
    fi

    eval "$(parse_yaml .blueprint/extensions/"${identifier}"/private/.store/conf.yml old_)"
    local DUPLICATE="y"

    # run extension update script
    if [[ -f ".blueprint/extensions/$identifier/private/update.sh" ]]; then
      PRINT WARNING "Extension uses a custom update script, proceed with caution."
      hide_progress
      chmod --silent +x ".blueprint/extensions/$identifier/private/update.sh" 2>> "$BLUEPRINT__DEBUG"


      su "$WEBUSER" -s "$USERSHELL" -c "
        cd \"$FOLDER\";
        ENGINE=\"$BLUEPRINT_ENGINE\"         \
        EXTENSION_IDENTIFIER=\"$identifier\" \
        EXTENSION_TARGET=\"$target\"         \
        EXTENSION_VERSION=\"$version\"       \
        PTERODACTYL_DIRECTORY=\"$FOLDER\"    \
        BLUEPRINT_VERSION=\"$VERSION\"       \
        BLUEPRINT_DEVELOPER=\"$dev\"         \
        BLUEPRINT_TMP=\".blueprint/tmp/$n\"  \
        bash .blueprint/extensions/$identifier/private/update.sh
      "
      echo -e "\e[0m\x1b[0m\033[0m"
    fi

    # Clean up some old extension files.
    if [[ $old_data_public != "" ]]; then
      # Clean up old public folder.
      rm -R ".blueprint/extensions/$identifier/public"
      mkdir ".blueprint/extensions/$identifier/public"
    fi
    if [[ $old_data_console != "" ]]; then
      # Clean up old console folder.
      rm -R \
        ".blueprint/extensions/$identifier/console" \
        "app/Console/Commands/BlueprintFramework/Extensions/${identifier^}"
    fi
  fi

  ((PROGRESS_NOW++))

  # Assign variables to extension flags.
  PRINT INFO "Reading and assigning extension flags.."
  assignflags

  ((PROGRESS_NOW++))

  # Force http/https url scheme for extension website urls when needed.
  if [[ $website != "" ]]; then
    if [[ ( $website != "https://"* ) && ( $website != "http://"* ) ]] \
    && [[ ( $website != "/"*        ) && ( $website != "."*       ) ]]; then
      local website="http://${conf_info_website}"
      local conf_info_website="${website}"
    fi

    case "${website}" in
      *"://github.com"* | *"://"*".github.com"*)               local websiteiconclass="bx bx-git-branch" ;;   # GitHub
      *"://gitlab.io"* | *"://"*".gitlab.io"*)                 local websiteiconclass="bx bx-git-branch" ;;   # GitLab
      *"://sourcexchange.net"* | *"://"*".sourcexchange.net"*) local websiteiconclass="bx bx-store" ;;        # sourceXchange
      *"://builtbybit.com"* | *"://"*".builtbybit.com"*)       local websiteiconclass="bx bx-store" ;;        # BuiltByBit
      *"://discord.gg"* | *"://"*".discord.gg"*)               local websiteiconclass="bx bxl-discord-alt" ;; # Discord
      *"://patreon.com"* | *"://"*".patreon.com"*)             local websiteiconclass="bx bxl-patreon" ;;     # Patreon
      *"://twitch.tv"* | *"://"*".twitch.tv"*)                 local websiteiconclass="bx bxl-twitch" ;;      # Twitch
      *"://youtube.com"* | *"://"*".youtube.com"*)             local websiteiconclass="bx bxl-youtube" ;;     # YouTube
      *"://ko-fi.com"* | *"://"*".ko-fi.com"*)                 local websiteiconclass="bx bxs-heart" ;;       # Ko-fi
      
      *) local websiteiconclass="bx bx-link-external" ;;
    esac
  fi

  ((PROGRESS_NOW++))

  if [[ $dev == true ]]; then
    mv ".blueprint/tmp/$n" ".blueprint/tmp/$identifier"
    n=$identifier
  fi

  ((PROGRESS_NOW++))

  if ! $F_ignorePlaceholders; then
    # Prepare variables for placeholders
    PRINT INFO "Writing extension placeholders.."
    DIR=".blueprint/tmp/$n"
    INSTALL_STAMP=$(date +%s)
    local INSTALL_MODE="local"
    if $dev; then local INSTALL_MODE="develop"; fi
    EXT_AUTHOR="$author"
    if [[ $author == "" ]]; then EXT_AUTHOR="undefined"; fi
    IS_TARGET=true
    if [[ $target != "$VERSION" ]]; then IS_TARGET=false; fi

    # Use either legacy or stable placeholders for backwards compatibility.
    if [[ $target == "alpha-"* ]] \
    || [[ $target == "indev-"* ]] \
    || $F_forceLegacyPlaceholders; then

      # (v1) Legacy placeholders
      local INSTALLMODE="normal"
      if [[ $dev == true ]]; then local INSTALLMODE="developer"; fi
      PLACE_PLACEHOLDERS() {
        local dir="$1"
        for file in "$dir"/*; do
          if [ -f "$file" ]; then
            file=${file// /\\ }
            sed -i \
              -e "s~\^#version#\^~$version~g" \
              -e "s~\^#author#\^~$author~g" \
              -e "s~\^#name#\^~$name~g" \
              -e "s~\^#identifier#\^~$identifier~g" \
              -e "s~\^#path#\^~$FOLDER~g" \
              -e "s~\^#datapath#\^~$FOLDER/.blueprint/extensions/$identifier/private~g" \
              -e "s~\^#publicpath#\^~$FOLDER/.blueprint/extensions/$identifier/public~g" \
              -e "s~\^#installmode#\^~$INSTALLMODE~g" \
              -e "s~\^#blueprintversion#\^~$VERSION~g" \
              -e "s~\^#timestamp#\^~$INSTALL_STAMP~g" \
              -e "s~\^#componentroot#\^~@/blueprint/extensions/$identifier~g" \
              \
              -e "s~__version__~$version~g" \
              -e "s~__author__~$author~g" \
              -e "s~__identifier__~$identifier~g" \
              -e "s~__name__~$name~g" \
              -e "s~__path__~$FOLDER~g" \
              -e "s~__datapath__~$FOLDER/.blueprint/extensions/$identifier/private~g" \
              -e "s~__publicpath__~$FOLDER/.blueprint/extensions/$identifier/public~g" \
              -e "s~__installmode__~$INSTALLMODE~g" \
              -e "s~__blueprintversion__~$VERSION~g" \
              -e "s~__timestamp__~$INSTALL_STAMP~g" \
              -e "s~__componentroot__~@/blueprint/extensions/$identifier~g" \
              "$file"
          elif [ -d "$file" ]; then
            PLACE_PLACEHOLDERS "$file"
          fi
        done
      }
      PLACE_PLACEHOLDERS "$DIR"

    else

      # (v2) Stable placeholders
      PLACE_PLACEHOLDERS() {
        local dir="$1"
        for file in "$dir"/*; do
          if [ -f "$file" ]; then
            file=${file// /\\ }

            # Step 1: Modify escaped placeholders to prevent them from being written to.
            # Step 2: Apply normal placeholders.
            # Step 3: Apply placeholders with modifiers.
            # Step 4: Apply conditional placeholders.
            # Step 5: Switch escaped placeholders back to their original form, without the backslash.
            sed -i \
              -e "s~!{identifier~{!!!!identifier~g" \
              -e "s~!{name~{!!!!name~g" \
              -e "s~!{author~{!!!!author~g" \
              -e "s~!{version~{!!!!version~g" \
              -e "s~!{random~{!!!!random~g" \
              -e "s~!{timestamp~{!!!!timestamp~g" \
              -e "s~!{mode~{!!!!mode~g" \
              -e "s~!{target~{!!!!target~g" \
              -e "s~!{root~{!!!!root~g" \
              -e "s~!{webroot~{!!!!webroot~g" \
              -e "s~!{engine_~{!!!!engine_~g" \
              -e "s~!{is_~{!!!!is_~g" \
              \
              -e "s~{identifier}~$identifier~g" \
              -e "s~{name}~$name~g" \
              -e "s~{author}~$EXT_AUTHOR~g" \
              -e "s~{version}~$version~g" \
              -e "s~{random}~$RANDOM~g" \
              -e "s~{timestamp}~$INSTALL_STAMP~g" \
              -e "s~{mode}~$INSTALL_MODE~g" \
              -e "s~{target}~$VERSION~g" \
              -e "s~{root}~$FOLDER~g" \
              -e "s~{webroot}~/~g" \
              -e "s~{engine}~$BLUEPRINT_ENGINE~g" \
              \
              -e "s~{identifier^}~${identifier^}~g" \
              -e "s~{identifier!}~${identifier^^}~g" \
              -e "s~{name!}~${name^^}~g" \
              -e "s~{root/public}~$FOLDER/.blueprint/extensions/$identifier/public~g" \
              -e "s~{root/data}~$FOLDER/.blueprint/extensions/$identifier/private~g" \
              -e "s~{root/fs}~$FOLDER/.blueprint/extensions/$identifier/fs~g" \
              -e "s~{webroot/public}~/extensions/$identifier~g" \
              -e "s~{webroot/fs}~/fs/extensions/$identifier~g" \
              \
              -e "s~{is_target}~$IS_TARGET~g" \
              \
              -e "s~{!!!!identifier~{identifier~g" \
              -e "s~{!!!!name~{name~g" \
              -e "s~{!!!!author~{author~g" \
              -e "s~{!!!!version~{version~g" \
              -e "s~{!!!!random~{random~g" \
              -e "s~{!!!!timestamp~{timestamp~g" \
              -e "s~{!!!!mode~{mode~g" \
              -e "s~{!!!!target~{target~g" \
              -e "s~{!!!!root~{root~g" \
              -e "s~{!!!!webroot~{webroot~g" \
              -e "s~{!!!!engine_~{engine~g" \
              -e "s~{!!!!is_~{is~g" \
              "$file"


          elif [ -d "$file" ]; then
            PLACE_PLACEHOLDERS "$file"
          fi
        done
      }
      PLACE_PLACEHOLDERS "$DIR"

    fi
  fi

  ((PROGRESS_NOW++))

  if [[ $name == "" ]]; then rm -R ".blueprint/tmp/$n";                 PRINT FATAL "'info_name' is a required configuration option.";return 1;fi
  if [[ $identifier == "" ]]; then rm -R ".blueprint/tmp/$n";           PRINT FATAL "'info_identifier' is a required configuration option.";return 1;fi
  if [[ $description == "" ]]; then rm -R ".blueprint/tmp/$n";          PRINT FATAL "'info_description' is a required configuration option.";return 1;fi
  if [[ $version == "" ]]; then rm -R ".blueprint/tmp/$n";              PRINT FATAL "'info_version' is a required configuration option.";return 1;fi
  if [[ $target == "" ]]; then rm -R ".blueprint/tmp/$n";               PRINT FATAL "'info_target' is a required configuration option.";return 1;fi
  if [[ $admin_view == "" ]]; then rm -R ".blueprint/tmp/$n";           PRINT FATAL "'admin_view' is a required configuration option.";return 1;fi

  if [[ $icon == "" ]]; then                                            PRINT WARNING "${identifier^} does not come with an icon, consider adding one.";fi
  if [[ $target != "$VERSION" ]]; then                                  PRINT WARNING "${identifier^} is built for version $target, but your version is $VERSION.";fi
  if [[ $identifier != "$n" ]]; then rm -R ".blueprint/tmp/$n";         PRINT FATAL "Extension file name must be the same as your identifier. (example: identifier.blueprint)";return 1;fi
  if ! [[ $identifier =~ [a-z] ]]; then rm -R ".blueprint/tmp/$n";      PRINT FATAL "Extension identifier should be lowercase and only contain characters a-z.";return 1;fi
  if [[ $identifier == "blueprint" ]]; then rm -R ".blueprint/tmp/$n";  PRINT FATAL "Extensions can not have the identifier 'blueprint'.";return 1;fi

  if [[ $identifier == *" "* ]] \
  || [[ $identifier == *"-"* ]] \
  || [[ $identifier == *"_"* ]] \
  || [[ $identifier == *"."* ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension identifier may not contain spaces, underscores, hyphens or periods."
    return 1
  fi

  ((PROGRESS_NOW++))

  # Validate paths to files and directories defined in conf.yml.
  if \
    [[ ( ! -f ".blueprint/tmp/$n/$icon"                         ) && ( ${icon} != ""                         ) ]] ||    # file:   icon                         (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$admin_view"                   )                                              ]] ||    # file:   admin_view
    [[ ( ! -f ".blueprint/tmp/$n/$admin_controller"             ) && ( ${admin_controller} != ""             ) ]] ||    # file:   admin_controller             (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$admin_css"                    ) && ( ${admin_css} != ""                    ) ]] ||    # file:   admin_css                    (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$admin_wrapper"                ) && ( ${admin_wrapper} != ""                ) ]] ||    # file:   admin_wrapper                (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$dashboard_css"                ) && ( ${dashboard_css} != ""                ) ]] ||    # file:   dashboard_css                (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$dashboard_wrapper"            ) && ( ${dashboard_wrapper} != ""            ) ]] ||    # file:   dashboard_wrapper            (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$dashboard_components"         ) && ( ${dashboard_components} != ""         ) ]] ||    # folder: dashboard_components         (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$data_directory"               ) && ( ${data_directory} != ""               ) ]] ||    # folder: data_directory               (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$data_public"                  ) && ( ${data_public} != ""                  ) ]] ||    # folder: data_public                  (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$requests_views"               ) && ( ${requests_views} != ""               ) ]] ||    # folder: requests_views               (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$requests_app"                 ) && ( ${requests_app} != ""                 ) ]] ||    # folder: requests_app                 (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_application" ) && ( ${requests_routers_application} != "" ) ]] ||    # file:   requests_routers_application (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_client"      ) && ( ${requests_routers_client} != ""      ) ]] ||    # file:   requests_routers_client      (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_web"         ) && ( ${requests_routers_web} != ""         ) ]] ||    # file:   requests_routers_web         (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$database_migrations"          ) && ( ${database_migrations} != ""          ) ]];then  # folder: database_migrations          (optional)
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension configuration points towards one or more files that do not exist."
    return 1
  fi

  ((PROGRESS_NOW++))

  # Place database migrations.
  if [[ $database_migrations != "" ]]; then
    PRINT INFO "Cloning database migration files.."
    cp -R ".blueprint/tmp/$n/$database_migrations/"* "database/migrations/" 2>> "$BLUEPRINT__DEBUG"
    dbmigrations="true"
  fi

  ((PROGRESS_NOW++))

  # Place views directory.
  if [[ $requests_views != "" ]]; then
    PRINT INFO "Cloning and linking views directory.."
    mkdir -p ".blueprint/extensions/$identifier/views"
    cp -R ".blueprint/tmp/$n/$requests_views/"* ".blueprint/extensions/$identifier/views/" 2>> "$BLUEPRINT__DEBUG"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/views" "$FOLDER/resources/views/blueprint/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"
  fi

  ((PROGRESS_NOW++))

  # Place app directory.
  if [[ $requests_app != "" ]]; then
    PRINT INFO "Cloning and linking app directory.."
    mkdir -p ".blueprint/extensions/$identifier/app"
    cp -R ".blueprint/tmp/$n/$requests_app/"* ".blueprint/extensions/$identifier/app/" 2>> "$BLUEPRINT__DEBUG"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/app" "$FOLDER/app/BlueprintFramework/Extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"
  fi

  ((PROGRESS_NOW++))

  # Place routes directory.
  if [[ $requests_routers_application != "" ]] \
  || [[ $requests_routers_client      != "" ]] \
  || [[ $requests_routers_web         != "" ]]; then
    PRINT INFO "Cloning and linking router files.."
    mkdir -p ".blueprint/extensions/$identifier/routers"

    if [[ $requests_routers_application != "" ]]; then
      {
        rm "$FOLDER/routes/blueprint/application/$identifier.php"
        cp -R ".blueprint/tmp/$n/$requests_routers_application" ".blueprint/extensions/$identifier/routers/application.php"
        ln -s -r -T ".blueprint/extensions/$identifier/routers/application.php" "$FOLDER/routes/blueprint/application/$identifier.php"
      } 2>> "$BLUEPRINT__DEBUG"
    fi

    if [[ $requests_routers_client != "" ]]; then
      {
        rm "$FOLDER/routes/blueprint/client/$identifier.php"
        cp -R ".blueprint/tmp/$n/$requests_routers_client" ".blueprint/extensions/$identifier/routers/client.php"
        ln -s -r -T ".blueprint/extensions/$identifier/routers/client.php" "$FOLDER/routes/blueprint/client/$identifier.php"
      } 2>> "$BLUEPRINT__DEBUG"
    fi

    if [[ $requests_routers_web != "" ]]; then
      {
        rm "$FOLDER/routes/blueprint/web/$identifier.php"
        cp -R ".blueprint/tmp/$n/$requests_routers_web" ".blueprint/extensions/$identifier/routers/web.php"
        ln -s -r -T ".blueprint/extensions/$identifier/routers/web.php" "$FOLDER/routes/blueprint/web/$identifier.php"
      } 2>> "$BLUEPRINT__DEBUG"
    fi
  fi

  ((PROGRESS_NOW++))

  # Place and link console directory and generate artisan files.
  if [[ $data_console != "" ]]; then
    PRINT INFO "Cloning and linking console directory.."

    # Create console directory alongside a functions directory which would store all console functions.
    # -> To avoid conflicts, we sadly have to import functions instead of giving full access to Artisan commands.
    #    We'll need to create a decently large BlueprintConsoleLibrary for more functionality as well, and somehow
    #    automatically import it into these functions.
    mkdir -p \
      ".blueprint/extensions/$identifier/console/functions" \
      "app/Console/Commands/BlueprintFramework/Extensions/${identifier^}"
    cp -R ".blueprint/tmp/$n/$data_console/"* ".blueprint/extensions/$identifier/console/functions/" 2>> "$BLUEPRINT__DEBUG"

    # Now we check if Console.yml exists, and if it does, create Artisan commands from options defined in Console.yml.
    if [[ -f ".blueprint/tmp/$n/$data_console/Console.yml" ]]; then

      # Read the Console.yml file with the "parse_yaml" library.
      eval "$(parse_yaml .blueprint/tmp/"$n"/"$data_console"/Console.yml Console_)"
      if [[ $DUPLICATE == "y" ]]; then eval "$(parse_yaml .blueprint/extensions/"${identifier}"/private/.store/Console.yml OldConsole_)"; fi
    
      # Print warning if console configuration is empty - otherwise go through all options.
      if [[ $Console__ == "" ]]; then
        PRINT WARNING "Console configuration (Console.yml) is empty!"
      else
        PRINT INFO "Creating and linking console commands and schedules.."

        # Create (and replace) schedules file
        touch "app/BlueprintFramework/Schedules/${identifier^}Schedules.php" 2>> "$BLUEPRINT__DEBUG"
        echo -e "<?php\n\n" > "app/BlueprintFramework/Schedules/${identifier^}Schedules.php"

        for parent in $Console__; do
          parent="${parent}_"
          for child in ${!parent}; do
            # Entry signature
            if [[ $child == "Console_"+([0-9])"_Signature" ]]; then CONSOLE_ENTRY_SIGN="${!child}"; fi
            # Entry description
            if [[ $child == "Console_"+([0-9])"_Description" ]]; then CONSOLE_ENTRY_DESC="${!child}"; fi
            # Entry path
            if [[ $child == "Console_"+([0-9])"_Path" ]]; then CONSOLE_ENTRY_PATH="${!child}"; fi
            # Entry interval
            if [[ $child == "Console_"+([0-9])"_Interval" ]]; then CONSOLE_ENTRY_INTE="${!child}"; fi
          done

          ArtisanCommandConstructor="$__BuildDir/extensions/console/ArtisanCommandConstructor.bak"
          ScheduleConstructor="$__BuildDir/extensions/console/ScheduleConstructor.bak"

          {
            cp "$__BuildDir/extensions/console/ArtisanCommandConstructor" "$ArtisanCommandConstructor"
            cp "$__BuildDir/extensions/console/ScheduleConstructor" "$ScheduleConstructor"
          } 2>> "$BLUEPRINT__DEBUG"

          sed -i "s~\[id\^]~""${identifier^}""~g" "$ArtisanCommandConstructor"

          CONSOLE_ENTRY_SIGN="${CONSOLE_ENTRY_SIGN//&/\\&}"
          CONSOLE_ENTRY_DESC="${CONSOLE_ENTRY_DESC//&/\\&}"
          CONSOLE_ENTRY_SIGN="${CONSOLE_ENTRY_SIGN//\'/\\\'}"
          CONSOLE_ENTRY_DESC="${CONSOLE_ENTRY_DESC//\'/\\\'}"

          # Console entry identifier
          CONSOLE_ENTRY_IDEN=$(tr -dc '[:lower:]' < /dev/urandom | fold -w 10 | head -n 1)
          CONSOLE_ENTRY_IDEN="${identifier^}${CONSOLE_ENTRY_IDEN^}"

          echo -e "SIGN: $CONSOLE_ENTRY_SIGN\nDESC: $CONSOLE_ENTRY_DESC\nPATH: $CONSOLE_ENTRY_PATH\nINTE: $CONSOLE_ENTRY_INTE\nIDEN: $CONSOLE_ENTRY_IDEN" >> "$BLUEPRINT__DEBUG"


          # Prevent escaping console folder.
          if [[
            ( ${CONSOLE_ENTRY_PATH} == "/"* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"/.."* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"../"* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"/../"* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"\n"* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"@"* ) ||
            ( ${CONSOLE_ENTRY_PATH} == *"\\"* )
          ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Console entry paths may not escape the console directory."
            return 1
          fi

          # Validate file names for console entries.
          if [[ ${CONSOLE_ENTRY_PATH} != *".php" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Console entry paths may not end with a file extension other than '.php'."
            return 1
          fi

          # Validate file path.
          if [[ ! -f ".blueprint/tmp/$n/$data_console/${CONSOLE_ENTRY_PATH}" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Console configuration points towards one or more files that do not exist."
            return 1
          fi

          # Return error if identifier is generated incorrectly.
          if [[ $CONSOLE_ENTRY_IDEN == "" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Failed to generate extension console entry identifier, halting process."
            return 1
          fi

          # Return error if console entries are defined incorrectly.
          if [[ $CONSOLE_ENTRY_SIGN == "" ]] \
          || [[ $CONSOLE_ENTRY_DESC == "" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "One or more extension console entries appear to have undefined fields."
            return 1
          fi

          # Assign value to certain variables if empty/invalid
          if [[ $CONSOLE_ENTRY_INTE == "" ]]; then CONSOLE_ENTRY_INTE="false";  fi

          # Apply variables to contructors.
          sed -i \
            -e "s~\[IDENTIFIER\]~$identifier~g" \
            -e "s~\[SIGNATURE\]~$CONSOLE_ENTRY_SIGN~g" \
            -e "s~\[DESCRIPTION\]~$CONSOLE_ENTRY_DESC~g" \
            -e "s~\[FILENAME\]~$CONSOLE_ENTRY_PATH~g" \
            -e "s~__ArtisanCommand__~${CONSOLE_ENTRY_IDEN}Command~g" \
            "$ArtisanCommandConstructor"
          sed -i \
            -e "s~\[IDENTIFIER\]~$identifier~g" \
            -e "s~\[SIGNATURE\]~$CONSOLE_ENTRY_SIGN~g" \
            "$ScheduleConstructor"
          
          cp "$ArtisanCommandConstructor" "app/Console/Commands/BlueprintFramework/Extensions/${identifier^}/${CONSOLE_ENTRY_IDEN}Command.php"

          # Detect schedule definition and apply it
          SCHEDULE_SET=false
          if [[ 
            ( $CONSOLE_ENTRY_INTE != "" ) &&
            ( $CONSOLE_ENTRY_INTE != "false" )
          ]]; then
            SCHEDULE_SET="false"
            ApplyConsoleInterval() {
              sed -i "s~\[SCHEDULE\]~${1}()~g" "$ScheduleConstructor"
            }

            case "${CONSOLE_ENTRY_INTE}" in
              everyMinute)         ApplyConsoleInterval "everyMinute" ;;
              everyTwoMinutes)     ApplyConsoleInterval "everyTwoMinutes" ;;
              everyThreeMinutes)   ApplyConsoleInterval "everyThreeMinutes" ;;
              everyFourMinutes)    ApplyConsoleInterval "everyFourMinutes" ;;
              everyFiveMinutes)    ApplyConsoleInterval "everyFiveMinutes" ;;
              everyTenMinutes)     ApplyConsoleInterval "everyTenMinutes" ;;
              everyFifteenMinutes) ApplyConsoleInterval "everyFifteenMinutes" ;;
              everyThirtyMinutes)  ApplyConsoleInterval "everyThirtyMinutes" ;;
              hourly)              ApplyConsoleInterval "hourly" ;;
              daily)               ApplyConsoleInterval "daily" ;;
              weekdays)            ApplyConsoleInterval "daily()->weekdays" ;;
              weekends)            ApplyConsoleInterval "daily()->weekends" ;;
              sundays)             ApplyConsoleInterval "daily()->sundays" ;;
              mondays)             ApplyConsoleInterval "daily()->mondays" ;;
              tuesdays)            ApplyConsoleInterval "daily()->tuesdays" ;;
              wednesdays)          ApplyConsoleInterval "daily()->wednesdays" ;;
              thursdays)           ApplyConsoleInterval "daily()->thursdays" ;;
              fridays)             ApplyConsoleInterval "daily()->fridays" ;;
              saturdays)           ApplyConsoleInterval "daily()->saturdays" ;;
              weekly)              ApplyConsoleInterval "weekly" ;;
              monthly)             ApplyConsoleInterval "monthly" ;;
              quarterly)           ApplyConsoleInterval "quarterly" ;;
              yearly)              ApplyConsoleInterval "yearly" ;;
            
              *)                   sed -i "s~\[SCHEDULE\]~cron('$CONSOLE_ENTRY_INTE')~g" "$ScheduleConstructor" ;;
            esac
            
            cat "$ScheduleConstructor" >> "app/BlueprintFramework/Schedules/${identifier^}Schedules.php"
          fi

          # Clear variables after doing all console entry stuff for a defined entry.
          CONSOLE_ENTRY_SIGN=""
          CONSOLE_ENTRY_DESC=""
          CONSOLE_ENTRY_PATH=""
          CONSOLE_ENTRY_INTE=""
          CONSOLE_ENTRY_IDEN=""

          rm \
            "$ArtisanCommandConstructor" \
            "$ScheduleConstructor" \
            2>> "$BLUEPRINT__DEBUG"
        done
      fi

    fi
  fi

  ((PROGRESS_NOW++))

  # Create, link and connect components directory.
  if [[ $dashboard_components != "" ]]; then
    YARN="y"
    PRINT INFO "Cloning and linking components directory.."
    mkdir -p ".blueprint/extensions/$identifier/components"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/components" "$FOLDER/resources/scripts/blueprint/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"

    # Remove custom routes to prevent duplicates.
    if [[ $DUPLICATE == "y" ]]; then
      sed -i \
        -e "s/\/\* ${identifier^}ImportStart \*\/.*\/\* ${identifier^}ImportEnd \*\///" \
        -e "s~/\* ${identifier^}ImportStart \*/~~g" \
        -e "s~/\* ${identifier^}ImportEnd \*/~~g" \
        \
        -e "s/\/\* ${identifier^}AccountRouteStart \*\/.*\/\* ${identifier^}AccountRouteEnd \*\///" \
        -e "s~/\* ${identifier^}AccountRouteStart \*~~g" \
        -e "s~/\* ${identifier^}AccountRouteEnd \*~~g" \
        \
        -e "s/\/\* ${identifier^}ServerRouteStart \*\/.*\/\* ${identifier^}ServerRouteEnd \*\///" \
        -e "s~/\* ${identifier^}ServerRouteStart \*~~g" \
        -e "s~/\* ${identifier^}ServerRouteEnd \*~~g" \
        \
        "resources/scripts/blueprint/extends/routers/routes.ts"
    fi

    cp -R ".blueprint/tmp/$n/$dashboard_components/"* ".blueprint/extensions/$identifier/components/" 2>> "$BLUEPRINT__DEBUG"
    if [[ -f ".blueprint/tmp/$n/$dashboard_components/Components.yml" ]]; then

      # fetch component config
      eval "$(parse_yaml .blueprint/tmp/"$n"/"$dashboard_components"/Components.yml Components_)"
      if [[ $DUPLICATE == "y" ]]; then eval "$(parse_yaml .blueprint/extensions/"${identifier}"/private/.store/Components.yml OldComponents_)"; fi

      # define static variables to make stuff a bit easier
      im="\/\* blueprint\/import \*\/"; re="{/\* blueprint\/react \*/}"; co="resources/scripts/blueprint/components"
      s="import ${identifier^}Component from '"; e="';"

      PLACE_REACT() {
        if [[
          ( $1 == "/"* ) ||
          ( $1 == *"/.."* ) ||
          ( $1 == *"../"* ) ||
          ( $1 == *"/../"* ) ||
          ( $1 == *"\n"* ) ||
          ( $1 == *"@"* ) ||
          ( $1 == *"\\"* )
        ]]; then
          rm -R ".blueprint/tmp/$n"
          PRINT FATAL "Component file paths cannot escape the components folder."
          return 1
        fi

        if [[ $3 != "$1" ]]; then
          # remove old components
          sed -i "s~""${s}@/blueprint/extensions/${identifier}/$3${e}""~~g" "$co"/"$2"
          sed -i "s~""<${identifier^}Component />""~~g" "$co"/"$2"
        fi
        if [[ ! $1 == "" ]]; then

          # validate file name
          if [[ ${1} == *".tsx" ]] ||
            [[ ${1} == *".ts"   ]] ||
            [[ ${1} == *".jsx"  ]] ||
            [[ ${1} == *".js"   ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Component paths may not end with a file extension."
            return 1
          fi

          # validate path
          if [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.tsx" ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.ts"   ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.jsx"  ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.js"   ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Components configuration points towards one or more files that do not exist."
            return 1
          fi

          # Purge and add components.
          sed -i \
            -e "s~""${s}@/blueprint/extensions/${identifier}/$1${e}""~~g" \
            -e "s~""<${identifier^}Component />""~~g" \
            \
            -e "s~""$im""~""${im}${s}@/blueprint/extensions/${identifier}/$1${e}""~g" \
            -e "s~""$re""~""${re}\<${identifier^}Component /\>""~g" \
            "$co"/"$2"
        fi
      }

      # Backwards compatibility
      if [ -n "$Components_Dashboard_BeforeContent" ]; then Components_Dashboard_Serverlist_BeforeContent="$Components_Dashboard_BeforeContent"; fi
      if [ -n "$Components_Dashboard_AfterContent" ]; then Components_Dashboard_Serverlist_AfterContent="$Components_Dashboard_AfterContent"; fi
      if [ -n "$Components_Dashboard_ServerRow_" ]; then 
        Components_Dashboard_Serverlist_ServerRow_BeforeEntryName="$Components_Dashboard_ServerRow_BeforeEntryName"
        Components_Dashboard_Serverlist_ServerRow_AfterEntryName="$Components_Dashboard_ServerRow_AfterEntryName"
        Components_Dashboard_Serverlist_ServerRow_BeforeEntryDescription="$Components_Dashboard_ServerRow_BeforeEntryDescription"
        Components_Dashboard_Serverlist_ServerRow_AfterEntryDescription="$Components_Dashboard_ServerRow_AfterEntryDescription"
        Components_Dashboard_Serverlist_ServerRow_ResourceLimits="$Components_Dashboard_ServerRow_ResourceLimits"
      fi

      if [[ $DUPLICATE == "y" ]]; then
        if [ -n "$OldComponents_Dashboard_BeforeContent" ]; then OldComponents_Dashboard_Serverlist_BeforeContent="$OldComponents_Dashboard_BeforeContent"; fi
        if [ -n "$OldComponents_Dashboard_AfterContent" ]; then OldComponents_Dashboard_Serverlist_AfterContent="$OldComponents_Dashboard_AfterContent"; fi
        if [ -n "$OldComponents_Dashboard_ServerRow_" ]; then 
          OldComponents_Dashboard_Serverlist_ServerRow_BeforeEntryName="$OldComponents_Dashboard_ServerRow_BeforeEntryName"
          OldComponents_Dashboard_Serverlist_ServerRow_AfterEntryName="$OldComponents_Dashboard_ServerRow_AfterEntryName"
          OldComponents_Dashboard_Serverlist_ServerRow_BeforeEntryDescription="$OldComponents_Dashboard_ServerRow_BeforeEntryDescription"
          OldComponents_Dashboard_Serverlist_ServerRow_AfterEntryDescription="$OldComponents_Dashboard_ServerRow_AfterEntryDescription"
          OldComponents_Dashboard_Serverlist_ServerRow_ResourceLimits="$OldComponents_Dashboard_ServerRow_ResourceLimits"
        fi
      fi

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
      PLACE_REACT "$Components_Dashboard_Global_BeforeSection" "Dashboard/Global/BeforeSection.tsx" "$OldComponents_Dashboard_Global_BeforeSection"
      PLACE_REACT "$Components_Dashboard_Global_AfterSection" "Dashboard/Global/AfterSection.tsx" "$OldComponents_Dashboard_Global_AfterSection"
      PLACE_REACT "$Components_Dashboard_Serverlist_BeforeContent" "Dashboard/Serverlist/BeforeContent.tsx" "$OldComponents_Dashboard_Serverlist_BeforeContent"
      PLACE_REACT "$Components_Dashboard_Serverlist_AfterContent" "Dashboard/Serverlist/AfterContent.tsx" "$OldComponents_Dashboard_Serverlist_AfterContent"
      PLACE_REACT "$Components_Dashboard_Serverlist_ServerRow_BeforeEntryName" "Dashboard/Serverlist/ServerRow/BeforeEntryName.tsx" "$OldComponents_Dashboard_Serverlist_ServerRow_BeforeEntryName"
      PLACE_REACT "$Components_Dashboard_Serverlist_ServerRow_AfterEntryName" "Dashboard/Serverlist/ServerRow/AfterEntryName.tsx" "$OldComponents_Dashboard_Serverlist_ServerRow_AfterEntryName"
      PLACE_REACT "$Components_Dashboard_Serverlist_ServerRow_BeforeEntryDescription" "Dashboard/Serverlist/ServerRow/BeforeEntryDescription.tsx" "$OldComponents_Dashboard_Serverlist_ServerRow_BeforeEntryDescription"
      PLACE_REACT "$Components_Dashboard_Serverlist_ServerRow_AfterEntryDescription" "Dashboard/Serverlist/ServerRow/AfterEntryDescription.tsx" "$OldComponents_Dashboard_Serverlist_ServerRow_AfterEntryDescription"
      PLACE_REACT "$Components_Dashboard_Serverlist_ServerRow_ResourceLimits" "Dashboard/Serverlist/ServerRow/ResourceLimits.tsx" "$OldComponents_Dashboard_Serverlist_ServerRow_ResourceLimits"

      # authentication
      PLACE_REACT "$Components_Authentication_Container_BeforeContent" "Authentication/Container/BeforeContent.tsx" "$OldComponents_Authentication_Container_BeforeContent"
      PLACE_REACT "$Components_Authentication_Container_AfterContent" "Authentication/Container/AfterContent.tsx" "$OldComponents_Authentication_Container_AfterContent"

      # server
      PLACE_REACT "$Components_Server_Terminal_BeforeContent" "Server/Terminal/BeforeContent.tsx" "$OldComponents_Server_Terminal_BeforeContent"
      PLACE_REACT "$Components_Server_Terminal_AdditionalPowerButtons" "Server/Terminal/AdditionalPowerButtons.tsx" "$OldComponents_Server_Terminal_AdditionalPowerButtons"
      PLACE_REACT "$Components_Server_Terminal_BeforeInformation" "Server/Terminal/BeforeInformation.tsx" "$OldComponents_Server_Terminal_BeforeInformation"
      PLACE_REACT "$Components_Server_Terminal_AfterInformation" "Server/Terminal/AfterInformation.tsx" "$OldComponents_Server_Terminal_AfterInformation"
      PLACE_REACT "$Components_Server_Terminal_CommandRow" "Server/Terminal/CommandRow.tsx" "$OldComponents_Server_Terminal_CommandRow"
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



      # Place custom extension routes.
      if [[ $Components_Navigation_Routes_ != "" ]]; then
        PRINT INFO "Linking navigation routes.."

        ImportConstructor="$__BuildDir/extensions/routes/importConstructor.bak"
        AccountRouteConstructor="$__BuildDir/extensions/routes/accountRouteConstructor.bak"
        ServerRouteConstructor="$__BuildDir/extensions/routes/serverRouteConstructor.bak"

        {
          cp "$__BuildDir/extensions/routes/importConstructor" "$ImportConstructor"
          cp "$__BuildDir/extensions/routes/accountRouteConstructor" "$AccountRouteConstructor"
          cp "$__BuildDir/extensions/routes/serverRouteConstructor" "$ServerRouteConstructor"
        } 2>> "$BLUEPRINT__DEBUG"

        sed -i "s~\[id\^]~""${identifier^}""~g" "$ImportConstructor"
        sed -i "s~\[id\^]~""${identifier^}""~g" "$AccountRouteConstructor"
        sed -i "s~\[id\^]~""${identifier^}""~g" "$ServerRouteConstructor"

        for parent in $Components_Navigation_Routes_; do
          parent="${parent}_"
          for child in ${!parent}; do
            # Route name
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_Name" ]]; then COMPONENTS_ROUTE_NAME="${!child}"; fi
            # Route path
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_Path" ]]; then COMPONENTS_ROUTE_PATH="${!child}"; fi
            # Route type
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_Type" ]]; then COMPONENTS_ROUTE_TYPE="${!child}"; fi
            # Route component
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_Component" ]]; then COMPONENTS_ROUTE_COMP="${!child}"; fi
            # Route permission
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_Permission" ]]; then COMPONENTS_ROUTE_PERM="${!child}"; fi
            # Route admin
            if [[ $child == "Components_Navigation_Routes_"+([0-9])"_AdminOnly" ]]; then COMPONENTS_ROUTE_ADMI="${!child}"; fi
          done

          # Route identifier
          COMPONENTS_ROUTE_IDEN=$(tr -dc '[:lower:]' < /dev/urandom | fold -w 10 | head -n 1)
          COMPONENTS_ROUTE_IDEN="${identifier^}${COMPONENTS_ROUTE_IDEN^}"

          echo -e "NAME: $COMPONENTS_ROUTE_NAME\nPATH: $COMPONENTS_ROUTE_PATH\nTYPE: $COMPONENTS_ROUTE_TYPE\nCOMP: $COMPONENTS_ROUTE_COMP\nIDEN: $COMPONENTS_ROUTE_IDEN\nPERM: $COMPONENTS_ROUTE_PERM\nADMI: $COMPONENTS_ROUTE_ADMI" >> "$BLUEPRINT__DEBUG"


          # Return error if type is not defined correctly.
          if [[ ( $COMPONENTS_ROUTE_TYPE != "server" ) && ( $COMPONENTS_ROUTE_TYPE != "account" ) ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Navigation route types can only be either 'server' or 'account'."
            return 1
          fi

          # Prevent escaping components folder.
          if [[
            ( ${COMPONENTS_ROUTE_COMP} == "/"* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"/.."* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"../"* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"/../"* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"\n"* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"@"* ) ||
            ( ${COMPONENTS_ROUTE_COMP} == *"\\"* )
          ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Navigation route component paths may not escape the components directory."
            return 1
          fi

          # Validate file names for route components.
          if [[ ${COMPONENTS_ROUTE_COMP} == *".tsx" ]] \
          || [[ ${COMPONENTS_ROUTE_COMP} == *".ts"  ]] \
          || [[ ${COMPONENTS_ROUTE_COMP} == *".jsx" ]] \
          || [[ ${COMPONENTS_ROUTE_COMP} == *".js"  ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Navigation route component paths may not end with a file extension."
            return 1
          fi

          # Validate file path.
          if [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${COMPONENTS_ROUTE_COMP}.tsx" ]] \
          && [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${COMPONENTS_ROUTE_COMP}.ts"  ]] \
          && [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${COMPONENTS_ROUTE_COMP}.jsx" ]] \
          && [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${COMPONENTS_ROUTE_COMP}.js"  ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Navigation route configuration points towards one or more components that do not exist."
            return 1
          fi

          # Return error if identifier is generated incorrectly.
          if [[ $COMPONENTS_ROUTE_IDEN == "" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Failed to generate extension navigation route identifier, halting process."
            return 1
          fi

          # Return error if routes are defined incorrectly.
          if [[ $COMPONENTS_ROUTE_PATH == "" ]] \
          || [[ $COMPONENTS_ROUTE_TYPE == "" ]] \
          || [[ $COMPONENTS_ROUTE_COMP == "" ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "One or more extension navigation routes appear to have undefined fields."
            return 1
          fi

          # Assign value to certain variables if empty/invalid
          if [[ $COMPONENTS_ROUTE_ADMI != "true" ]]; then COMPONENTS_ROUTE_ADMI="false"; fi
          if [[ $COMPONENTS_ROUTE_PERM == ""     ]]; then COMPONENTS_ROUTE_PERM="null";  fi

          # Apply routes.
          if [[ $COMPONENTS_ROUTE_TYPE == "account" ]]; then
            # Account routes
            #if [[ $COMPONENTS_ROUTE_PERM != "" ]]; then PRINT WARNING "Route permission declarations have no effect on account navigation routes."; fi

            COMPONENTS_IMPORT="import $COMPONENTS_ROUTE_IDEN from '@/blueprint/extensions/$identifier/$COMPONENTS_ROUTE_COMP';"
            COMPONENTS_ROUTE="{ path: '$COMPONENTS_ROUTE_PATH', name: '$COMPONENTS_ROUTE_NAME', component: $COMPONENTS_ROUTE_IDEN, adminOnly: $COMPONENTS_ROUTE_ADMI, identifier: '$identifier' },"

            sed -i "s~/\* \[import] \*/~/* [import] */""$COMPONENTS_IMPORT""~g" "$ImportConstructor"
            sed -i "s~/\* \[routes] \*/~/* [routes] */""$COMPONENTS_ROUTE""~g" "$AccountRouteConstructor"
          elif [[ $COMPONENTS_ROUTE_TYPE == "server" ]]; then
            # Server routes
            COMPONENTS_IMPORT="import $COMPONENTS_ROUTE_IDEN from '@/blueprint/extensions/$identifier/$COMPONENTS_ROUTE_COMP';"
            COMPONENTS_ROUTE="{ path: '$COMPONENTS_ROUTE_PATH', permission: $COMPONENTS_ROUTE_PERM, name: '$COMPONENTS_ROUTE_NAME', component: $COMPONENTS_ROUTE_IDEN, adminOnly: $COMPONENTS_ROUTE_ADMI, identifier: '$identifier' },"

            sed -i "s~/\* \[import] \*/~/* [import] */""$COMPONENTS_IMPORT""~g" "$ImportConstructor"
            sed -i "s~/\* \[routes] \*/~/* [routes] */""$COMPONENTS_ROUTE""~g" "$ServerRouteConstructor"
          fi

          # Clear variables after doing all route stuff for a defined route.
          COMPONENTS_ROUTE=""
          COMPONENTS_IMPORT=""

          COMPONENTS_ROUTE_NAME=""
          COMPONENTS_ROUTE_PATH=""
          COMPONENTS_ROUTE_TYPE=""
          COMPONENTS_ROUTE_COMP=""
          COMPONENTS_ROUTE_IDEN=""
          COMPONENTS_ROUTE_PERM=""
          COMPONENTS_ROUTE_ADMI=""
        done

        sed -i "s~/\* \[import] \*/~~g" "$ImportConstructor"
        sed -i "s~/\* \[routes] \*/~~g" "$AccountRouteConstructor"
        sed -i "s~/\* \[routes] \*/~~g" "$ServerRouteConstructor"

        sed -i \
          -e "s~\/\* blueprint\/import \*\/~/* blueprint/import */""$(tr '\n' '\001' <"${ImportConstructor}")""~g" \
          -e "s~\/\* routes/account \*\/~/* routes/account */""$(tr '\n' '\001' <"${AccountRouteConstructor}")""~g" \
          -e "s~\/\* routes/server \*\/~/* routes/server */""$(tr '\n' '\001' <"${ServerRouteConstructor}")""~g" \
          "resources/scripts/blueprint/extends/routers/routes.ts"

        # Fix line breaks by removing all of them.
        sed -i -E "s~~~g" "resources/scripts/blueprint/extends/routers/routes.ts"

        rm \
          "$ImportConstructor" \
          "$AccountRouteConstructor" \
          "$ServerRouteConstructor" \
          2>> "$BLUEPRINT__DEBUG"
      fi
    else
      # warn about missing components.yml file
      PRINT WARNING "Could not find '$dashboard_components/Components.yml', component extendability might be limited."
    fi
  fi

  ((PROGRESS_NOW++))

  # Create and link public directory.
  if [[ $data_public != "" ]]; then
    PRINT INFO "Cloning and linking public directory.."
    mkdir -p ".blueprint/extensions/$identifier/public"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/public" "$FOLDER/public/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"

    cp -R ".blueprint/tmp/$n/$data_public/"* ".blueprint/extensions/$identifier/public/" 2>> "$BLUEPRINT__DEBUG"
  fi

  if [[ $admin_controller == "" ]]; then
    controller_type="default"
  else
    controller_type="custom"
  fi

  ((PROGRESS_NOW++))

  # Prepare build files.
  AdminControllerConstructor="$__BuildDir/extensions/controller.build.bak"
  AdminBladeConstructor="$__BuildDir/extensions/admin.blade.php.bak"
  ConfigExtensionFS="$__BuildDir/extensions/config/ExtensionFS.build.bak"
  {
    if [[ $controller_type == "default" ]]; then cp "$__BuildDir/extensions/controller.build" "$AdminControllerConstructor"; fi
    cp "$__BuildDir/extensions/admin.blade.php" "$AdminBladeConstructor"
    cp "$__BuildDir/extensions/config/ExtensionFS.build" "$ConfigExtensionFS"
  } 2>> "$BLUEPRINT__DEBUG"

  ((PROGRESS_NOW++))

  # Start creating data directory.
  PRINT INFO "Cloning and linking private directory.."
  mkdir -p \
    ".blueprint/extensions/$identifier/private" \
    ".blueprint/extensions/$identifier/private/.store"

  if [[ $data_directory != "" ]]; then cp -R ".blueprint/tmp/$n/$data_directory/"* ".blueprint/extensions/$identifier/private/"; fi

  #backup conf.yml
  cp ".blueprint/tmp/$n/conf.yml" ".blueprint/extensions/$identifier/private/.store/conf.yml"
  #backup Components.yml
  if [[ -f ".blueprint/tmp/$n/$dashboard_components/Components.yml" ]] \
  && [[ $dashboard_components != "" ]]; then
    cp ".blueprint/tmp/$n/$dashboard_components/Components.yml" ".blueprint/extensions/$identifier/private/.store/Components.yml"
  fi
  #backup Console.yml
  if [[ -f ".blueprint/tmp/$n/$data_console/Console.yml" ]] \
  && [[ $data_console != "" ]]; then
    cp ".blueprint/tmp/$n/$data_console/Console.yml" ".blueprint/extensions/$identifier/private/.store/Console.yml"
  fi

  # End creating data directory.

  ((PROGRESS_NOW++))

  # Link and create assets folder
  PRINT INFO "Linking and writing assets directory.."
  if [[ $DUPLICATE != "y" ]]; then
    # Create assets folder if the extension is not updating.
    mkdir .blueprint/extensions/"$identifier"/assets
  fi
  ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/assets" "$FOLDER/public/assets/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"

  ((PROGRESS_NOW++))

  if [[ $icon == "" ]]; then
    # use random placeholder icon if extension does not
    # come with an icon.
    icnNUM=$(( 1 + RANDOM % 5 ))
    cp ".blueprint/assets/Extensions/Defaults/$icnNUM.jpg" ".blueprint/extensions/$identifier/assets/icon.$ICON_EXT"
  else
    ICON_EXT="jpg"
    case "${icon}" in
      *.svg) local ICON_EXT="svg" ;;
      *.png) local ICON_EXT="png" ;;
      *.gif) local ICON_EXT="gif" ;;
      *.jpeg) local ICON_EXT="jpeg" ;;
      *.webp) local ICON_EXT="webp" ;;
      *) local ICON_EXT="jpg" ;;
    esac
    cp ".blueprint/tmp/$n/$icon" ".blueprint/extensions/$identifier/assets/icon.$ICON_EXT"
  fi;
  ICON="/assets/extensions/$identifier/icon.$ICON_EXT"

  ((PROGRESS_NOW++))

  if [[ $admin_css != "" ]]; then
    PRINT INFO "Cloning and linking admin css.."
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" ".blueprint/extensions/blueprint/assets/admin.extensions.css"
    echo -e "@import url(/assets/extensions/$identifier/admin.style.css);" >> ".blueprint/extensions/blueprint/assets/admin.extensions.css"
    cp ".blueprint/tmp/$n/$admin_css" ".blueprint/extensions/$identifier/assets/admin.style.css"
  fi
  if [[ $dashboard_css != "" ]]; then
    PRINT INFO "Cloning and linking dashboard css.."
    YARN="y"
    sed -i "s~@import url(./imported/$identifier.css);~~g" "resources/scripts/blueprint/css/extensions.css"
    echo -e "@import url(./imported/$identifier.css);" >> "resources/scripts/blueprint/css/extensions.css"
    cp ".blueprint/tmp/$n/$dashboard_css" "resources/scripts/blueprint/css/imported/$identifier.css"
  fi

  ((PROGRESS_NOW++))

  if [[ $name == *"~"* ]]; then        PRINT WARNING "'name' contains '~' and may result in an error.";fi
  if [[ $description == *"~"* ]]; then PRINT WARNING "'description' contains '~' and may result in an error.";fi
  if [[ $version == *"~"* ]]; then     PRINT WARNING "'version' contains '~' and may result in an error.";fi
  if [[ $ICON == *"~"* ]]; then        PRINT WARNING "'ICON' contains '~' and may result in an error.";fi
  if [[ $identifier == *"~"* ]]; then  PRINT WARNING "'identifier' contains '~' and may result in an error.";fi

  escaped_name=$(php_escape_string "$name")
  escaped_description=$(php_escape_string "$description")

  # Construct admin view
  sed -i \
    -e "s~\[name\]~$escaped_name~g" \
    -e "s~\[description\]~$escaped_description~g" \
    -e "s~\[version\]~$version~g" \
    -e "s~\[icon\]~$ICON~g" \
    -e "s~\[id\]~$identifier~g" \
    "$AdminBladeConstructor"
  sed -i -e "s/\\\\\\\\/\\\\/g" "$AdminBladeConstructor"
  if [[ $website != "" ]]; then
    sed -i \
      -e "s~\[website\]~$website~g" \
      -e "s~<!--\[web\] ~~g" \
      -e "s~ \[web\]-->~~g" \
      -e "s~\[webicon\]~$websiteiconclass~g" \
      "$AdminBladeConstructor"
  fi
  echo -e "$(<".blueprint/tmp/$n/$admin_view")\n@endsection" >> "$AdminBladeConstructor"

  # Construct admin controller
  if [[ $controller_type == "default" ]]; then sed -i "s~\[id\]~$identifier~g" "$AdminControllerConstructor"; fi

  # Construct ExtensionFS
  sed -i \
    -e "s~\[id\]~$identifier~g" \
    -e "s~\[id\^\]~${identifier^}~g" \
    "$ConfigExtensionFS"

  # Read final results.
  ADMINVIEW_RESULT=$(<"$AdminBladeConstructor")
  if [[ $controller_type == "default" ]]; then ADMINCONTROLLER_RESULT=$(<"$AdminControllerConstructor"); fi
  CONFIGEXTENSIONFS_RESULT=$(<"$ConfigExtensionFS")
  ADMINCONTROLLER_NAME="${identifier}ExtensionController.php"

  ((PROGRESS_NOW++))

  # Place admin extension view.
  PRINT INFO "Cloning admin view.."
  mkdir -p "resources/views/admin/extensions/$identifier"
  touch "resources/views/admin/extensions/$identifier/index.blade.php"
  echo "$ADMINVIEW_RESULT" > "resources/views/admin/extensions/$identifier/index.blade.php"

  # Place admin extension view controller.
  PRINT INFO "Cloning admin controller.."
  mkdir -p "app/Http/Controllers/Admin/Extensions/$identifier"
  touch "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  if [[ $controller_type == "default" ]]; then
    # Use custom view controller.
    touch "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
    echo "$ADMINCONTROLLER_RESULT" > "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  else
    # Use default extension controller.
    cp ".blueprint/tmp/$n/$admin_controller" "app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME"
  fi

  ((PROGRESS_NOW++))

  # Place dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then
    PRINT INFO "Cloning and linking dashboard wrapper.."
    if [[ -f "resources/views/blueprint/dashboard/wrappers/$identifier.blade.php" ]]; then rm "resources/views/blueprint/dashboard/wrappers/$identifier.blade.php"; fi
    if [[ ! -d ".blueprint/extensions/$identifier/wrappers" ]]; then mkdir ".blueprint/extensions/$identifier/wrappers"; fi
    cp ".blueprint/tmp/$n/$dashboard_wrapper" ".blueprint/extensions/$identifier/wrappers/dashboard.blade.php"
    ln -s -r -T ".blueprint/extensions/$identifier/wrappers/dashboard.blade.php" "$FOLDER/resources/views/blueprint/dashboard/wrappers/$identifier.blade.php"
  fi

  ((PROGRESS_NOW++))

  # Place admin wrapper
  if [[ $admin_wrapper != "" ]]; then
    PRINT INFO "Cloning and linking admin wrapper.."
    if [[ -f "resources/views/blueprint/admin/wrappers/$identifier.blade.php" ]]; then rm "resources/views/blueprint/admin/wrappers/$identifier.blade.php"; fi
    if [[ ! -d ".blueprint/extensions/$identifier/wrappers" ]]; then mkdir ".blueprint/extensions/$identifier/wrappers"; fi
    cp ".blueprint/tmp/$n/$admin_wrapper" ".blueprint/extensions/$identifier/wrappers/admin.blade.php"
    ln -s -r -T ".blueprint/extensions/$identifier/wrappers/admin.blade.php" "$FOLDER/resources/views/blueprint/admin/wrappers/$identifier.blade.php"
  fi

  ((PROGRESS_NOW++))

  # Create extension filesystem (ExtensionFS/PrivateFS)
  PRINT INFO "Creating and linking extension filesystem.."

  mkdir -p ".blueprint/extensions/$identifier/fs"
  {
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/fs" "$FOLDER/storage/extensions/$identifier"
    ln -s -r -T "$FOLDER/storage/extensions/$identifier" "$FOLDER/public/fs/$identifier"
    ln -s -r -T "$FOLDER/storage/.extensions/$identifier" "$FOLDER/.blueprint/extensions/$identifier/private"
  } 2>> "$BLUEPRINT__DEBUG"

  if [[ $DUPLICATE == "y" ]]; then
    sed -i \
      -e "s/\/\* ${identifier^}Start \*\/.*\/\* ${identifier^}End \*\///" \
      -e "s~/\* ${identifier^}Start \*/~~g" \
      -e "s~/\* ${identifier^}End \*/~~g" \
      "config/ExtensionFS.php"
  fi
  sed -i "s~\/\* blueprint/disks \*\/~/* blueprint/disks */$CONFIGEXTENSIONFS_RESULT~g" config/ExtensionFS.php

  ((PROGRESS_NOW++))

  # Create backup of generated values.
  mkdir -p \
    ".blueprint/extensions/$identifier/private/.store/build" \
    ".blueprint/extensions/$identifier/private/.store/build/config"
  cp "$__BuildDir/extensions/config/ExtensionFS.build.bak" ".blueprint/extensions/$identifier/private/.store/build/config/ExtensionFS.build"

  # Remove temporary build files.
  PRINT INFO "Cleaning up build files.."
  if [[ $controller_type == "default" ]]; then rm "$__BuildDir/extensions/controller.build.bak"; fi
  rm \
    "$AdminBladeConstructor" \
    "$ConfigExtensionFS"
  rm -R ".blueprint/tmp/$n"

  ((PROGRESS_NOW++))
  
  if [[ ( $F_developerForceMigrate == true ) && ( $dev == true ) ]]; then
    DeveloperForcedMigrate="true"
  fi

  if [[ ( $YARN == "y" ) && ( $F_developerIgnoreRebuild == true ) && ( $dev == true ) ]]; then
    IgnoreRebuild="true"
  fi

  if [[ ( $dev == "true" ) && ( $F_developerKeepApplicationCache == "true" ) ]]; then
    KeepApplicationCache="true"
  fi

  chown -R "$OWNERSHIP" "$FOLDER/.blueprint/extensions/$identifier/private"
  chmod --silent -R +x ".blueprint/extensions/"* 2>> "$BLUEPRINT__DEBUG"

  ((PROGRESS_NOW++))

  if [[ ( $F_developerIgnoreInstallScript == false ) || ( $dev != true ) ]]; then
    if [[ -f ".blueprint/extensions/$identifier/private/install.sh" ]]; then
      PRINT WARNING "Extension uses a custom installation script, proceed with caution."
      hide_progress
      chmod --silent +x ".blueprint/extensions/$identifier/private/install.sh" 2>> "$BLUEPRINT__DEBUG"

      # Run script while also parsing some useful variables for the install script to use.
      if $F_developerEscalateInstallScript; then
        ENGINE="$BLUEPRINT_ENGINE"         \
        EXTENSION_IDENTIFIER="$identifier" \
        EXTENSION_TARGET="$target"         \
        EXTENSION_VERSION="$version"       \
        PTERODACTYL_DIRECTORY="$FOLDER"    \
        BLUEPRINT_VERSION="$VERSION"       \
        BLUEPRINT_DEVELOPER="$dev"         \
        bash .blueprint/extensions/"$identifier"/private/install.sh
      else
        su "$WEBUSER" -s "$USERSHELL" -c "
          cd \"$FOLDER\";
          ENGINE=\"$BLUEPRINT_ENGINE\"         \
          EXTENSION_IDENTIFIER=\"$identifier\" \
          EXTENSION_TARGET=\"$target\"         \
          EXTENSION_VERSION=\"$version\"       \
          PTERODACTYL_DIRECTORY=\"$FOLDER\"    \
          BLUEPRINT_VERSION=\"$VERSION\"       \
          BLUEPRINT_DEVELOPER=\"$dev\"         \
          bash .blueprint/extensions/$identifier/private/install.sh
        "
      fi
      echo -e "\e[0m\x1b[0m\033[0m"
    fi
  fi

  ((PROGRESS_NOW++))

  if [[ $DUPLICATE != "y" ]]; then
    PRINT INFO "Adding '$identifier' to active extensions list.."
    printf "%s," "${identifier}" >> ".blueprint/extensions/blueprint/private/db/installed_extensions"
  fi

  if [[ $dev != true ]]; then
    if [[ $InstalledExtensions == "" ]]; then InstalledExtensions="$identifier"; else InstalledExtensions+=", $identifier"; fi
    
    # Unset variables
    PRINT INFO "Unsetting variables.."
    unsetVariables
  else
    BuiltExtensions="$identifier"
  fi

  ((PROGRESS_NOW++))
}

Command() {
  if [[ $1 == "" ]]; then PRINT FATAL "Expected at least 1 argument but got 0.";exit 2;fi
  if [[ ( $1 == "./"* ) || ( $1 == "../"* ) || ( $1 == "/"* ) ]]; then PRINT FATAL "Cannot import extensions from external paths.";exit 2;fi

  PRINT INFO "Searching and validating framework dependencies.."
  # Check if required programs and libraries are installed.
  depend

  # Install selected extensions
  current=0
  extensions="$*"
  total=$(echo "$extensions" | wc -w)

  local EXTENSIONS_STEPS=34 #Total amount of steps per extension
  local FINISH_STEPS=6 #Total amount of finalization steps

  export PROGRESS_TOTAL="$(("$FINISH_STEPS" + "$EXTENSIONS_STEPS" * "$total"))"
  export PROGRESS_NOW=0

  for extension in $extensions; do
    (( current++ ))
    InstallExtension "$extension" "$current" "$total"
    export PROGRESS_NOW="$(("$EXTENSIONS_STEPS" * "$current"))"
  done

  if [[ ( $InstalledExtensions != "" ) || ( $BuiltExtensions != "" ) ]]; then
    ((PROGRESS_NOW++))

    # Finalize transaction
    PRINT INFO "Finalizing transaction.."

    if [[ ( $YARN == "y" ) && ( $IgnoreRebuild != "true" ) ]]; then
      PRINT INFO "Rebuilding panel assets.."
      hide_progress
      cd "$FOLDER" || cdhalt
      yarn run build:production --progress
    fi

    ((PROGRESS_NOW++))

    # Link filesystems
    PRINT INFO "Linking filesystems.."
    php artisan storage:link &>> "$BLUEPRINT__DEBUG"

    ((PROGRESS_NOW++))

    # Flush cache.
    PRINT INFO "Flushing view, config and route cache.."
    {
      php artisan view:cache
      php artisan config:cache
      php artisan route:clear
      if [[ $KeepApplicationCache != "true" ]]; then php artisan cache:clear; fi
      php artisan bp:cache
      php artisan queue:restart
    } &>> "$BLUEPRINT__DEBUG"

    ((PROGRESS_NOW++))

    # Make sure all files have correct permissions.
    PRINT INFO "Changing Pterodactyl file ownership to '$OWNERSHIP'.."
    find "$FOLDER/" \
    -path "$FOLDER/node_modules" -prune \
    -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"

    ((PROGRESS_NOW++))

    # Database migrations
    if [[ ( $dbmigrations == "true" ) && ( $DOCKER != "y" ) ]]; then
      PRINT INFO "Running database migrations.."
      hide_progress
      php artisan migrate --force
    fi

    ((PROGRESS_NOW++))

    if [[ $BuiltExtensions == "" ]]; then
      CorrectPhrasing="have"
      if [[ $total = 1 ]]; then CorrectPhrasing="has"; fi
      PRINT SUCCESS "$InstalledExtensions $CorrectPhrasing been installed."
      hide_progress
    else
      PRINT SUCCESS "$BuiltExtensions has been built."
      hide_progress
    fi

    exit 0
  fi

  hide_progress
  exit 1
}