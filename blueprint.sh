#!/bin/bash

err="\033[0;31m ERROR \033[0m";
warn="\033[0;33m WARN \033[0m";
info="\033[0;96m INFO \033[0m";
task="\033[0;93m TASK \033[0m";

cd /var/www/pterodactyl;
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

if [[ "$@" != *"-bash"* ]]; then
    if dbValidate "blueprint.setupFinished"; then
        echo -e $info"\033[0;34mThis command only works if you have yet to install Blueprint. You can run \"\033[1;94mblueprint\033[0m\033[0;34m\" instead.\033[0m";
        dbRemove "blueprint.setupFinished";
    else
        echo -e $task"\033[0;33mMaking .blueprint files.\033[0m";
        touch .blueprint/db.md > /dev/null;
        echo -e "# Internal database for the bash side of Blueprint.\n+ db.addnewrecord;" > .blueprint/db.md;


        echo -e $task"\033[0;33mInjecting custom css.\033[0m";
        sed -i "s/@import 'checkbox.css';/@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);/g" /var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css;


        echo -e $task"\033[0;33mClearing views.\033[0m";
        php artisan view:clear > /dev/null;
        php artisan config:clear > /dev/null;

        echo -e $task"\033[0;33mUpdating permissions.\033[0m";
        chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null;

        dbAdd "blueprint.setupFinished";
    fi;
fi;
