#!/bin/bash

err="\033[0;31m ERROR \033[0m";
warn="\033[0;33m WARN \033[0m";
info="\033[0;34m\033[1;94m INFO \033[0;34m";
task="\033[0;93m TASK \033[0m";
log="\e[2;37;40m";

cd /var/www/pterodactyl;
if [[ "$@" == *"-php"* ]]; then
    exit 1;
fi;

if [[ $2 == "-c" ]]; then
    for x in {0..8}; do for i in {30..37}; do for a in {40..47}; do echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "; done; echo; done; done; echo ""; exit 1;
fi;


mkdir -p .blueprint > /dev/null;

dbAdd() {
    # dbAdd "database.record";
    sed -i "s/+ db.addnewrecord;/* ${1};\n+ db.addnewrecord;/g" /var/www/pterodactyl/.blueprint/db.md;
}; dbValidate() {
    # dbValidate "database.record";
    grep -Fxq "* ${1};" /var/www/pterodactyl/.blueprint/db.md;
}; dbRemove() {
    # dbRemove "database.record";
    sed -i "s/* ${1};//g" /var/www/pterodactyl/.blueprint/db.md;
};

touch /usr/local/bin/blueprint > /dev/null;
echo -e "#!/bin/bash\nbash /var/www/pterodactyl/blueprint.sh \$@ -bash;" > /usr/local/bin/blueprint;
chmod u+x /var/www/pterodactyl/blueprint.sh > /dev/null;
chmod u+x /usr/local/bin/blueprint > /dev/null;

if [[ $1 != "-bash" ]]; then
    if dbValidate "blueprint.setupFinished"; then
        echo -e $info"This command only works if you have yet to install Blueprint. You can run \"\033[1;94mblueprint\033[0m\033[0;34m\" instead.\033[0m";
        dbRemove "blueprint.setupFinished";
    else
        echo -e $log"cp -R blueprint .blueprint\033[0m";
        cp -R blueprint .blueprint > /dev/null

        echo -e $log"rm -R blueprint/\033[0m";
        rm -R blueprint/ > /dev/null;

        echo -e $log"/var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css\033[0m";
        sed -i "s!@import 'checkbox.css';!@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);!g" /var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css;


        echo -e $log"php artisan view:clear\033[0m";
        php artisan view:clear > /dev/null;


        echo -e $log"php artisan config:clear\033[0m";
        php artisan config:clear > /dev/null;


        echo -e $log"chown -R www-data:www-data /var/www/pterodactyl/*\033[0m";
        chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null;

        echo -e $log"chown -R www-data:www-data /var/www/pterodactyl/.*\033[0m";
        chown -R www-data:www-data /var/www/pterodactyl/.* > /dev/null;

        dbAdd "blueprint.setupFinished";
    fi;
fi;

if [[ $2 == "help" ]]; then
    echo -e "";
fi;