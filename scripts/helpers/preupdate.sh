#!/bin/bash

# $NEW_TAG: New Blueprint version that update.sh is updating to
# $OLD_TAG: Old Blueprint version that update.sh is updating from
# $RAN_BY_LEGACY: If this script is ran by the legacy updater
# $UPDATE_FOLDER: Folder with the update files
# $PROGRESS_NOW: Current loader progress
# $PROGRESS_TOTAL: Total loader progress

# $FOLDER: Pterodactyl directory
# $REPOSITORY: GitHub repository
# $BLUEPRINT_ENGINE: Blueprint engine name
# $OWNERSHIP: Group that owns the Pterodactyl directory permissions
# $WEBUSER: User that owns the Pterodactyl directory permissions
# $USERSHELL: The shell used for extension scripts and stuff
# $BLUEPRINT__DEBUG: Blueprint debug directory for debug logs

source ../libraries/logFormat.sh || echo "could not import logformat"

exit 0
