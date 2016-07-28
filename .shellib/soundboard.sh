soundboard() {
	test -z $SOUNDBOARD_CMD    && SOUNDBOARD_CMD="curl"
	test -z $SOUNDBOARD_PREFIX && SOUNDBOARD_PREFIX="localhost:8080/play/"
	cwd=$PWD
	debug "soundboard args: '$@'"
	if echo "$@" | grep '\.\(mp3\|wav\|mp4\)$'
	then
		debug "playing file directly"
		file="$@"
	elif test -d "$SOUNDBOARD_PATH"
	then
		debug "playing regex"
		cd $SOUNDBOARD_PATH
		file=`find | grep "$@" | head -n1`
		cd $cwd
	else 
		error "SOUNDBOARD_PATH:$SOUNDBOARD_PATH not found"
	fi
	file=`echo "$file" | sed 's/ /%20/g'`
	echo "$SOUNDBOARD_CMD $SOUNDBOARD_PREFIX$file"
	$SOUNDBOARD_CMD $SOUNDBOARD_PREFIX$file
}
alias play='soundboard'

isZsh && source $SL_DIR/omz-plugins/soundboard.zsh

# vim:ft=sh:
