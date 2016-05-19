#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#

checkPATH() {
	#dir=`cd "$@" 2> /dev/null && pwd` &&             # try to access the dir (disabled, too slow!)
	dir="$@"
	! echo ":$PATH:" | grep ":$dir:" > /dev/null &&   # test if it is already in the PATH
	echo "$dir"                                       # print if found and not in PATH
}

addPATH() {
	if ! test -z "$@" &&	p=`checkPATH $@`
	then export PATH="$PATH:$p"; warn "PATH is now '$PATH'"
	fi
}

# golang support
if which go > /dev/null
then
	setGOPATH() { 
		if p=`cd "$@" && pwd` && export GOPATH="$p"
		then warn "GOPATH is now '$GOPATH'"
		else warn "GOPATH not set to '$@' (make sure that the dir is accessible)"
		fi
	}
fi

# for all dirs modify PATH only if dir exists and is not yet in PATH
# (ensures replayability of the script)
updatePaths(){
	for d in /bin /sbin /usr /usr/local /usr/local/games /usr/local/go $HOME/bin $HOME/sbin; do
		p1=`checkPATH $d/bin`                             # check and fix bin subdirs,
		p2=`checkPATH $d/sbin`                            # sbin subdir,
		p3=`checkPATH $d`                                 # and the base dir itself

		test -d "$p1" && export PATH="$p1:$PATH"          # first try to add bin  dir
		test -d "$p2" && export PATH="$p2:$PATH"          # also  try to add sbin dir

		! test -d "$p1" && ! test -d "$p2" &&             # if both additions failed
		test -d "$p3" && export PATH="$p3:$PATH"          # add the basedir
	done
}

updatePaths

