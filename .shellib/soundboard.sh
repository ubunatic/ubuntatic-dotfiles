# Please set your SOUNDBOARD_CMD in your ~/.profile

alias urldecode='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])"'
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])"'

findsounds(){
	cwd=$PWD
	cd $SOUNDBOARD_PATH
	find -type f | grep -i "$@" | sed -e 's/^\.\///'
	cd $cwd
}

encodeumlaut(){
	case "$@" in
		ö) p="%C3%B6";;
		Ö) p="%C3%96";;
		ä) p="%C3%A4";;
		Ä) p="%C3%84";;
		ü) p="%C3%BC";;
		Ü) p="%C3%9C";;
		ß) p="%C3%9F";;
	   \ ) p="%20";;
		*) p="$@";;
	esac
	echo "$p"
}

uml(){ echo "s/$@/`encodeumlaut $@`/g"; }

soundboardencode(){
	echo "$@" | sed \
		-e "`uml ö`" -e "`uml Ö`" \
		-e "`uml ü`" -e "`uml Ü`" \
		-e "`uml ä`" -e "`uml Ä`" \
		-e "`uml ß`" \
		-e "`uml ' '`"
}

soundboard() {
	test -z "$SOUNDBOARD_CMD"    && SOUNDBOARD_CMD="curl"
	test -z "$SOUNDBOARD_PREFIX" && SOUNDBOARD_PREFIX="localhost:8080/play/"
	debug "soundboard args: '$@'"
	if echo "$@" | grep '\.\(mp3\|wav\|mp4\)$'; then
		debug "playing file directly"
		file="$@"
	elif test -d "$SOUNDBOARD_PATH"; then
		debug "playing regex"
		file=`findsounds "$@" | head -n 1`
		warn "matched file: $file"
		warn "unmatched files:"
		findsounds "$@" | tail -n +2 | awk '{ print "   "$0}'
		warn ""
	else
		error "SOUNDBOARD_PATH:$SOUNDBOARD_PATH not found"
	fi
	file=`soundboardencode "$file"`
	warn "$SOUNDBOARD_CMD $SOUNDBOARD_OPTS $SOUNDBOARD_PREFIX$file"
	$SOUNDBOARD_CMD $SOUNDBOARD_OPTS "$SOUNDBOARD_PREFIX$file"
}
alias play='soundboard'

isZsh && source $SL_DIR/omz-plugins/soundboard.zsh

# vim:ft=sh:
