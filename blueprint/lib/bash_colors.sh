#!/bin/bash
#
# This script may have been modified to work better with Blueprint.
# Source code: https://github.com/technobomz/bash_colors
#
# Constants and functions for terminal colors.
if [[ "$BASH_SOURCE" == "$0" ]]; then
    is_script=true
    set -eu -o pipefail
else
    is_script=false
fi
log_ESC="\033["

# All these variables has a function with the same name, but in lower case.
#
log_RESET=0             # reset all attributes to their defaults
log_RESET_UNDERLINE=24  # underline off
log_RESET_REVERSE=27    # reverse off
log_DEFAULT=39          # set underscore off, set default foreground color
log_DEFAULTB=49         # set default background color

log_BOLD=1              # set bold
log_BRIGHT=2            # set half-bright (simulated with color on a color display)
log_UNDERSCORE=4        # set underscore (simulated with color on a color display)
log_REVERSE=7           # set reverse video

log_BLACK=30            # set black foreground
log_RED=31              # set red foreground
log_GREEN=32            # set green foreground
log_BROWN=33            # set brown foreground
log_BLUE=34             # set blue foreground
log_MAGENTA=35          # set magenta foreground
log_CYAN=36             # set cyan foreground
log_WHITE=37            # set white foreground
log_YELLOW=33           # set yellow foreground

log_BLACKB=40           # set black background
log_REDB=41             # set red background
log_GREENB=42           # set green background
log_BROWNB=43           # set brown background
log_BLUEB=44            # set blue background
log_MAGENTAB=45         # set magenta background
log_CYANB=46            # set cyan background
log_WHITEB=47           # set white background
log_YELLOWB=43          # set yellow background


# check if string exists as function
# usage: if fn_exists "sometext"; then ... fi
function fn_exists
{
    type -t "$1" | grep -q 'function'
}

# iterate through command arguments, o allow for iterative color application
function log_layer
{
    # default echo setting
    log_ECHOSWITCHES="-e"
    log_STACK=""
    log_SWITCHES=""
    ARGS=("$@")

    # iterate over arguments in reverse
    for ((i=$#-1; i>=0; i--)); do
        ARG=${ARGS[$i]}
        # echo $ARG
        # set log_VAR as last argtype
        firstletter=${ARG:0:1}

        # check if argument is a switch
        if [ "$firstletter" = "-" ] ; then
            # if -n is passed, set switch for echo in log_escape
            if [[ $ARG == *"n"* ]]; then
                log_ECHOSWITCHES="-en"
                log_SWITCHES=$ARG
            fi
        else
            # last arg is the incoming string
            if [ -z "$log_STACK" ]; then
                log_STACK=$ARG
            else
                # if the argument is function, apply it
                if [ -n "$ARG" ] && fn_exists $ARG; then
                    #continue to pass switches through recursion
                    log_STACK=$($ARG "$log_STACK" $log_SWITCHES)
                fi
            fi
        fi
    done

    # pass stack and color var to escape function
    log_escape "$log_STACK" $1;
}

# General function to wrap string with escape sequence(s).
# Ex: log_escape foobar $log_RED $log_BOLD
function log_escape
{
    local result="$1"
    until [ -z "${2:-}" ]; do
	if ! [ $2 -ge 0 -a $2 -le 47 ] 2> /dev/null; then
	    echo "log_escape: argument \"$2\" is out of range" >&2 && return 1
	fi
        result="${log_ESC}${2}m${result}${log_ESC}${log_RESET}m"
	shift || break
    done
    
    echo "$log_ECHOSWITCHES" "$result"
    if [[ -f "$FOLDER/.blueprint/extensions/blueprint/private/debug/logs.txt" ]]; then 
        echo "$log_ECHOSWITCHES" "$result" >> .blueprint/extensions/blueprint/private/debug/logs.txt
        echo -e "\n" >> .blueprint/extensions/blueprint/private/debug/logs.txt
    fi
}

function log                 { log_layer $log_RESET "$@";           }
function log_reset           { log_layer $log_RESET "$@";           }
function log_reset_underline { log_layer $log_RESET_UNDERLINE "$@"; }
function log_reset_reverse   { log_layer $log_RESET_REVERSE "$@";   }
function log_default         { log_layer $log_DEFAULT "$@";         }
function log_defaultb        { log_layer $log_DEFAULTB "$@";        }
function log_bold            { log_layer $log_BOLD "$@";            }
function log_bright          { log_layer $log_BRIGHT "$@";          }
function log_underscore      { log_layer $log_UNDERSCORE "$@";      }
function log_reverse         { log_layer $log_REVERSE "$@";         }
function log_black           { log_layer $log_BLACK "$@";           }
function log_red             { log_layer $log_RED "$@";             }
function log_green           { log_layer $log_GREEN "$@";           }
function log_brown           { log_layer $log_BROWN "$@";           }
function log_blue            { log_layer $log_BLUE "$@";            }
function log_magenta         { log_layer $log_MAGENTA "$@";         }
function log_cyan            { log_layer $log_CYAN "$@";            }
function log_white           { log_layer $log_WHITE "$@";           }
function log_yellow          { log_layer $log_YELLOW "\e[1;33]$@";  }
function log_blackb          { log_layer $log_BLACKB "$@";          }
function log_redb            { log_layer $log_REDB "$@";            }
function log_greenb          { log_layer $log_GREENB "$@";          }
function log_brownb          { log_layer $log_BROWNB "$@";          }
function log_blueb           { log_layer $log_BLUEB "$@";           }
function log_magentab        { log_layer $log_MAGENTAB "$@";        }
function log_cyanb           { log_layer $log_CYANB "$@";           }
function log_whiteb          { log_layer $log_WHITEB "$@";          }
function log_yellowb         { log_layer $log_YELLOWB "\e[1;43]$@"; }

# Outputs colors table
function log_dump
{
    local T='gYw'

    echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m";

    for FGs in '   0m' '   1m' '  30m' '1;30m' '  31m' '1;31m' \
               '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m' \
               '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
    do
        FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m; do
            echo -en " \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
    done

    echo
    log_bold "    Code     Function           Variable"
    echo \
'    0        log_reset          $log_RESET
    1        log_bold           $log_BOLD
    2        log_bright         $log_BRIGHT
    4        log_underscore     $log_UNDERSCORE
    7        log_reverse        $log_REVERSE

    30       log_black          $log_BLACK
    31       log_red            $log_RED
    32       log_green          $log_GREEN
    33       log_brown          $log_BROWN
    34       log_blue           $log_BLUE
    35       log_magenta        $log_MAGENTA
    36       log_cyan           $log_CYAN
    37       log_white          $log_WHITE

    40       log_blackb         $log_BLACKB
    41       log_redb           $log_REDB
    42       log_greenb         $log_GREENB
    43       log_brownb         $log_BROWNB
    44       log_blueb          $log_BLUEB
    45       log_magentab       $log_MAGENTAB
    46       log_cyanb          $log_CYANB
    47       log_whiteb         $log_WHITEB
'
}

if [[ "$is_script" == "true" ]]; then
    log_dump
fi
