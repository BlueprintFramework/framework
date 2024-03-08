#!/bin/bash

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi


# Prompt the user
echo "WARNING!: The following uninstall will remove blueprint and most* of its components"
echo "This will also delete your app/ public/ resources/ ./blueprint folders."
read -p "Are you sure you want to continue with the uninstall(y/n): " choice

# Check the user's choice

case "$choice" in
  y|Y) echo "Continuing with the script..." ;;
  n|N) echo "Exiting the script."; exit ;;
  *) echo "Invalid choice. Please enter 'y' for yes or 'n' for no." ;;
esac

# Define variables
directory="/var/www/pterodactyl"
build_url="https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
files_to_delete=(
    ".blueprint/"
    "app/"
    "public/"
    "resources/"
    "routes/"
    "blueprint.sh"
    # Add more filenames as needed
)

read -p "Current directory: $directory. Press Enter to confirm, or enter a new directory: " new_directory

# Check if the user entered a new directory
if [ -n "$new_directory" ]; then
    directory="$new_directory"
    echo "Pterodactyl directory changed to: $directory"
else
    echo "Pterodactyl directory confirmed: $directory"
fi
currentLoc=$(pwd)
#Go to install directory
cd $directory
php artisan down
echo "Set panel into Meintenance Mode"
# Iterate over each filename and delete it
for filename in "${files_to_delete[@]}"; do
    # Concatenate directory and filename
    file_path="${directory}/${filename}"

    if [ -e "$file_path" ]; then
        rm "$file_path"
        echo "File '$filename' deleted successfully."
    else
        echo "File '$filename' does not exist in directory '$directory'."
    fi
done
echo "Done deleting files"

curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv
echo "Got latest panel build"
rm -fr panel.tar.gz
chmod -R 755 storage/* bootstrap/cache
php artisan view:clear
php artisan config:clear

# Prompt the user
read -p "Do you want to update your database schema for the newest version of Pterodactyl? (y/n): " choice

# Check the user's choice
case "$choice" in
  y|Y) echo "Updating database schema..." 
    php artisan migrate --seed --force
    ;;
  n|N) echo "Skipping database schema update." ;;
  *) echo "Invalid choice. Please enter 'y' for yes or 'n' for no." ;;
esac
echo "Finishing up..."
chown -R www-data:www-data ${directory}/
php artisan queue:restart
php artisan up
chown -R www-data:www-data ${directory}/
echo "If you want to update your dependencies also, run:"
echo "composer install --no-dev --optimize-autoloader"
echo "As composer's developers recommandation, do NOT run it as root."
echo "See https://getcomposer.org/root for details"
cd $currentLoc
echo "Job is complete!"

