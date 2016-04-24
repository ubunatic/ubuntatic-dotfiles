# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

#DEBUG t_profilestart=`date +%s%3N`

# === General Settings ans helpers for all systems ===

epoch(){
	case $1 in
		ms|mil*)    date +%s%3N ;;
		ns|nano*)   date +%s%N  ;;
		µs|us|mic*) date +%s%6N ;;
		*)          date +%s    ;;
	esac
}

isBash()   { test -n "$BASH_VERSION"; }
isZsh()    { test -n "$ZSH_VERSION";  }

warn()     { echo $@  1>&2; }
isEmpty()  { test  -z "$@"; }
isFile()   { test  -f "$@"; }
isDir()    { test  -d "$@"; }
canTouch() { touch -c "$@" 2> /dev/null; }

checkPATH()  {
	#dir=`cd "$@" 2> /dev/null && pwd` &&             # try to access the dir (disabled, too slow!)
	dir="$@"
	! echo ":$PATH:" | grep ":$dir:" > /dev/null &&   # test if it is already in the PATH
	echo "$dir"                                       # print if found and not in PATH
}

setGOPATH() { p=`cd "$@" && pwd` && export GOPATH="$p"     && warn "GOPATH is now '$GOPATH'"; }
addPATH()   { p=`checkPATH $@`   && export PATH="$PATH:$p" && warn "PATH is now '$PATH'";     }

isBash &&                                            # if running bash
isFile $HOME/.bashrc &&                              # and .bashrc exists
source $HOME/.bashrc                                 # source it!

# for all dirs modify PATH only if dir exists and is not yet in PATH
# (ensures replayability of the script)
for d in $HOME / /usr /usr/local /usr/local/games /usr/local/go; do
	p1=`checkPATH $d/bin`                             # check and fix bin subdirs,
	p2=`checkPATH $d/sbin`                            # sbin subdir,
	p3=`checkPATH $d`                                 # and the base dir itself

	test -d "$p1" && export PATH="$p1:$PATH"          # first try to add bin  dir
	test -d "$p2" && export PATH="$p2:$PATH"          # also  try to add sbin dir

	! test -d "$p1" && ! test -d "$p2" &&             # if both additions failed
	test -d "$p3" && export PATH="$p3:$PATH"          # add the basedir
done

#DEBUG (( t_profilesource = `date +%s%3N` - t_profilestart ))
#DEBUG export LAST_PROFILE_SOURCE_DURATION="$t_profilesource ms"
#DEBUG export LAST_PROFILE_SOURCE_TIME="`date`"

# == Custom Settings ===

test -z "$GOPATH" && mkdir -p $HOME/dev &&
export GOPATH="$HOME/dev"

alias run="./run.sh"
alias res="./run.sh restart"
alias cmd="./run.sh cmd"


