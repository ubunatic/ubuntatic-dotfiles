# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

alias warn="cat 1>&2 <<<"

isBash()         { test -n "$BASH_VERSION"     }
isZsh()          { test -n "$ZSH_VERSION";     }
isEmpty()        { test -z "$@";               }
isFile()         { test -f "$@";               }
isDir()          { test -d "$@";               }
canTouch()       { touch -c "$@" 2> /dev/null; }

export_gopath() { export GOPATH="$@" && warn "GOPATH set to '$@'"; }

checkPATH()  {
	dir=`cd "$@" 2> /dev/null && pwd` &&              # try to access the dir
	! echo ":$PATH:" | grep ":$dir:" > /dev/null &&   # test if it is already in the PATH
	echo "$dir"                                       # print if found and not in PATH
}

isBash &&                                            # if running bash
test -f "$HOME/.bashrc" &&                           # and .bashrc exists
source "$HOME/.bashrc"                               # source it!

for p in $HOME /usr/local /usr / /usr/local/games /usr/local/go; do
	p1=`checkPATH $p/bin`                             # check and fix bin subdirs,
	p2=`checkPATH $p/sbin`                            # sbin subdir,
	p=`checkPATH $p`                                  # and the base dir itself

	test -d "$p1" && export PATH="$p1:$PATH"          # try to add bin dir
	test -d "$p2" && export PATH="$p2:$PATH"          # try to add sbin dir
	test -z "$p1" && test -z "$p2" &&                 # otherwise
	test -d "$p" && export PATH="$p:$PATH"            # add basedir itself
done

test -z "$GOPATH" && mkdir $HOME/dev &&
export GOPATH=$HOME/dev

alias run=./run.sh
alias res="./run.sh restart"
alias cmd="./run.sh cmd"

export LAST_PROFILE_SOURCE_TIME=`date`

