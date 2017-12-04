#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#

checkPATH() {
	local dir="$@"
	if echo ":$PATH:" | grep -o ":$dir:" > /dev/null
	then return 1  # dir already in PATH
	else return 0  # dir not in path
	fi
}

addPATH() {
	local dir="$@"
	if ! test -z "$dir" && checkPATH "$dir"
	then export PATH="$PATH:$dir"
	fi
}

# for all dirs modify PATH only if dir exists and is not yet in PATH
# (ensures replayability of the script)
updatePaths(){
	local dir old_path="`echo "$PATH" | sed 's/:/ /g'`"
	export PATH="/bin:/usr/bin"  # start with minimal path
	for dir in $old_path \
		/bin             /sbin                \
		/usr/bin         /usr/sbin            \
		/usr/local/bin   /usr/local/sbin      \
		$HOME/bin        $HOME/sbin           \
		$HOME/.local/bin $HOME/.local/sbin
	do
		addPATH "$dir"
	done
}

updatePaths

