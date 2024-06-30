#!/bin/bash

Command() {
  # This is logged as a "fatal" error since it's something that is making Blueprint run unsuccessfully.
  PRINT FATAL "'$1' is not a valid command or argument. Use argument '-help' for a list of commands."
  exit 2
}