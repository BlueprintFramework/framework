#!/bin/bash
#
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.


dbAdd() {
  echo "* ${1};" >> .blueprint/extensions/blueprint/private/db/database;
}
dbValidate() {
  grep -Fxq "* ${1};" .blueprint/extensions/blueprint/private/db/database > /dev/null;
}
dbRemove() {
  sed -i "s/* ${1};//g" .blueprint/extensions/blueprint/private/db/database > /dev/null;
}


shiftArgs() {
  shift 1
  args=""
  for arg in "$@"; do
    args+="$arg "
  done
  echo "$args"
}


unsetVariables() {
  patterns=("^conf_" "^old_" "^Console_" "^OldConsole_" "^Components_" "^OldComponents_" "^F_")
  for pattern in "${patterns[@]}"; do
    for var in $(compgen -v | grep "$pattern"); do
      unset "$var"
    done
  done
}


is_developer() {
  if [[ $is_developer != "" ]]; then
    return "$is_developer"
  fi
  if [[ $(php artisan bp:developer) == "true"* ]]; then
    export is_developer=0
    return 0
  else
    export is_developer=1
    return 1
  fi
}


php_escape_string() {
  local string="$1"

  # Escape ampersands.
  string="${string//&/\\\\&}"

  # Escape double quotes.
  string="${string//\"/\\\\\\\\\\\"}"

  echo "$string"
}


extract_extension() {
  # Get input file and clean extension
  local file="$1"
  if [[ $file == *".blueprint" ]]; then
    file="${file::-10}"
  fi
  
  # Export the parsed extension name
  export parsed_extension="$file"
  
  # Set full filename with .blueprint extension
  file="${file}.blueprint"
  
  # Check if file exists
  if [[ ! -f "$file" ]]; then
    PRINT FATAL "$file could not be found or detected."
    return 2
  fi
  
  # Setup tmp directory
  local name="${parsed_extension}"
  local tmp_dir=".blueprint/tmp"
  
  # Clean and recreate tmp directory
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"
  
  # Extract blueprint contents
  cp "$file" "$tmp_dir/$name.zip"
  (cd "$tmp_dir" && unzip -qq "$name.zip")
  rm "$tmp_dir/$name.zip"
  
  # Find conf.yml
  local conf_path
  conf_path=$(find "$tmp_dir" -name "conf.yml" -type f)
  if [[ -z "$conf_path" ]]; then
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    PRINT FATAL "Extension configuration file not found or detected."
    return 1
  fi
  
  # Move files to tmp root if needed
  local conf_dir
  conf_dir=$(dirname "$conf_path")
  if [[ "$conf_dir" != "$tmp_dir" ]]; then
    mv "$conf_dir"/* "$tmp_dir/"
    find "$tmp_dir" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
  fi
  
  return 0
}