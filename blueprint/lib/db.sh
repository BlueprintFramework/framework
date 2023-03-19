#!/bin/bash

dbAdd() {
    # dbAdd "database.record";
    sed -i "s/+ db.addnewrecord;/* ${1};\n+ db.addnewrecord;/g" /var/www/pterodactyl/.blueprint/db.md > /dev/null;
}; dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" /var/www/pterodactyl/.blueprint/db.md > /dev/null;
}; dbRemove() {
    # dbRemove "database.record";
    sed -i "s/* ${1};//g" /var/www/pterodactyl/.blueprint/db.md > /dev/null;
};