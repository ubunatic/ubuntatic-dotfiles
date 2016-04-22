#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#
# source this file from your custom .profile
# to setup the main PATHs and add a few utils

epoch()      { date +%s;    }
epoch-ms()   { date +%s%3N; }
epoch-nano() { date +%s%N;  }

isBash()    { test -n "$BASH_VERSION"; }
isZsh()     { test -n "$ZSH_VERSION";  }

warn()      { echo $@  1>&2;              }
isEmpty()   { test  -z "$@";              }
isFile()    { test  -f "$@";              }
isDir()     { test  -d "$@";              }
canTouch()  { touch -c "$@" 2> /dev/null; }

checkPATH()  {
	dir=`cd "$@" 2> /dev/null && pwd` &&              # try to access the dir
	! echo ":$PATH:" | grep ":$dir:" > /dev/null &&   # test if it is already in the PATH
	echo "$dir"                                       # print if found and not in PATH
}

setGOPATH() { p=`cd "$@" && pwd` && export GOPATH="$p"   && warn "GOPATH is now '$GOPATH'"; }
addPATH()   { p=`checkPATH $@` && export PATH="$PATH:$p" && warn "PATH is now '$PATH'";     }

isBash &&                                            # if running bash
isFile $HOME/.bashrc &&                              # and .bashrc exists
source $HOME/.bashrc                                 # source it!

for p in $HOME /usr/local /usr / /usr/local/games /usr/local/go; do
	p1=`checkPATH $p/bin`                             # check and fix bin subdirs,
	p2=`checkPATH $p/sbin`                            # sbin subdir,
	p=`checkPATH $p`                                  # and the base dir itself

	test -d "$p1" && export PATH="$p1:$PATH"          # try to add bin dir
	test -d "$p2" && export PATH="$p2:$PATH"          # try to add sbin dir
	test -z "$p1" && test -z "$p2" &&                 # otherwise
	test -d "$p" && export PATH="$p:$PATH"            # add basedir itself
done

test -f "$HOME/.hosts" && export HOSTALIASES="$HOME/.hosts" # setup host aliases

export LAST_PROFILE_SOURCE_TIME=`date`

# vim:ft=sh:
