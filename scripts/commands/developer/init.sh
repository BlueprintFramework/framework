#!/bin/bash

Command() {
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  # To prevent accidental wiping of your dev directory, you are unable to initialize another extension
  # until you wipe the contents of the .blueprint/dev directory.
  if [[ -n $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory contains files. To protect you against accidental data loss, you are unable to initialize another extension unless you clear the '.blueprint/dev' folder."
    exit 2
  fi

  ask_template() {
    PRINT INPUT "Choose an extension template:"
    echo -e "$(curl 'https://raw.githubusercontent.com/BlueprintFramework/templates/main/repository' 2>> "$BLUEPRINT__DEBUG")"
    read -r ASKTEMPLATE
    REDO_TEMPLATE=false

    # Template should not be empty
    if [[ ${ASKTEMPLATE} == "" ]]; then
      PRINT WARNING "Template should not be empty."
      REDO_TEMPLATE=true
    fi
    # Unknown template.
    if [[ $(echo -e "$(curl "https://raw.githubusercontent.com/BlueprintFramework/templates/main/${ASKTEMPLATE}/TemplateConfiguration.yml" 2>> "$BLUEPRINT__DEBUG")") == "404: Not Found" ]]; then
      PRINT WARNING "Unknown template, please choose a valid option."
      REDO_TEMPLATE=true
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_TEMPLATE} == true ]]; then ASKTEMPLATE=""; ask_template; fi
  }

  ask_name() {
    INPUT_DEFAULT="SpaceInvaders"
    PRINT INPUT "Name [$INPUT_DEFAULT]:"
    read -r ASKNAME
    REDO_NAME=false

    # Name should not be empty
    if [[ ${ASKNAME} == "" ]]; then
      ASKNAME="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_NAME} == true ]]; then ASKNAME=""; ask_name; fi
  }

  ask_identifier() {
    INPUT_DEFAULT="spaceinvaders"
    PRINT INPUT "Identifier [$INPUT_DEFAULT]:"
    read -r ASKIDENTIFIER
    REDO_IDENTIFIER=false

    # Identifier should not be empty
    if [[ ${ASKIDENTIFIER} == "" ]]; then
      ASKIDENTIFIER="$INPUT_DEFAULT"
    fi
    # Identifier should be a-z.
    if ! [[ ${ASKIDENTIFIER} =~ [a-z] ]]; then
      PRINT WARNING "Identifier should only contain a-z characters."
      REDO_IDENTIFIER=true
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_IDENTIFIER} == true ]]; then ASKIDENTIFIER=""; ask_identifier; fi
  }

  ask_description() {
    INPUT_DEFAULT="Shoot down space aliens!"
    PRINT INPUT "Description [$INPUT_DEFAULT]:"
    read -r ASKDESCRIPTION
    REDO_DESCRIPTION=false

    # Description should not be empty
    if [[ ${ASKDESCRIPTION} == "" ]]; then
      ASKDESCRIPTION="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_DESCRIPTION} == true ]]; then ASKDESCRIPTION=""; ask_description; fi
  }

  ask_version() {
    INPUT_DEFAULT="1.0"
    PRINT INPUT "Version [$INPUT_DEFAULT]:"
    read -r ASKVERSION
    REDO_VERSION=false

    # Version should not be empty
    if [[ ${ASKVERSION} == "" ]]; then
      ASKVERSION="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_VERSION} == true ]]; then ASKVERSION=""; ask_version; fi
  }

  ask_author() {
    INPUT_DEFAULT="byte"
    PRINT INPUT "Author [$INPUT_DEFAULT]:"
    read -r ASKAUTHOR
    REDO_AUTHOR=false

    # Author should not be empty
    if [[ ${ASKAUTHOR} == "" ]]; then
      ASKAUTHOR="$INPUT_DEFAULT"
    fi

    # Ask again if response does not pass validation.
    if [[ ${REDO_AUTHOR} == true ]]; then ASKAUTHOR=""; ask_author; fi
  }

  ask_template
  ask_name
  ask_identifier
  ask_description
  ask_version
  ask_author

  tnum=${ASKTEMPLATE}
  PRINT INFO "Fetching templates.."
  if [[ $(php artisan bp:latest) != "$VERSION" ]]; then PRINT WARNING "Active Blueprint version is not latest, you might run into compatibility issues."; fi
  cd .blueprint/tmp || cdhalt
  git clone "https://github.com/BlueprintFramework/templates.git"
  cd "${FOLDER}"/.blueprint || cdhalt
  cp -R tmp/templates/* extensions/blueprint/private/build/templates/
  rm -R tmp/templates
  cd "${FOLDER}" || cdhalt

  eval "$(parse_yaml "$__BuildDir"/templates/"${tnum}"/TemplateConfiguration.yml t_)"

  PRINT INFO "Building template.."
  mkdir -p .blueprint/tmp/init
  cp -R "$__BuildDir"/templates/"${tnum}"/contents/* .blueprint/tmp/init/

  sed -i \
    -e "s~␀name␀~${ASKNAME}~g" \
    -e "s~␀identifier␀~${ASKIDENTIFIER}~g" \
    -e "s~␀description␀~${ASKDESCRIPTION}~g" \
    -e "s~␀ver␀~${ASKVERSION}~g" \
    -e "s~␀author␀~${ASKAUTHOR}~g" \
    -e "s~␀version␀~${VERSION}~g" \
    -e "s~\[name\]~${ASKNAME}~g" \
    -e "s~\[identifier\]~${ASKIDENTIFIER}~g" \
    -e "s~\[description\]~${ASKDESCRIPTION}~g" \
    -e "s~\[ver\]~${ASKVERSION}~g" \
    -e "s~\[author\]~${ASKAUTHOR}~g" \
    -e "s~\[version\]~${VERSION}~g" \
    ".blueprint/tmp/init/conf.yml"

  # Return files to folder.
  cp -R .blueprint/tmp/init/* .blueprint/dev/

  # Remove tmp files.
  PRINT INFO "Cleaning up build files.."
  rm -R \
    ".blueprint/tmp" \
    "$__BuildDir/templates/"*
  mkdir -p .blueprint/tmp

  PRINT SUCCESS "Extension files initialized and imported to '.blueprint/dev'."
  sendTelemetry "INITIALIZE_DEVELOPMENT_EXTENSION" >> "$BLUEPRINT__DEBUG"
}