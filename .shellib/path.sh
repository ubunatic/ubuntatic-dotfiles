#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#

checkPATH() {
	#dir=`cd "$@" 2> /dev/null && pwd` &&      # try to access the dir (disabled, too slow!)
	dir="$@"
	test -d "$dir" && ! echo ":$PATH:" |
		grep ":$dir:" > /dev/null &&            # test if it is already in the PATH
		echo "$dir"                             # print if not in PATH and return grep exit code
}

addPATH() {
	if ! test -z "$@" &&	p=`checkPATH $@`
	then export PATH="$PATH:$p" #; warn "PATH is now '$PATH'" #disabled to avoid messages at desktop login
	fi
}

# for all dirs modify PATH only if dir exists and is not yet in PATH
# (ensures replayability of the script)
updatePaths(){
	for dir in \
		/bin             /sbin                \
		/usr/bin         /usr/sbin            \
		/usr/local/bin   /usr/local/sbin      \
		$HOME/bin        $HOME/sbin           \
		$HOME/.local/bin $HOME/.local/sbin
	do
		dir=`checkPATH $dir` && export PATH="$dir:$PATH" 
	done
}

updatePaths

