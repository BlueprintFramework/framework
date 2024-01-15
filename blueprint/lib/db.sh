#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

FLDR=".blueprint/extensions/blueprint/private/db/database"

# dbAdd "database.record"
dbAdd() { echo "* ${1};" >> $FLDR; }

# dbValidate "database.record"
dbValidate() { grep -Fxq "* ${1};" $FLDR > /dev/null; }

# dbRemove "database.record"
dbRemove() { sed -i "s/* ${1};//g" $FLDR > /dev/null; }
