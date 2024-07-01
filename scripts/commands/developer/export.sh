#!/bin/bash

Command() {
  # Check for developer mode through the database library.
  if ! dbValidate "blueprint.developerEnabled"; then PRINT FATAL "Developer mode is not enabled.";exit 2; fi

  if [[ -z $(find .blueprint/dev -maxdepth 1 -type f -not -name ".gitkeep" -print -quit) ]]; then
    PRINT FATAL "Development directory is empty."
    exit 2
  fi

  PRINT INFO "Start packaging extension.."

  cd .blueprint || cdhalt
  rm dev/.gitkeep 2>> "$BLUEPRINT__DEBUG"

  eval "$(parse_yaml dev/conf.yml conf_)"; identifier="${conf_info_identifier}"

  cp -r dev/* tmp/
  cd tmp || cdhalt

  # Assign variables to extension flags.
  flags="$conf_info_flags"
  PRINT INFO "Reading and assigning extension flags.."
  assignflags

  if $F_hasExportScript; then
    chmod +x "${conf_data_directory}""/export.sh"

    # Run script while also parsing some useful variables for the export script to use.
    if $F_developerEscalateExportScript; then
      EXTENSION_IDENTIFIER="$conf_info_identifier"        \
      EXTENSION_TARGET="$conf_info_target"                \
      EXTENSION_VERSION="$conf_info_version"              \
      PTERODACTYL_DIRECTORY="$FOLDER"                     \
      BLUEPRINT_EXPORT_DIRECTORY="$FOLDER/.blueprint/tmp" \
      BLUEPRINT_VERSION="$VERSION"                        \
      bash "${conf_data_directory}"/export.sh
    else
      su "$WEBUSER" -s "$USERSHELL" -c "
          cd \"$FOLDER\"/.blueprint/tmp;
          EXTENSION_IDENTIFIER=\"$conf_info_identifier\"        \
          EXTENSION_TARGET=\"$conf_info_target\"                \
          EXTENSION_VERSION=\"$conf_info_version\"              \
          PTERODACTYL_DIRECTORY=\"$FOLDER\"                     \
          BLUEPRINT_EXPORT_DIRECTORY=\"$FOLDER/.blueprint/tmp\" \
          BLUEPRINT_VERSION=\"$VERSION\"                        \
          bash \"${conf_data_directory}\"/export.sh
        "
    fi
    echo -e "\e[0m\x1b[0m\033[0m"
  fi

  zip -r extension.zip ./*
  cd "${FOLDER}" || cdhalt
  cp .blueprint/tmp/extension.zip "${identifier}.blueprint"
  rm -R .blueprint/tmp
  mkdir -p .blueprint/tmp

  if [[ $1 == "expose"* ]]; then
    PRINT INFO "Generating download url.. (expires after 2 minutes)"
    randstr=${RANDOM}${RANDOM}${RANDOM}${RANDOM}${RANDOM}
    mkdir .blueprint/extensions/blueprint/assets/exports/${randstr}
    cp "${identifier}".blueprint .blueprint/extensions/blueprint/assets/exports/${randstr}/"${identifier}".blueprint

    PRINT SUCCESS "Extension has been exported to '$(grabAppUrl)/assets/extensions/blueprint/exports/${randstr}/${identifier}.blueprint' and '${FOLDER}/${identifier}.blueprint'."
    sleep 120 && rm -R .blueprint/extensions/blueprint/assets/exports/${randstr} 2>> "$BLUEPRINT__DEBUG" &
  else
    PRINT SUCCESS "Extension has been exported to '${FOLDER}/${identifier}.blueprint'."
  fi
  sendTelemetry "EXPORT_DEVELOPMENT_EXTENSION" >> "$BLUEPRINT__DEBUG"
}