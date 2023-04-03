#!/bin/bash

dbAdd() {
    # dbAdd "database.record";
    sed -i "s/+ db.addnewrecord;/&\n* ${1};/" /var/www/pterodactyl/.blueprint/db.md > /dev/null
}

dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" /var/www/pterodactyl/.blueprint/db.md > /dev/null
}

dbRemove() {
    # dbRemove "database.record";
    sed -i "/^\\* ${1};$/d" /var/www/pterodactyl/.blueprint/db.md > /dev/null
}
