#!/bin/bash

err="\033[0;31m ERROR \033[0m";
warn="\033[0;33m WARN \033[0m";
info="\033[0;34m\033[1;94m INFO \033[0;34m";
task="\033[0;93m TASK \033[0m";
log="\e[1;37;40m LOG \e[2;37;40m";

cd /var/www/pterodactyl;
if [[ "$@" == *"-php"* ]]; then
    exit 1;
fi;

if [[ $1 == "-c" ]]; then
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
        echo -e $log"/var/www/pterodactyl/.blueprint/db.md\033[0m";
        touch .blueprint/db.md > /dev/null;
        echo -e "# Internal database for the bash side of Blueprint.\n+ db.addnewrecord;" > .blueprint/db.md;


        echo -e $task"/var/www/pterodactyl/.blueprint/defaults\033[0m";
        mkdir -p .blueprint/defaults > /dev/null;


        echo -e $task"/var/www/pterodactyl/.blueprint/defaults/extensions\033[0m";
        mkdir -p .blueprint/defaults/extensions > /dev/null;


        echo -e $task"/var/www/pterodactyl/.blueprint/defaults/extensions/admin.default\033[0m";
        touch .blueprint/defaults/extensions/admin.default > /dev/null;
        echo -e "@extends('layouts.admin')\n\n@section('title')\n    ␀title␀\n@endsection\n\n@section('content-header')\n    <img src=\"␀icon␀\" alt=\"logo\" style=\"float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;\">\n    <h1 ext-title>␀name␀<tag mg-left blue>␀version␀</tag></h1>\n    <ol class=\"breadcrumb\">\n        <li><a href=\"{{ route('admin.index') }}\">Admin</a></li>\n        <li><a href=\"{{ route('admin.extensions') }}\">Extensions</a></li>\n        <li class=\"active\">␀breadcrumb␀</li>\n    </ol>\n@endsection\n\n@section('content')\n    ␀content␀\n@endsection" > .blueprint/defaults/extensions/admin.default;


        echo -e $task"/var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css\033[0m";
        sed -i "s!@import 'checkbox.css';!@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);!g" /var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css;


        echo -e $task"php artisan view:clear\033[0m";
        php artisan view:clear > /dev/null;


        echo -e $task"php artisan config:clear\033[0m";
        php artisan config:clear > /dev/null;


        echo -e $task"chown -R www-data:www-data /var/www/pterodactyl/*\033[0m";
        chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null;

        dbAdd "blueprint.setupFinished";
    fi;
fi;