#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future.

FLDR=$BLUEPRINT__FOLDER"/.blueprint/data/internal/db/database"

dbAdd() {
    # dbAdd "database.record";
    echo "* ${1};" >> $FLDR
}; dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" $FLDR > /dev/null;
}; dbRemove() {
    # dbRemove "database.record";
    sed -i "s/* ${1};//g" $FLDR > /dev/null;
};
