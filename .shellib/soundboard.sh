# Please set your SOUNDBOARD_CMD in your ~/.profile

alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'

findsounds(){
	cd $SOUNDBOARD_PATH
	find | grep -i "$@" |  sed -e 's/^\.\///'
	cd $cwd
}

soundboard() {
	test -z "$SOUNDBOARD_CMD"    && SOUNDBOARD_CMD="curl"
	test -z "$SOUNDBOARD_PREFIX" && SOUNDBOARD_PREFIX="localhost:8080/play/"
	cwd=$PWD
	debug "soundboard args: '$@'"
	if echo "$@" | grep '\.\(mp3\|wav\|mp4\)$'
	then
		debug "playing file directly"
		file="$@"
	elif test -d "$SOUNDBOARD_PATH"
	then
		debug "playing regex"
		file=`findsounds $@ | head -n 1`
		warn "unmatched files:"
		findsounds $@ | tail -n +2 | awk '{ print "   "$0}'
		warn ""
	else
		error "SOUNDBOARD_PATH:$SOUNDBOARD_PATH not found"
	fi
	file=`urlencode "$file"`
	warn "$SOUNDBOARD_CMD $SOUNDBOARD_OPTS $SOUNDBOARD_PREFIX$file"
	$SOUNDBOARD_CMD $SOUNDBOARD_OPTS "$SOUNDBOARD_PREFIX$file"
}
alias play='soundboard'

isZsh && source $SL_DIR/omz-plugins/soundboard.zsh

# vim:ft=sh:
