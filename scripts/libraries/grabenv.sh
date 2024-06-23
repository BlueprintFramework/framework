#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.
#
# Commands:
# - grabAppUrl              string
# - grabAppDebug            bool
# - grabAppTimezone         string
# - grabAppLocale           string



cd "${BLUEPRINT__FOLDER}" || exit
env_file=".env"
while IFS= read -r line; do
  if [[ $line == \#* ]]; then
    continue
  fi
  if [[ $line == *"="* ]]; then
    variable_name=$(echo "$line" | cut -d= -f1)
    variable_value=$(echo "$line" | cut -d= -f2-)
    variable_name=$(echo "$variable_name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    variable_value=$(echo "$variable_value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^"\(.*\)"$/\1/')
    declare "$variable_name=$variable_value"
  fi
done < "$env_file"

grabAppUrl()               { echo "$APP_URL";      }
grabAppDebug()             { echo "$APP_DEBUG";    }
grabAppTimezone()          { echo "$APP_TIMEZONE"; }
grabAppLocale()            { echo "$APP_LOCALE";   }