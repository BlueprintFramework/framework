#!/bin/bash
# 
# This script has been created as part of the Blueprint source code
# and uses the same license as the rest of the codebase.

_blueprint="-install -remove -init -build -export -wipe -version -help -info -debug -upgrade -rerun-install"
complete -W "${_blueprint}" 'blueprint'