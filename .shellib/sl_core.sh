# Author: Uwe Jugel, uwe.jugel@gmail.com

if ! test -z "$DEBUG" || test "$DEBUG" = "true" || test "$SL_DEBUG" = "true"
then SL_DEBUG=true
else SL_DEBUG=false
fi

test -z "$SL_LOAD_PLUGINS" && SL_LOAD_PLUGINS=true
test -z "$SL_REPLAY"       && SL_REPLAY=always

if $SL_DEBUG
then
	(( t_profilestart   = `date +%s%3N`  ))
	(( t_profilesource  = t_profilestart ))
fi

warn()     {              echo $@ 1>&2; }
debug()    { $SL_DEBUG && echo $@ 1>&2; }
isBash()   { test -n "$BASH_VERSION"; }
isZsh()    { test -n "$ZSH_VERSION";  }

__sourcedir() {
	if echo "$@" | grep "^$SL_DIR" > /dev/null
	then echo "$SL_DIR"; debug "SL_SOURCE_DIR: using SL_DIR"
	else dirname "$@";   debug "SL_SOURCE_DIR: using 'dirname'"
	fi
}

__source() {	
	if $SL_DEBUG
	then
		(( t_libstart = `date +%s%3N` ))
		source `__sourcedir "$@"`/`basename "$@"`
		(( t_libsource = `date +%s%3N` - t_libstart ))
		debug "SL_SOURCE: '$1' $t_libsource (ms)"
	else source $1
	fi
}

__bench() {
	if $SL_DEBUG
	then
		(( t_start = `date +%s%3N` ))
		$@
		ret=$?
		(( t_bench = `date +%s%3N` - t_start ))
		debug "SL_BENCH:  '$@' $t_bench (ms)"
		return $ret
	else $@
	fi
}

__start() {
	if $SL_DEBUG
	then debug "SL_PROFILE: start `date +%T.%3N`"
	fi
}

__end() {
	if $SL_DEBUG
	then
		(( t_profilesource = `date +%s%3N` - t_profilestart ))
		export LAST_PROFILE_SOURCE_DURATION="$t_profilesource (ms)"
		export LAST_PROFILE_SOURCE_TIME="`date`"
		debug "SL_PROFILE: PATH  $PATH"
		debug "SL_PROFILE: total $t_profilesource (ms)"
		debug "SL_PROFILE: end   `date +%T.%3N`"
	fi
}
