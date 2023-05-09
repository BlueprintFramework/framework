#!/bin/bash

FLDR="/var/www/&bp.folder&/.blueprint/.storage/db.md";

# If Blueprint does not replace the variable, default to "/var/www/pterodactyl" as root folder.
if [[ $FLDR == "/var/www/&b""p.folder&/.blueprint/.storage/db.md" ]]; then FLDR="/var/www/pterodactyl/.blueprint/.storage/db.md"; fi;

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