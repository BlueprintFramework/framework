#!/bin/bash

FLDR="/var/www/&bp.folder&";

# If Blueprint does not replace the variable, default to "/var/www/pterodactyl" as root folder.
if [[ $FLDR == "/var/www/&b""p.folder&" ]]; then FLDR="/var/www/pterodactyl" fi;

dbAdd() {
    # dbAdd "database.record";
    sed -i "s/+ db.addnewrecord;/* ${1};\n+ db.addnewrecord;/g" $FLDR/.blueprint/db.md > /dev/null;
}; dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" $FLDR/.blueprint/db.md > /dev/null;
}; dbRemove() {
    # dbRemove "database.record";
    sed -i "s/* ${1};//g" $FLDR/.blueprint/db.md > /dev/null;
};