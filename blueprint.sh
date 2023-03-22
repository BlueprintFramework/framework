#!/bin/bash

cd /var/www/pterodactyl;
if [[ "$@" == *"-php"* ]]; then
    exit 1;
fi;

mkdir .blueprint 2> /dev/null;
cp -R blueprint/* .blueprint/ 2> /dev/null;
rm -R blueprint 2> /dev/null;

source .blueprint/lib/bash_colors.sh;
source .blueprint/lib/db.sh;

if [[ $1 != "-bash" ]]; then
    if dbValidate "blueprint.setupFinished"; then
        clr_blue "This command only works if you have yet to install Blueprint. You can run \"\033[1;94mblueprint\033[0m\033[0;34m\" instead.";
        dbRemove "blueprint.setupFinished";
    else
        clr_bright "/var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css";
        sed -i "s!@import 'checkbox.css';!@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);!g" /var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css;


        clr_bright "php artisan view:clear";
        php artisan view:clear > /dev/null;


        clr_bright "php artisan config:clear";
        php artisan config:clear > /dev/null;


        clr_bright "chown -R www-data:www-data /var/www/pterodactyl/*";
        chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null;

        clr_bright "chown -R www-data:www-data /var/www/pterodactyl/.*";
        chown -R www-data:www-data /var/www/pterodactyl/.* > /dev/null;

        dbAdd "blueprint.setupFinished";
    fi;
fi;

touch /usr/local/bin/blueprint > /dev/null;
echo -e "#!/bin/bash\nbash /var/www/pterodactyl/blueprint.sh -bash \$@;" > /usr/local/bin/blueprint;
chmod u+x /var/www/pterodactyl/blueprint.sh > /dev/null;
chmod u+x /usr/local/bin/blueprint > /dev/null;

if [[ $2 == "help" ]]; then
    echo -e "";
fi;