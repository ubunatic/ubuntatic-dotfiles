#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#
# source this file from your custom .profile
# to setup the main PATHs and add a few utils

test -z "$SL_DIR"    && SL_DIR=$HOME/.shellib
test -z "$SL_RCFILE" && SL_FILE=$HOME/.shellibrc

test -e "$SL_RCFILE" && source "$SL_RCFILE"

source "$SL_DIR/sl_core.sh"

__start

__source .shellib/epoch.sh
__source .shellib/path.sh

isEmpty()  { test  -z "$@"; }
isFile()   { test  -f "$@"; }
isDir()    { test  -d "$@"; }
canTouch() { touch -c "$@" 2> /dev/null; }

if test "$SL_REPLAY" = "always"
then
	isBash   &&                                            # if running bash
	isFile   $HOME/.bashrc &&                              # and .bashrc exists
	__source $HOME/.bashrc                                 # source it!
fi

test -f "$HOME/.hosts" && export HOSTALIASES="$HOME/.hosts" # setup host aliases

__end

# vim:ft=sh:
