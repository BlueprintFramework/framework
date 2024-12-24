#!/bin/bash

RemoveExtension() {
  if [[ $USER_CONFIRMED_REMOVAL != "yes" ]]; then
    PRINT INPUT "Do you want to proceed with this transaction? Some files might not be removed properly. (y/N)"
    hide_progress
    read -r YN
    if [[ ( ( ${YN} != "y"* ) && ( ${YN} != "Y"* ) ) || ( ( ${YN} == "" ) ) ]]; then
      PRINT INFO "Extension removal cancelled."
      hide_progress
      exit 1
    fi
  fi
  export USER_CONFIRMED_REMOVAL="yes"

  PRINT INFO "\x1b[34;mRemoving $1...\x1b[0m \x1b[37m($current/$total)\x1b[0m"

  # Check if the extension is installed.
  EXTENSION=$1
  if [[ $EXTENSION == *".blueprint" ]]; then EXTENSION="${EXTENSION::-10}"; fi
  set -- "${@:1:2}" "$EXTENSION" "${@:4}"

  if [[ $(cat ".blueprint/extensions/blueprint/private/db/installed_extensions") != *"$EXTENSION,"* ]]; then
    PRINT FATAL "'$EXTENSION' is not installed or detected."
    return 2
  fi

  ((PROGRESS_NOW++))

  if [[ -f ".blueprint/extensions/$EXTENSION/private/.store/conf.yml" ]]; then
    eval "$(parse_yaml ".blueprint/extensions/$EXTENSION/private/.store/conf.yml" conf_)"
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


    # Add backwards compatibility
    if [[ $conf_requests_controllers != "" ]]; then
      local requests_app="$conf_requests_controllers"
      PRINT WARNING "Config value 'requests_controllers' is deprecated, use 'requests_app' instead."
    fi
  else
    PRINT FATAL "Extension configuration file not found or detected."
    return 1
  fi

  ((PROGRESS_NOW++))

  if [[ $current == "1" ]]; then
    # Only needed for one extension
    PRINT INFO "Searching and validating framework dependencies.."
    depend
  fi

  ((PROGRESS_NOW++))

  # Assign variables to extension flags.
  PRINT INFO "Reading and assigning extension flags.."
  assignflags

  ((PROGRESS_NOW++))

  if [[ -f ".blueprint/extensions/$identifier/private/remove.sh" ]]; then
    PRINT WARNING "Extension uses a custom removal script, proceed with caution."
    hide_progress
    chmod +x ".blueprint/extensions/$identifier/private/remove.sh"

    # Run script while also parsing some useful variables for the uninstall script to use.
    su "$WEBUSER" -s "$USERSHELL" -c "
        cd \"$FOLDER\";
        ENGINE=\"$BLUEPRINT_ENGINE\"         \
        EXTENSION_IDENTIFIER=\"$identifier\" \
        EXTENSION_TARGET=\"$target\"         \
        EXTENSION_VERSION=\"$version\"       \
        PTERODACTYL_DIRECTORY=\"$FOLDER\"    \
        BLUEPRINT_VERSION=\"$VERSION\"       \
        bash .blueprint/extensions/$identifier/private/remove.sh
      "

    echo -e "\e[0m\x1b[0m\033[0m"
  fi

  ((PROGRESS_NOW++))

  # Remove admin view and controller
  PRINT INFO "Removing admin view and controller.."
  rm -r \
    "resources/views/admin/extensions/$identifier" \
    "app/Http/Controllers/Admin/Extensions/$identifier"

  ((PROGRESS_NOW++))

  # Remove admin css
  if [[ $admin_css != "" ]]; then
    PRINT INFO "Removing and unlinking admin css.."
    sed -i "s~@import url(/assets/extensions/$identifier/admin.style.css);~~g" ".blueprint/extensions/blueprint/assets/admin.extensions.css"
  fi

  ((PROGRESS_NOW++))

  # Remove admin wrapper
  if [[ $admin_wrapper != "" ]]; then
    PRINT INFO "Removing and unlinking admin wrapper.."
    rm "resources/views/blueprint/admin/wrappers/$identifier.blade.php";
  fi

  ((PROGRESS_NOW++))

  # Remove dashboard wrapper
  if [[ $dashboard_wrapper != "" ]]; then
    PRINT INFO "Removing and unlinking dashboard wrapper.."
    rm "resources/views/blueprint/dashboard/wrappers/$identifier.blade.php";
  fi

  ((PROGRESS_NOW++))

  # Remove dashboard css
  if [[ $dashboard_css != "" ]]; then
    PRINT INFO "Removing and unlinking dashboard css.."
    sed -i "s~@import url(./imported/$identifier.css);~~g" "resources/scripts/blueprint/css/extensions.css"
    rm "resources/scripts/blueprint/css/imported/$identifier.css"
    YARN="y"
  fi

  ((PROGRESS_NOW++))

  # Remove dashboard components
  if [[ $dashboard_components != "" ]]; then
    PRINT INFO "Removing and unlinking dashboard components.."
    # fetch component config
    eval "$(parse_yaml .blueprint/extensions/"$identifier"/components/Components.yml Components_)"

    # define static variables to make stuff a bit easier
    im="\/\* blueprint\/import \*\/"; re="{/\* blueprint\/react \*/}"; co="resources/scripts/blueprint/components"
    s="import ${identifier^}Component from '"; e="';"

    REMOVE_REACT() {
      if [[ ! $EXTENSION == "" ]]; then
        # remove components
        sed -i \
          -e "s~""${s}@/blueprint/extensions/${identifier}/$EXTENSION${e}""~~g" \
          -e "s~""<${identifier^}Component />""~~g" \
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
    REMOVE_REACT "$Components_Dashboard_Global_BeforeSection" "Dashboard/Global/BeforeSection.tsx"
    REMOVE_REACT "$Components_Dashboard_Global_AfterSection" "Dashboard/Global/AfterSection.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_BeforeContent" "Dashboard/Serverlist/BeforeContent.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_AfterContent" "Dashboard/Serverlist/AfterContent.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_ServerRow_BeforeEntryName" "Dashboard/Serverlist/ServerRow/BeforeEntryName.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_ServerRow_AfterEntryName" "Dashboard/Serverlist/ServerRow/AfterEntryName.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_ServerRow_BeforeEntryDescription" "Dashboard/Serverlist/ServerRow/BeforeEntryDescription.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_ServerRow_AfterEntryDescription" "Dashboard/Serverlist/ServerRow/AfterEntryDescription.tsx"
    REMOVE_REACT "$Components_Dashboard_Serverlist_ServerRow_ResourceLimits" "Dashboard/Serverlist/ServerRow/ResourceLimits.tsx"

    # authentication
    REMOVE_REACT "$Components_Authentication_Container_BeforeContent" "Authentication/Container/BeforeContent.tsx"
    REMOVE_REACT "$Components_Authentication_Container_AfterContent" "Authentication/Container/AfterContent.tsx"

    # server
    REMOVE_REACT "$Components_Server_Terminal_BeforeContent" "Server/Terminal/BeforeContent.tsx"
    REMOVE_REACT "$Components_Server_Terminal_AdditionalPowerButtons" "Server/Terminal/AdditionalPowerButtons.tsx"
    REMOVE_REACT "$Components_Server_Terminal_BeforeInformation" "Server/Terminal/BeforeInformation.tsx"
    REMOVE_REACT "$Components_Server_Terminal_AfterInformation" "Server/Terminal/AfterInformation.tsx"
    REMOVE_REACT "$Components_Server_Terminal_CommandRow" "Server/Terminal/CommandRow.tsx"
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

    rm -R \
      ".blueprint/extensions/$identifier/components" \
      "resources/scripts/blueprint/extensions/$identifier"
    YARN="y"
  fi

  ((PROGRESS_NOW++))

  # Remove custom routes
  PRINT INFO "Unlinking navigation routes.."
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

  ((PROGRESS_NOW++))

  # Remove views folder
  if [[ $requests_views != "" ]]; then
    PRINT INFO "Removing and unlinking views folder.."
    rm -R \
      ".blueprint/extensions/$identifier/views" \
      "resources/views/blueprint/extensions/$identifier"
  fi

  ((PROGRESS_NOW++))

  # Remove app folder
  if [[ $requests_app != "" ]]; then
    PRINT INFO "Removing and unlinking app folder.."
    rm -R \
      ".blueprint/extensions/$identifier/app" \
      "app/BlueprintFramework/Extensions/$identifier"
  fi

  ((PROGRESS_NOW++))

  # Remove router files
  if [[ $requests_routers             != "" ]] \
  || [[ $requests_routers_application != "" ]] \
  || [[ $requests_routers_client      != "" ]] \
  || [[ $requests_routers_web         != "" ]]; then
    PRINT INFO "Removing and unlinking router files.."
    rm -r \
      ".blueprint/extensions/$identifier/routers" \
      "routes/blueprint/application/$identifier.php" \
      "routes/blueprint/client/$identifier.php" \
      "routes/blueprint/web/$identifier.php" \
      &>> "$BLUEPRINT__DEBUG"
  fi

  ((PROGRESS_NOW++))

  # Remove console folder
  if [[ $data_console != "" ]]; then # further expand on this if needed
    PRINT INFO "Removing and unlinking console folder.."
    rm -R \
      ".blueprint/extensions/$identifier/console" \
      "app/Console/Commands/BlueprintFramework/Extensions/${identifier^}" \
      "app/BlueprintFramework/Schedules/${identifier^}Schedules.php" \
      2>> "$BLUEPRINT__DEBUG"
  fi

  ((PROGRESS_NOW++))

  # Remove private folder
  PRINT INFO "Removing and unlinking private folder.."
  rm -R ".blueprint/extensions/$identifier/private"

  ((PROGRESS_NOW++))

  # Remove public folder
  if [[ $data_public != "" ]]; then
    PRINT INFO "Removing and unlinking public folder.."
    rm -R \
      ".blueprint/extensions/$identifier/public" \
      "public/extensions/$identifier"
  fi

  ((PROGRESS_NOW++))

  # Remove assets folder
  PRINT INFO "Removing and unlinking assets folder.."
  rm -R \
    ".blueprint/extensions/$identifier/assets" \
    "public/assets/extensions/$identifier"
  
  ((PROGRESS_NOW++))

  # Remove extension filesystem (ExtensionFS)
  PRINT INFO "Removing and unlinking extension filesystem.."
  rm -r \
    ".blueprint/extensions/$identifier/fs" \
    ".blueprint/extensions/$identifier/.fs" \
    "storage/extensions/$identifier" \
    "storage/.extensions/$identifier" \
    "public/fs/$identifier" > /dev/null 2>&1
  sed -i \
    -e "s/\/\* ${identifier^}Start \*\/.*\/\* ${identifier^}End \*\///" \
    -e "s~/\* ${identifier^}Start \*/~~g" \
    -e "s~/\* ${identifier^}End \*/~~g" \
    "config/ExtensionFS.php"

  ((PROGRESS_NOW++))

  # Remove extension directory
  PRINT INFO "Removing extension folder.."
  rm -R ".blueprint/extensions/$identifier"

  ((PROGRESS_NOW++))

  # Remove from installed list
  PRINT INFO "Removing '$identifier' from active extensions list.."
  sed -i "s~$identifier,~~g" ".blueprint/extensions/blueprint/private/db/installed_extensions"

  if [[ $RemovedExtensions == "" ]]; then RemovedExtensions="$identifier"; else RemovedExtensions+=", $identifier"; fi
  
  ((PROGRESS_NOW++))

  # Unset variables
  PRINT INFO "Unsetting variables.."
  unsetVariables
}

Command() {
  if [[ $1 == "" ]]; then PRINT FATAL "Expected at least 1 argument but got 0.";exit 2;fi

  # Remove selected extensions
  current=0
  extensions="$*"
  total=$(echo "$extensions" | wc -w)

  local EXTENSIONS_STEPS=22 #Total amount of steps per extension
  local FINISH_STEPS=5 #Total amount of finalization 
  
  export PROGRESS_TOTAL="$(("$FINISH_STEPS" + "$EXTENSIONS_STEPS" * "$total"))"
  export PROGRESS_NOW=0

  for extension in $extensions; do
    (( current++ ))
    RemoveExtension "$extension" "$current" "$total"
    export PROGRESS_NOW="$(("$EXTENSIONS_STEPS" * "$current"))"
  done

  if [[ $RemovedExtensions != "" ]]; then
    ((PROGRESS_NOW++))

    # Finalize transaction
    PRINT INFO "Finalizing transaction.."

    # Rebuild panel
    if [[ $YARN == "y" ]]; then
      PRINT INFO "Rebuilding panel assets.."
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
      php artisan cache:clear
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

    CorrectPhrasing="have"
    if [[ $total = 1 ]]; then CorrectPhrasing="has"; fi
    PRINT SUCCESS "$RemovedExtensions $CorrectPhrasing been removed."
    hide_progress

    exit 0
  fi
  
  hide_progress
  exit 1
}