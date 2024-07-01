#!/bin/bash

Command() {
  PRINT WARNING "This is an advanced feature, only proceed if you know what you are doing."
  dbRemove "blueprint.setupFinished"
  cd "${FOLDER}" || cdhalt
  bash blueprint.sh
}