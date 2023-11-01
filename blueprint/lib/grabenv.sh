#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future.
#
# Commands:
# - grabAppUrl              string
# - grabAppDebug            bool
# - grabAppTimezone         string
# - grabAppLocale           string



cd "${BLUEPRINT__FOLDER}"
source ${BLUEPRINT__FOLDER}/.env

grabAppUrl()               { echo $APP_URL;      }
grabAppDebug()             { echo $APP_DEBUG;    }
grabAppTimezone()          { echo $APP_TIMEZONE; }
grabAppLocale()            { echo $APP_LOCALE;   }