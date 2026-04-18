#!/bin/bash
# lockfile manager

lockfile_print_warning() {
  PRINT WARNING "Lockfile error, check debug log for more information"
}

lock_create() {
  if [[ $BLUEPRINT__FOLDER == "" ]]; then
    PRINT DEBUG "(lock.sh) lockfile could not be locked, \$BLUEPRINT__FOLDER is empty"
    lockfile_print_warning
    return 1
  fi
  if [ ! -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; then
    touch "$BLUEPRINT__FOLDER/.blueprint/lock" &> "$BLUEPRINT__DEBUG"
    if [ -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; then
      PRINT DEBUG "(lock.sh) lockfile created"
      return 0
    else
      PRINT DEBUG "(lock.sh) lockfile creation was attempted, was not successful"
      lockfile_print_warning
      return 1
    fi
  else
    PRINT DEBUG "(lock.sh) lockfile was already locked"
    lockfile_print_warning
    return 1
  fi
}

lock_remove() {
  if [[ $BLUEPRINT__FOLDER == "" ]]; then
    PRINT DEBUG "(lock.sh) lockfile could not be unlocked, \$BLUEPRINT__FOLDER is empty"
    lockfile_print_warning
    return 1
  fi

  if [ ! -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; then
    PRINT DEBUG "(lock.sh) Lockfile was already unlocked"
    lockfile_print_warning
    return 1
  fi

  rm "$BLUEPRINT__FOLDER/.blueprint/lock" &> "$BLUEPRINT__DEBUG"

  if [ -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; then
    PRINT DEBUG "(lock.sh) Lockfile unlock attempted, did not succeed"
    lockfile_print_warning
    return 1
  fi
  return 0
}

lock_wait() {
  if [ -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; then
    PRINT DEBUG "(lock.sh) found lockfile, waiting for file to be removed"
    PRINT WARNING "Lockfile found, waiting for file to be unlocked.."

    local i
    i=1

    while [ -f "$BLUEPRINT__FOLDER/.blueprint/lock" ]; do
      sleep 5
      PRINT DEBUG "(lock.sh) lockfile still persistent ($i tries)"
      ((i++))
    done
  fi
}
