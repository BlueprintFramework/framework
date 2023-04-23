#!/bin/bash

VERSION="([(pterodactylmarket_version)])";

cd /var/www/pterodactyl;
if [[ "$@" == *"-php"* ]]; then
    exit 1;
fi;

mkdir .blueprint 2> /dev/null;
cp -R blueprint/* .blueprint/ 2> /dev/null;
rm -R blueprint 2> /dev/null;

source .blueprint/lib/bash_colors.sh;
source .blueprint/lib/parse_yaml.sh;
source .blueprint/lib/db.sh;

export NEWT_COLORS='
    root=,black
    window=black,blue
    title=white,blue
    border=blue,blue
    textbox=white,blue
    listbox=white,black
    button=white,blue
';

error() {
    whiptail --title " ◆ " --ok-button "ok" --msgbox "Sorry, this operation could not be completed. For troubleshooting, please go to ptero.shop/error.\n\n\"${1}\"" 15 60;
    clr_red "${1}";
    exit 1;
};

touch /usr/local/bin/blueprint > /dev/null;
echo -e "#!/bin/bash\nbash /var/www/pterodactyl/blueprint.sh -bash \$@;" > /usr/local/bin/blueprint;
chmod u+x /var/www/pterodactyl/blueprint.sh > /dev/null;
chmod u+x /usr/local/bin/blueprint > /dev/null;

if [[ $1 != "-bash" ]]; then
    if dbValidate "blueprint.setupFinished"; then
        clr_blue "This command only works if you have yet to install Blueprint. You can run \"\033[1;94mblueprint\033[0m\033[0;34m\" instead.";
        exit 1;
    else
        clr_bright "php artisan down";
        php artisan down;

        clr_bright "/var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css";
        sed -i "s!@import 'checkbox.css';!@import 'checkbox.css';\n@import url(/assets/extensions/blueprint/blueprint.style.css);\n/* blueprint reserved line */!g" /var/www/pterodactyl/public/themes/pterodactyl/css/pterodactyl.css;


        clr_bright "php artisan view:clear";
        php artisan view:clear;


        clr_bright "php artisan config:clear";
        php artisan config:clear;


        clr_bright "php artisan migrate";
        php artisan migrate;


        clr_bright "chown -R www-data:www-data /var/www/pterodactyl/*";
        chown -R www-data:www-data /var/www/pterodactyl/*;

        clr_bright "chown -R www-data:www-data /var/www/pterodactyl/.*";
        chown -R www-data:www-data /var/www/pterodactyl/.*;

        clr_bright "php artisan up";
        php artisan up;

        clr_blue "\n\nBlueprint should now be installed. If something didn't work as expected, please let us know at discord.gg/CUwHwv6xRe.";

        dbAdd "blueprint.setupFinished";
        exit 1;
    fi;
fi;

if [[ $2 == "-placeholder" ]]; then
    if [[ $3 == "" ]]; then
        echo -e "Expected 1 argument but got $(expr $# - 2). (-placeholder versionid)";
        exit 1;
    fi;

    sed -E -i "s*\(\[\(pterodactylmarket_version\)\]\)*$3*g" app/Services/Helpers/BlueprintPlaceholderService.php;
    sed -E -i "s*\(\[\(pterodactylmarket_version\)\]\)*$3*g" blueprint.sh;
fi;

if [[ ( $2 == "-i" ) || ( $2 == "-install" ) ]]; then
    if [[ $(expr $# - 2) != 1 ]]; then error "Expected 1 argument but got $(expr $# - 2).";fi;
    FILE=$3".blueprint"
    if [[ ! -f "$FILE" ]]; then error "$FILE could not be found.";fi;

    ZIP=$3".zip";
    cp $FILE .blueprint/tmp/$ZIP;
    cd .blueprint/tmp;
    unzip $ZIP;
    rm $ZIP;
    if [[ ! -f "$3/*" ]]; then
        cd ..;
        rm -R tmp;
        mkdir tmp;
        cd tmp;

        mkdir ./$3;
        cp ../../$FILE ./$3/$ZIP;
        cd $3;
        unzip $ZIP;
        rm $ZIP;
        cd ..;
    fi;


    cd /var/www/pterodactyl;

    eval $(parse_yaml .blueprint/tmp/$3/conf.yml)

    if [[ $flags != *"-placeholders.skip;"* ]]; then
        DIR=.blueprint/tmp/$3/*;

        # ^#version#^ = version
        # ^#author#^ = author

        for f in $DIR; do
            sed -i "s~^#version#^~$version~g" $f;
            sed -i "s~^#author#^~$author~g" $f;
            echo "Done placeholders in '$f'.";
        done;
    else echo "-placeholders.skip;"; fi;

    if [[ $name == "" ]]; then rm -R .blueprint/tmp/$3; error "'name' is a required option.";fi;
    if [[ $identifier == "" ]]; then rm -R .blueprint/tmp/$3; error "'identifier' is a required option.";fi;
    if [[ $description == "" ]]; then rm -R .blueprint/tmp/$3; error "'description' is a required option.";fi;
    if [[ $version == "" ]]; then rm -R .blueprint/tmp/$3; error "'version' is a required option.";fi;
    if [[ $target == "" ]]; then rm -R .blueprint/tmp/$3; error "'target' is a required option.";fi;
    if [[ $icon == "" ]]; then rm -R .blueprint/tmp/$3; error "'icon' is a required option.";fi;

    if [[ $controller_location == "" ]]; then rm -R .blueprint/tmp/$3; error "'controller_location' is a required option.";fi;
    if [[ $view_location == "" ]]; then rm -R .blueprint/tmp/$3; error "'view_location' is a required option.";fi;

    if [[ $target != $VERSION ]]; then clr_red "This extension is built for version $target, but your version is $VERSION.";fi;
    if [[ $identifier != $3 ]]; then rm -R .blueprint/tmp/$3; error "The extension identifier should be exactly the same as your .blueprint file (just without the .blueprint). This may be subject to change, but is currently required.";fi;
    if [[ $identifier == "blueprint" ]]; then rm -R .blueprint/tmp/$3; error "The operation could not be completed since the extension is attempting to overwrite internal files.";fi;

    if [[ $identifier =~ [a-z] ]]; then echo "ok";
    else rm -R .blueprint/tmp/$3; error "The extension identifier should be lowercase and only contain characters a-z.";fi;

    if [[ ! -f ".blueprint/tmp/$3/$icon" ]]; then rm -R .blueprint/tmp/$3;error "The 'icon' path points to a nonexisting file.";fi;

    if [[ $migrations_directory != "" ]]; then
        if [[ $migrations_enabled == "yes" ]]; then
            cp -R .blueprint/tmp/$3/$migrations_directory/* database/migrations/ 2> /dev/null;
        elif [[ $migrations_enabled == "no" ]]; then
            echo "ok";
        else
            rm -R .blueprint/tmp/$3;
            error "If defined, migrations_enabled should only be 'yes' or 'no'.";
        fi;
    fi;

    if [[ $css_location != "" ]]; then
        if [[ $css_enabled == "yes" ]]; then
            INJECTCSS=true;
        elif [[ $css_enabled == "no" ]]; then
            echo "ok";
        else
            rm -R .blueprint/tmp/$3;
            error "If defined, css_enabled should only be 'yes' or 'no'.";
        fi;
    fi;

    if [[ $adminrequests_directory != "" ]]; then
        if [[ $adminrequests_enabled == "yes" ]]; then
            mkdir app/Http/Requests/Admin/Extensions/$identifier;
            cp -R .blueprint/tmp/$3/$adminrequests_directory/* app/Http/Requests/Admin/Extensions/$identifier/ 2> /dev/null;
        elif [[ $adminrequests_enabled == "no" ]]; then
            echo "ok";
        else
            rm -R .blueprint/tmp/$3;
            error "If defined, adminrequests_enabled should only be 'yes' or 'no'.";
        fi;
    fi;

    if [[ $publicfiles_directory != "" ]]; then
        if [[ $publicfiles_enabled == "yes" ]]; then
            mkdir public/extensions/$identifier;
            cp -R .blueprint/tmp/$3/$publicfiles_directory/* public/extensions/$identifier/ 2> /dev/null;
        elif [[ $publicfiles_enabled == "no" ]]; then
            echo "ok";
        else
            rm -R .blueprint/tmp/$3;
            error "If defined, publicfiles_enabled should only be 'yes' or 'no'.";
        fi;
    fi;

    cp -R .blueprint/defaults/extensions/admin.default .blueprint/defaults/extensions/admin.default.bak 2> /dev/null;
    if [[ $controller_type != "" ]]; then
        if [[ $controller_type == "default" ]]; then
            cp -R .blueprint/defaults/extensions/controller.default .blueprint/defaults/extensions/controller.default.bak 2> /dev/null;
        elif [[ $controller_type == "custom" ]]; then
            echo "ok";
        else
            rm -R .blueprint/tmp/$3;
            error "If defined, controller_type should only be 'default' or 'custom'.";
        fi;
    fi;
    cp -R .blueprint/defaults/extensions/route.default .blueprint/defaults/extensions/route.default.bak 2> /dev/null;
    cp -R .blueprint/defaults/extensions/button.default .blueprint/defaults/extensions/button.default.bak 2> /dev/null;

    mkdir public/assets/extensions/$identifier;
    cp .blueprint/tmp/$3/$icon public/assets/extensions/$identifier/icon.jpg;
    ICON="/assets/extensions/$identifier/icon.jpg";
    CONTENT=$(cat .blueprint/tmp/$3/$view_location);

    if [[ $INJECTCSS == true ]]; then
        sed -i "s!/* blueprint reserved line */!/* blueprint reserved line */\n@import url(/assets/extensions/$identifier/$identifier.style.css);!g" public/themes/pterodactyl/css/pterodactyl.css;
        cp -R .blueprint/tmp/$3/$css_location/* public/assets/extensions/$identifier/$identifier.style.css 2> /dev/null;
    fi;

    if [[ $name == *"~"* ]]; then clr_red "'name' contains '~' and may result in an error.";fi;
    if [[ $description == *"~"* ]]; then clr_red "'description' contains '~' and may result in an error.";fi;
    if [[ $version == *"~"* ]]; then clr_red "'version' contains '~' and may result in an error.";fi;
    if [[ $CONTENT == *"~"* ]]; then clr_red "'CONTENT' contains '~' and may result in an error.";fi;
    if [[ $ICON == *"~"* ]]; then clr_red "'ICON' contains '~' and may result in an error.";fi;
    if [[ $identifier == *"~"* ]]; then clr_red "'identifier' contains '~' and may result in an error.";fi;

    sed -i "s~␀title␀~$name~g" .blueprint/defaults/extensions/admin.default.bak;
    sed -i "s~␀name␀~$name~g" .blueprint/defaults/extensions/admin.default.bak;
    sed -i "s~␀breadcrumb␀~$name~g" .blueprint/defaults/extensions/admin.default.bak;
    sed -i "s~␀name␀~$name~g" .blueprint/defaults/extensions/button.default.bak;

    sed -i "s~␀description␀~$description~g" .blueprint/defaults/extensions/admin.default.bak;

    sed -i "s~␀version␀~$version~g" .blueprint/defaults/extensions/admin.default.bak;
    sed -i "s~␀version␀~$version~g" .blueprint/defaults/extensions/button.default.bak;

    sed -i "s~␀icon␀~$ICON~g" .blueprint/defaults/extensions/admin.default.bak;

    sed -i "s~␀content␀~$CONTENT~g" .blueprint/defaults/extensions/admin.default.bak;

    if [[ $controller_type != "custom" ]]; then
        sed -i "s~␀id␀~$identifier~g" .blueprint/defaults/extensions/controller.default.bak;
    fi;
    sed -i "s~␀id␀~$identifier~g" .blueprint/defaults/extensions/route.default.bak;
    sed -i "s~␀id␀~$identifier~g" .blueprint/defaults/extensions/button.default.bak;

    ADMINVIEW_RESULT=$(cat .blueprint/defaults/extensions/admin.default.bak);
    ADMINROUTE_RESULT=$(cat .blueprint/defaults/extensions/route.default.bak);
    ADMINBUTTON_RESULT=$(cat .blueprint/defaults/extensions/button.default.bak);
    if [[ $controller_type != "custom" ]]; then
        ADMINCONTROLLER_RESULT=$(cat .blueprint/defaults/extensions/controller.default.bak);
    fi;
    ADMINCONTROLLER_NAME=$identifier"ExtensionController.php";

    mkdir resources/views/admin/extensions/$identifier;
    touch resources/views/admin/extensions/$identifier/index.blade.php;
    echo $ADMINVIEW_RESULT > resources/views/admin/extensions/$identifier/index.blade.php;

    mkdir app/Http/Controllers/Admin/Extensions/$identifier;
    touch app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;

    if [[ $controller_type != "custom" ]]; then
        echo $ADMINCONTROLLER_RESULT > app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
    else
        cp .blueprint/tmp/$3/$controller_location app/Http/Controllers/Admin/Extensions/$identifier/$ADMINCONTROLLER_NAME;
    fi;

    if [[ $controller_type == "custom" ]]; then
        cp .blueprint/tmp/$3/$controller_location app/Http/Controllers/Admin/Extensions/$identifier/${identifier}ExtensionController.php;
    fi;

    echo $ADMINROUTE_RESULT >> routes/admin.php;

    sed -i "s~<!--␀replace␀-->~$ADMINBUTTON_RESULT\n<!--␀replace␀-->~g" resources/views/admin/extensions.blade.php;

    rm .blueprint/defaults/extensions/admin.default.bak;
    if [[ $controller_type != "custom" ]]; then
        rm .blueprint/defaults/extensions/controller.default.bak;
    fi;
    rm .blueprint/defaults/extensions/route.default.bak;
    rm .blueprint/defaults/extensions/button.default.bak;
    rm -R .blueprint/tmp/$3;

    if [[ $author == "blueprint" ]]; then clr_blue "Please refrain from setting the author variable to 'blueprint', thanks!";fi;
    if [[ $author == "Blueprint" ]]; then clr_blue "Please refrain from setting the author variable to 'Blueprint', thanks!";fi;

    if [[ -f ".blueprint/.flags/onboarding.md" ]]; then
        clr_green "Congratulations on installing your first extension! We'll now automatically disable onboarding for you.";
        rm .blueprint/.flags/onboarding.md;
    fi;

    clr_blue "\n\n$identifier should now be installed. If something didn't work as expected, please let us know at discord.gg/CUwHwv6xRe.";
fi;

if [[ $2 == "help" ]]; then
    echo -e "-i [name] | install a blueprint extension\n-v | get the current blueprint version\n-reinstall | rerun the blueprint installation script";
fi;

if [[ ( $2 == "-v" ) || ( $2 == "-version" ) ]]; then
    echo -e $VERSION;
fi;

if [[ $2 == "-reinstall"  ]]; then
    dbRemove "blueprint.setupFinished";
    cd /var/www/pterodactyl;
    bash blueprint.sh;
fi;