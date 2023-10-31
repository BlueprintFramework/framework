#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and may be intergrated directly into the core in the future.

FLDR=$BLUEPRINT__FOLDER"/.blueprint/data/internal/db/database"

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
