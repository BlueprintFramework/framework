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
  local requests_controllers="$conf_requests_controllers"; #(optional)
  local requests_routers="$conf_requests_routers"; #(optional)
  local requests_routers_application="$conf_requests_routers_application"; #(optional)
  local requests_routers_client="$conf_requests_routers_client"; #(optional)
  local requests_routers_web="$conf_requests_routers_web"; #(optional)

  local database_migrations="$conf_database_migrations"; #(optional)


  # assign config aliases
  if [[ $requests_routers_application == "" ]] \
  && [[ $requests_routers_client      == "" ]] \
  && [[ $requests_routers_web         == "" ]] \
  && [[ $requests_routers             != "" ]]; then
    local requests_routers_application="$requests_routers"
  fi

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
  || [[ ( $requests_controllers         == "/"* ) || ( $requests_controllers         == *"/.."* ) || ( $requests_controllers         == *"../"* ) || ( $requests_controllers         == *"/../"* ) || ( $requests_controllers         == *"~"* ) || ( $requests_controllers         == *"\\"* ) ]] \
  || [[ ( $requests_routers_application == "/"* ) || ( $requests_routers_application == *"/.."* ) || ( $requests_routers_application == *"../"* ) || ( $requests_routers_application == *"/../"* ) || ( $requests_routers_application == *"~"* ) || ( $requests_routers_application == *"\\"* ) ]] \
  || [[ ( $requests_routers_client      == "/"* ) || ( $requests_routers_client      == *"/.."* ) || ( $requests_routers_client      == *"../"* ) || ( $requests_routers_client      == *"/../"* ) || ( $requests_routers_client      == *"~"* ) || ( $requests_routers_client      == *"\\"* ) ]] \
  || [[ ( $requests_routers_web         == "/"* ) || ( $requests_routers_web         == *"/.."* ) || ( $requests_routers_web         == *"../"* ) || ( $requests_routers_web         == *"/../"* ) || ( $requests_routers_web         == *"~"* ) || ( $requests_routers_web         == *"\\"* ) ]] \
  || [[ ( $database_migrations          == "/"* ) || ( $database_migrations          == *"/.."* ) || ( $database_migrations          == *"../"* ) || ( $database_migrations          == *"/../"* ) || ( $database_migrations          == *"~"* ) || ( $database_migrations          == *"\\"* ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Config file paths cannot escape the extension bundle."
    return 1
  fi

  # prevent potentional problems during installation due to wrongly defined folders
  if [[ ( $dashboard_components == *"/" ) ]] \
  || [[ ( $data_directory == *"/"       ) ]] \
  || [[ ( $data_public == *"/"          ) ]] \
  || [[ ( $data_console == *"/"         ) ]] \
  || [[ ( $requests_views == *"/"       ) ]] \
  || [[ ( $requests_controllers == *"/" ) ]] \
  || [[ ( $database_migrations == *"/"  ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Directory paths in conf.yml should not end with a slash."
    return 1
  fi

  # check if extension still has placeholder values
  if [[ ( $name    == "[name]" ) || ( $identifier == "[identifier]" ) || ( $description == "[description]" ) ]] \
  || [[ ( $version == "[ver]"  ) || ( $target     == "[version]"    ) || ( $author      == "[author]"      ) ]]; then
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension contains placeholder values which need to be replaced."
    return 1
  fi

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

  # Assign variables to extension flags.
  PRINT INFO "Reading and assigning extension flags.."
  assignflags

  # Force http/https url scheme for extension website urls when needed.
  if [[ $website != "" ]]; then
    if [[ ( $website != "https://"* ) && ( $website != "http://"* ) ]] \
    && [[ ( $website != "/"*        ) && ( $website != "."*       ) ]]; then
      local website="http://${conf_info_website}"
      local conf_info_website="${website}"
    fi


    # Change link icon depending on website url.
    local websiteiconclass="bx bx-link-external"

    # git
    if [[ $website == *"://github.com/"*        ]] || [[ $website == *"://www.github.com/"*        ]] \
    || [[ $website == *"://github.com"          ]] || [[ $website == *"://www.github.com"          ]] \
    || [[ $website == *"://gitlab.com/"*        ]] || [[ $website == *"://www.gitlab.com/"*        ]] \
    || [[ $website == *"://gitlab.com"          ]] || [[ $website == *"://www.gitlab.com"          ]]; then local websiteiconclass="bx bx-git-branch";fi
    # marketplaces
    if [[ $website == *"://sourcexchange.net/"* ]] || [[ $website == *"://www.sourcexchange.net/"* ]] \
    || [[ $website == *"://sourcexchange.net"   ]] || [[ $website == *"://www.sourcexchange.net"   ]] \
    || [[ $website == *"://builtbybit.com/"*    ]] || [[ $website == *"://www.builtbybit.com/"*    ]] \
    || [[ $website == *"://builtbybit.com"      ]] || [[ $website == *"://www.builtbybit.com"      ]] \
    || [[ $website == *"://builtbyb.it/"*       ]] || [[ $website == *"://www.builtbyb.it/"*       ]] \
    || [[ $website == *"://builtbyb.it"         ]] || [[ $website == *"://www.builtbyb.it"         ]] \
    || [[ $website == *"://bbyb.it/"*           ]] || [[ $website == *"://www.bbyb.it/"*           ]] \
    || [[ $website == *"://bbyb.it"             ]] || [[ $website == *"://www.bbyb.it"             ]]; then local websiteiconclass="bx bx-store";fi
    # discord
    if [[ $website == *"://discord.com/"*       ]] || [[ $website == *"://www.discord.com/"*       ]] \
    || [[ $website == *"://discord.com"         ]] || [[ $website == *"://www.discord.com"         ]] \
    || [[ $website == *"://discord.gg/"*        ]] || [[ $website == *"://www.discord.gg/"*        ]] \
    || [[ $website == *"://discord.gg"          ]] || [[ $website == *"://www.discord.gg"          ]]; then local websiteiconclass="bx bxl-discord-alt";fi
    # patreon
    if [[ $website == *"://patreon.com/"*       ]] || [[ $website == *"://www.patreon.com/"*       ]] \
    || [[ $website == *"://patreon.com"         ]] || [[ $website == *"://www.patreon.com"         ]]; then local websiteiconclass="bx bxl-patreon";fi
    # reddit
    if [[ $website == *"://reddit.com/"*        ]] || [[ $website == *"://www.reddit.com/"*        ]] \
    || [[ $website == *"://reddit.com"          ]] || [[ $website == *"://www.reddit.com"          ]]; then local websiteiconclass="bx bxl-reddit";fi
    # trello
    if [[ $website == *"://trello.com/"*        ]] || [[ $website == *"://www.trello.com/"*        ]] \
    || [[ $website == *"://trello.com"          ]] || [[ $website == *"://www.trello.com"          ]]; then local websiteiconclass="bx bxl-trello";fi
  fi

  if [[ $dev == true ]]; then
    mv ".blueprint/tmp/$n" ".blueprint/tmp/$identifier"
    n=$identifier
  fi

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
              \
              -e "s~{identifier^}~${identifier^}~g" \
              -e "s~{identifier!}~${identifier^^}~g" \
              -e "s~{name!}~${name^^}~g" \
              -e "s~{root/public}~$FOLDER/.blueprint/extensions/$identifier/public~g" \
              -e "s~{root/data}~$FOLDER/.blueprint/extensions/$identifier/private~g" \
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
    [[ ( ! -d ".blueprint/tmp/$n/$requests_controllers"         ) && ( ${requests_controllers} != ""         ) ]] ||    # folder: requests_controllers         (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_application" ) && ( ${requests_routers_application} != "" ) ]] ||    # file:   requests_routers_application (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_client"      ) && ( ${requests_routers_client} != ""      ) ]] ||    # file:   requests_routers_client      (optional)
    [[ ( ! -f ".blueprint/tmp/$n/$requests_routers_web"         ) && ( ${requests_routers_web} != ""         ) ]] ||    # file:   requests_routers_web         (optional)
    [[ ( ! -d ".blueprint/tmp/$n/$database_migrations"          ) && ( ${database_migrations} != ""          ) ]];then  # folder: database_migrations          (optional)
    rm -R ".blueprint/tmp/$n"
    PRINT FATAL "Extension configuration points towards one or more files that do not exist."
    return 1
  fi

  # Validate custom script paths.
  if [[ $F_hasInstallScript == true || $F_hasRemovalScript == true || $F_hasExportScript == true ]]; then
    if [[ $data_directory == "" ]]; then
      rm -R ".blueprint/tmp/$n"
      PRINT FATAL "Install/Remove/Export script requires private folder to be enabled."
      return 1
    fi

    if [[ $F_hasInstallScript == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/install.sh" ]] \
    || [[ $F_hasRemovalScript == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/remove.sh"  ]] \
    || [[ $F_hasExportScript  == true ]] && [[ ! -f ".blueprint/tmp/$n/$data_directory/export.sh"  ]]; then
      rm -R ".blueprint/tmp/$n"
      PRINT FATAL "Install/Remove/Export script could not be found or detected, even though enabled."
      return 1
    fi
  fi

  # Place database migrations.
  if [[ $database_migrations != "" ]]; then
    PRINT INFO "Cloning database migration files.."
    cp -R ".blueprint/tmp/$n/$database_migrations/"* "database/migrations/" 2>> "$BLUEPRINT__DEBUG"
    dbmigrations="true"
  fi

  # Place views directory.
  if [[ $requests_views != "" ]]; then
    PRINT INFO "Cloning and linking views directory.."
    mkdir -p ".blueprint/extensions/$identifier/views"
    cp -R ".blueprint/tmp/$n/$requests_views/"* ".blueprint/extensions/$identifier/views/" 2>> "$BLUEPRINT__DEBUG"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/views" "$FOLDER/resources/views/blueprint/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"
  fi

  # Place controllers directory.
  if [[ $requests_controllers != "" ]]; then
    PRINT INFO "Cloning and linking controllers directory.."
    mkdir -p ".blueprint/extensions/$identifier/controllers"
    cp -R ".blueprint/tmp/$n/$requests_controllers/"* ".blueprint/extensions/$identifier/controllers/" 2>> "$BLUEPRINT__DEBUG"
    ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/controllers" "$FOLDER/app/BlueprintFramework/Extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"
  fi

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
            if [[ $CONSOLE_ENTRY_INTE == "everyMinute"         ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyMinute";         fi
            if [[ $CONSOLE_ENTRY_INTE == "everyTwoMinutes"     ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyTwoMinutes";     fi
            if [[ $CONSOLE_ENTRY_INTE == "everyThreeMinutes"   ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyThreeMinutes";   fi
            if [[ $CONSOLE_ENTRY_INTE == "everyFourMinutes"    ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyFourMinutes";    fi
            if [[ $CONSOLE_ENTRY_INTE == "everyFiveMinutes"    ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyFiveMinutes";    fi
            if [[ $CONSOLE_ENTRY_INTE == "everyTenMinutes"     ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyTenMinutes";     fi
            if [[ $CONSOLE_ENTRY_INTE == "everyFifteenMinutes" ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyFifteenMinutes"; fi
            if [[ $CONSOLE_ENTRY_INTE == "everyThirtyMinutes"  ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "everyThirtyMinutes";  fi
            if [[ $CONSOLE_ENTRY_INTE == "hourly"              ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "hourly";              fi
            if [[ $CONSOLE_ENTRY_INTE == "daily"               ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily";               fi
            if [[ $CONSOLE_ENTRY_INTE == "weekdays"            ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->weekdays";   fi
            if [[ $CONSOLE_ENTRY_INTE == "weekends"            ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->weekends";   fi
            if [[ $CONSOLE_ENTRY_INTE == "sundays"             ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->sundays";    fi
            if [[ $CONSOLE_ENTRY_INTE == "mondays"             ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->mondays";    fi
            if [[ $CONSOLE_ENTRY_INTE == "tuesdays"            ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->tuesdays";   fi
            if [[ $CONSOLE_ENTRY_INTE == "wednesdays"          ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->wednesdays"; fi
            if [[ $CONSOLE_ENTRY_INTE == "thursdays"           ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->thursdays";  fi
            if [[ $CONSOLE_ENTRY_INTE == "fridays"             ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->fridays";    fi
            if [[ $CONSOLE_ENTRY_INTE == "saturdays"           ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "daily()->saturdays";  fi
            if [[ $CONSOLE_ENTRY_INTE == "weekly"              ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "weekly";              fi
            if [[ $CONSOLE_ENTRY_INTE == "monthly"             ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "monthly";             fi
            if [[ $CONSOLE_ENTRY_INTE == "quarterly"           ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "quarterly";           fi
            if [[ $CONSOLE_ENTRY_INTE == "yearly"              ]]; then SCHEDULE_SET="true"; ApplyConsoleInterval "yearly";              fi
            
            if [[ "$SCHEDULE_SET" == "false" ]]; then
              sed -i "s~\[SCHEDULE\]~cron('$CONSOLE_ENTRY_INTE')~g" "$ScheduleConstructor"
            fi
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
            [[ ${1} == *".ts"  ]] ||
            [[ ${1} == *".jsx" ]] ||
            [[ ${1} == *".js"  ]]; then
            rm -R ".blueprint/tmp/$n"
            PRINT FATAL "Component paths may not end with a file extension."
            return 1
          fi

          # validate path
          if [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.tsx" ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.ts"  ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.jsx" ]] &&
            [[ ! -f ".blueprint/tmp/$n/$dashboard_components/${1}.js"  ]]; then
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
      PLACE_REACT "$Components_Dashboard_BeforeContent" "Dashboard/BeforeContent.tsx" "$OldComponents_Dashboard_BeforeContent"
      PLACE_REACT "$Components_Dashboard_AfterContent" "Dashboard/AfterContent.tsx" "$OldComponents_Dashboard_AfterContent"
      PLACE_REACT "$Components_Dashboard_ServerRow_BeforeEntryName" "Dashboard/ServerRow/BeforeEntryName.tsx" "$OldComponents_Dashboard_ServerRow_BeforeEntryName"
      PLACE_REACT "$Components_Dashboard_ServerRow_AfterEntryName" "Dashboard/ServerRow/AfterEntryName.tsx" "$OldComponents_Dashboard_ServerRow_AfterEntryName"
      PLACE_REACT "$Components_Dashboard_ServerRow_BeforeEntryDescription" "Dashboard/ServerRow/BeforeEntryDescription.tsx" "$OldComponents_Dashboard_ServerRow_BeforeEntryDescription"
      PLACE_REACT "$Components_Dashboard_ServerRow_AfterEntryDescription" "Dashboard/ServerRow/AfterEntryDescription.tsx" "$OldComponents_Dashboard_ServerRow_AfterEntryDescription"
      PLACE_REACT "$Components_Dashboard_ServerRow_ResourceLimits" "Dashboard/ServerRow/ResourceLimits.tsx" "$OldComponents_Dashboard_ServerRow_ResourceLimits"

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

        sed -i "s~\[id\^]~""${identifier^}""~g" $ImportConstructor
        sed -i "s~\[id\^]~""${identifier^}""~g" $AccountRouteConstructor
        sed -i "s~\[id\^]~""${identifier^}""~g" $ServerRouteConstructor

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

          echo -e "NAME: $COMPONENTS_ROUTE_NAME\nPATH: $COMPONENTS_ROUTE_PATH\nTYPE: $COMPONENTS_ROUTE_TYPE\nCOMP: $COMPONENTS_ROUTE_COMP\nIDEN: $COMPONENTS_ROUTE_IDEN" >> "$BLUEPRINT__DEBUG"


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
            if [[ $COMPONENTS_ROUTE_PERM != "" ]]; then PRINT WARNING "Route permission declarations have no effect on account navigation routes."; fi

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

  # Prepare build files.
  AdminControllerConstructor="$__BuildDir/extensions/controller.build.bak"
  AdminBladeConstructor="$__BuildDir/extensions/admin.blade.php.bak"
  AdminRouteConstructor="$__BuildDir/extensions/route.php.bak"
  AdminButtonConstructor="$__BuildDir/extensions/button.blade.php.bak"
  ConfigExtensionFS="$__BuildDir/extensions/config/ExtensionFS.build.bak"
  {
    if [[ $controller_type == "default" ]]; then cp "$__BuildDir/extensions/controller.build" "$AdminControllerConstructor"; fi
    cp "$__BuildDir/extensions/admin.blade.php" "$AdminBladeConstructor"
    cp "$__BuildDir/extensions/route.php" "$AdminRouteConstructor"
    cp "$__BuildDir/extensions/button.blade.php" "$AdminButtonConstructor"
    cp "$__BuildDir/extensions/config/ExtensionFS.build" "$ConfigExtensionFS"
  } 2>> "$BLUEPRINT__DEBUG"


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


  # Link and create assets folder
  PRINT INFO "Linking and writing assets directory.."
  if [[ $DUPLICATE != "y" ]]; then
    # Create assets folder if the extension is not updating.
    mkdir .blueprint/extensions/"$identifier"/assets
  fi
  ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/assets" "$FOLDER/public/assets/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"

  ICON_EXT="jpg"
  if [[ $icon == "" ]]; then
    # use random placeholder icon if extension does not
    # come with an icon.
    icnNUM=$(( 1 + RANDOM % 5 ))
    cp ".blueprint/assets/Extensions/Defaults/$icnNUM.jpg" ".blueprint/extensions/$identifier/assets/icon.$ICON_EXT"
  else
    if [[ $icon == *".svg" ]]; then ICON_EXT='svg'; fi
    if [[ $icon == *".png" ]]; then ICON_EXT='png'; fi
    if [[ $icon == *".gif" ]]; then ICON_EXT='gif'; fi
    if [[ $icon == *".jpeg" ]]; then ICON_EXT='jpeg'; fi
    if [[ $icon == *".webp" ]]; then ICON_EXT='webp'; fi
    cp ".blueprint/tmp/$n/$icon" ".blueprint/extensions/$identifier/assets/icon.$ICON_EXT"
  fi;
  ICON="/assets/extensions/$identifier/icon.$ICON_EXT"

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

  if [[ $name == *"~"* ]]; then        PRINT WARNING "'name' contains '~' and may result in an error.";fi
  if [[ $description == *"~"* ]]; then PRINT WARNING "'description' contains '~' and may result in an error.";fi
  if [[ $version == *"~"* ]]; then     PRINT WARNING "'version' contains '~' and may result in an error.";fi
  if [[ $ICON == *"~"* ]]; then        PRINT WARNING "'ICON' contains '~' and may result in an error.";fi
  if [[ $identifier == *"~"* ]]; then  PRINT WARNING "'identifier' contains '~' and may result in an error.";fi

  # Construct admin button
  sed -i \
    -e "s~\[name\]~$name~g" \
    -e "s~\[version\]~$version~g" \
    -e "s~\[id\]~$identifier~g" \
    -e "s~\[icon\]~$ICON~g" \
    "$AdminButtonConstructor"

  # Construct admin view
  sed -i \
    -e "s~\[name\]~$name~g" \
    -e "s~\[description\]~$description~g" \
    -e "s~\[version\]~$version~g" \
    -e "s~\[icon\]~$ICON~g" \
    -e "s~\[id\]~$identifier~g" \
    "$AdminBladeConstructor"
  if [[ $website != "" ]]; then
    sed -i \
      -e "s~\[website\]~$website~g" \
      -e "s~<!--\[web\] ~~g" \
      -e "s~ \[web\]-->~~g" \
      -e "s~\[webicon\]~$websiteiconclass~g" \
      "$AdminBladeConstructor"
  fi
  echo -e "$(<".blueprint/tmp/$n/$admin_view")\n@endsection" >> "$AdminBladeConstructor"

  # Construct admin route
  sed -i "s~\[id\]~$identifier~g" "$AdminRouteConstructor"

  # Construct admin controller
  if [[ $controller_type == "default" ]]; then sed -i "s~\[id\]~$identifier~g" "$AdminControllerConstructor"; fi

  # Construct ExtensionFS
  sed -i \
    -e "s~\[id\]~$identifier~g" \
    -e "s~\[id\^\]~${identifier^}~g" \
    "$ConfigExtensionFS"

  # Read final results.
  ADMINVIEW_RESULT=$(<"$AdminBladeConstructor")
  ADMINROUTE_RESULT=$(<"$AdminRouteConstructor")
  ADMINBUTTON_RESULT=$(<"$AdminButtonConstructor")
  if [[ $controller_type == "default" ]]; then ADMINCONTROLLER_RESULT=$(<"$AdminControllerConstructor"); fi
  CONFIGEXTENSIONFS_RESULT=$(<"$ConfigExtensionFS")
  ADMINCONTROLLER_NAME="${identifier}ExtensionController.php"

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

  if [[ $DUPLICATE != "y" ]]; then
    # Place admin route if extension is not updating.
    PRINT INFO "Editing admin routes.."
    { echo "// $identifier:start";
    echo "$ADMINROUTE_RESULT";
    echo // "$identifier":stop; } >> "routes/blueprint.php"
  else
    # Replace old extensions page button if extension is updating.
    sed -n -i "/<!--@$identifier:s@-->/{p; :a; N; /<!--@$identifier:e@-->/!ba; s/.*\n//}; p" "resources/views/admin/extensions.blade.php"
    sed -i \
      -e "s~<!--@$identifier:s@-->~~g" \
      -e "s~<!--@$identifier:e@-->~~g" \
      "resources/views/admin/extensions.blade.php"
  fi
  sed -i "s~<!-- \[entryplaceholder\] -->~<!--@$identifier:s@-->\n$ADMINBUTTON_RESULT\n<!--@$identifier:e@-->\n<!-- \[entryplaceholder\] -->~g" "resources/views/admin/extensions.blade.php"

  # Place dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then
    PRINT INFO "Cloning and linking dashboard wrapper.."
    if [[ -f "resources/views/blueprint/dashboard/wrappers/$identifier.blade.php" ]]; then rm "resources/views/blueprint/dashboard/wrappers/$identifier.blade.php"; fi
    if [[ ! -d ".blueprint/extensions/$identifier/wrappers" ]]; then mkdir ".blueprint/extensions/$identifier/wrappers"; fi
    cp ".blueprint/tmp/$n/$dashboard_wrapper" ".blueprint/extensions/$identifier/wrappers/dashboard.blade.php"
    ln -s -r -T ".blueprint/extensions/$identifier/wrappers/dashboard.blade.php" "$FOLDER/resources/views/blueprint/dashboard/wrappers/$identifier.blade.php"
  fi

  # Place admin wrapper
  if [[ $admin_wrapper != "" ]]; then
    PRINT INFO "Cloning and linking admin wrapper.."
    if [[ -f "resources/views/blueprint/admin/wrappers/$identifier.blade.php" ]]; then rm "resources/views/blueprint/admin/wrappers/$identifier.blade.php"; fi
    if [[ ! -d ".blueprint/extensions/$identifier/wrappers" ]]; then mkdir ".blueprint/extensions/$identifier/wrappers"; fi
    cp ".blueprint/tmp/$n/$admin_wrapper" ".blueprint/extensions/$identifier/wrappers/admin.blade.php"
    ln -s -r -T ".blueprint/extensions/$identifier/wrappers/admin.blade.php" "$FOLDER/resources/views/blueprint/admin/wrappers/$identifier.blade.php"
  fi

  # Create extension filesystem (ExtensionFS)
  PRINT INFO "Creating and linking extension filesystem.."
  mkdir -p ".blueprint/extensions/$identifier/fs"
  ln -s -r -T "$FOLDER/.blueprint/extensions/$identifier/fs" "$FOLDER/storage/extensions/$identifier" 2>> "$BLUEPRINT__DEBUG"
  ln -s -r -T "$FOLDER/storage/extensions/$identifier" "$FOLDER/public/fs/$identifier" 2>> "$BLUEPRINT__DEBUG"
  if [[ $DUPLICATE == "y" ]]; then
    sed -i \
      -e "s/\/\* ${identifier^}Start \*\/.*\/\* ${identifier^}End \*\///" \
      -e "s~/\* ${identifier^}Start \*/~~g" \
      -e "s~/\* ${identifier^}End \*/~~g" \
      "config/ExtensionFS.php"
  fi
  sed -i "s~\/\* blueprint/disks \*\/~/* blueprint/disks */$CONFIGEXTENSIONFS_RESULT~g" config/ExtensionFS.php

  # Create backup of generated values.
  mkdir -p \
    ".blueprint/extensions/$identifier/private/.store/build" \
    ".blueprint/extensions/$identifier/private/.store/build/config"
  cp "$__BuildDir/extensions/route.php.bak" ".blueprint/extensions/$identifier/private/.store/build/route.php"
  cp "$__BuildDir/extensions/config/ExtensionFS.build.bak" ".blueprint/extensions/$identifier/private/.store/build/config/ExtensionFS.build"

  # Remove temporary build files.
  PRINT INFO "Cleaning up build files.."
  if [[ $controller_type == "default" ]]; then rm "$__BuildDir/extensions/controller.build.bak"; fi
  rm \
    "$AdminBladeConstructor" \
    "$AdminRouteConstructor" \
    "$AdminButtonConstructor" \
    "$ConfigExtensionFS"
  rm -R ".blueprint/tmp/$n"

  
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

  if [[ ( $F_developerIgnoreInstallScript == false ) || ( $dev != true ) ]]; then
    if $F_hasInstallScript; then
      PRINT WARNING "Extension uses a custom installation script, proceed with caution."
      chmod --silent +x ".blueprint/extensions/$identifier/private/install.sh" 2>> "$BLUEPRINT__DEBUG"

      # Run script while also parsing some useful variables for the install script to use.
      if $F_developerEscalateInstallScript; then
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

  if [[ $DUPLICATE != "y" ]]; then
    PRINT INFO "Adding '$identifier' to active extensions list.."
    echo "${identifier}," >> ".blueprint/extensions/blueprint/private/db/installed_extensions"
  fi

  if [[ $dev != true ]]; then
    if [[ $InstalledExtensions == "" ]]; then InstalledExtensions="$identifier"; else InstalledExtensions+=", $identifier"; fi
    
    # Unset variables
    PRINT INFO "Unsetting variables.."
    unsetVariables
  else
    BuiltExtensions="$identifier"
  fi
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
  for extension in $extensions; do
    (( current++ ))
    InstallExtension "$extension" "$current" "$total"
  done

  if [[ ( $InstalledExtensions != "" ) || ( $BuiltExtensions != "" ) ]]; then
    # Finalize transaction
    PRINT INFO "Finalizing transaction.."

    if [[ ( $YARN == "y" ) && ( $IgnoreRebuild != "true" ) ]]; then
      PRINT INFO "Rebuilding panel assets.."
      yarn run build:production --progress
    fi

    # Link filesystems
    PRINT INFO "Linking filesystems.."
    php artisan storage:link &>> "$BLUEPRINT__DEBUG"

    # Flush cache.
    PRINT INFO "Flushing view, config and route cache.."
    {
      php artisan view:cache
      php artisan config:cache
      php artisan route:clear
      if [[ $KeepApplicationCache != "true" ]]; then php artisan cache:clear; fi
      php artisan bp:cache
    } &>> "$BLUEPRINT__DEBUG"

    # Make sure all files have correct permissions.
    PRINT INFO "Changing Pterodactyl file ownership to '$OWNERSHIP'.."
    find "$FOLDER/" \
    -path "$FOLDER/node_modules" -prune \
    -o -exec chown "$OWNERSHIP" {} + &>> "$BLUEPRINT__DEBUG"

    # Database migrations
    if [[ ( $dbmigrations == "true" ) && ( $DOCKER != "y" ) ]] \
    || [[ ( $DeveloperForcedMigrate == "true" ) && ( $dev == true ) ]]; then

      if [[ ( $DeveloperForcedMigrate != "true" ) || ( $dev != true ) ]]; then
        PRINT INPUT "Would you like to migrate your database? (Y/n)"
        read -r YN
      fi

      if [[ ( $YN == "y"* ) || ( $YN == "Y"* ) || ( $YN == "" ) ]] || [[ ( $DeveloperForcedMigrate == "true" ) && ( $dev == true ) ]]; then
        PRINT INFO "Running database migrations.."
        php artisan migrate --force
      else
        PRINT INFO "Database migrations have been skipped."
      fi
    fi

    if [[ $BuiltExtensions == "" ]]; then
      sendTelemetry "FINISH_EXTENSION_INSTALLATION" >> "$BLUEPRINT__DEBUG"
      CorrectPhrasing="have"
      if [[ $total = 1 ]]; then CorrectPhrasing="has"; fi
      PRINT SUCCESS "$InstalledExtensions $CorrectPhrasing been installed."
    else
      sendTelemetry "BUILD_DEVELOPMENT_EXTENSION" >> "$BLUEPRINT__DEBUG"
      PRINT SUCCESS "$BuiltExtensions has been built."
    fi

    exit 0
  else
    exit 1
  fi
}