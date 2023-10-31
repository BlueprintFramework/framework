#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future.

FLDR=$BLUEPRINT__FOLDER

# If Blueprint does not replace the variable, default to "/var/www/pterodactyl" as root folder.
if [[ $FLDR == "&b""p.folder&/.blueprint/data/internal/db/database" ]]; then FLDR="/var/www/pterodactyl/.blueprint/data/internal/db/database"; fi;

dbAdd() {
    # dbAdd "database.record";
    sed -i "s/+ db.addnewrecord;/* ${1};\n+ db.addnewrecord;/g" $FLDR > /dev/null;
}; dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" $FLDR > /dev/null;
}; dbRemove() {
    # dbRemove "database.record";
    sed -i "s/* ${1};//g" $FLDR > /dev/null;
};
