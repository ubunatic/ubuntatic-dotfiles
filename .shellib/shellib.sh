#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#


# === Setup Shellib Environment ===
SL_VERSION=0.0.1
test -z "$SL_RCFILE" && SL_RCFILE=.shellibrc
test -f "$SL_RCFILE" || SL_RCFILE=$HOME/.shellibrc
test -f "$SL_RCFILE" || SL_RCFILE=/etc/shellib/shellibrc
test -f "$SL_RCFILE" && source "$SL_RCFILE"

# === Init/Override Debug Vars ===
if test -n "$DEBUG"
then SL_DEBUG=true
else SL_DEBUG=false
fi

if $SL_DEBUG
then
	(( t_slstart   = `date +%s%3N`  ))
	(( t_slend     = t_slstart ))
	(( t_slsource  = -1 ))
fi

test -z "$SL_RELOAD_PLUGINS" && SL_RELOAD_PLUGINS=true

# copy of debug method from utils.sh (reqired before loading plugins)
debug() { $SL_DEBUG && { echo -n "DEBUG:"; echo "$@"; } 1>&2; }

# find shellib.sh (in given SL_DIR, in relative script source dirs, or elsewhere)
for dir in "$SL_DIR" "`dirname "$0"`" "`dirname "$BASH_SOURCE"`" . .shellib $HOME/.shellib \
	/opt/shellib /usr/local/lib/shellib /usr/lib/shellib; do
	if test -f "$dir/shellib.sh"
	then SL_DIR="$dir"; debug "SL_MAIN: found shellib in '$dir'"; break
	fi
done

isBash() { test -n "$BASH_VERSION"; }
isZsh()  { test -n "$ZSH_VERSION";  }

if isZsh; then
	setopt shwordsplit # enable bash-like unquoted string expansion for sring looping
fi

if $SL_DEBUG
then
	debug "SL_CWD=`pwd`"
	debug "SL_CALLEE_DIR=`dirname "$0"`"
	debug "SL_CALLEE=`basename "$0"`"
	debug "SL_DIR=$SL_DIR"
	debug "SL_RCFILE=$SL_RCFILE"
	debug "SL_DEBUG=$SL_DEBUG"
	debug "SL_RELOAD_PLUGINS=$SL_RELOAD_PLUGINS"
fi

shellib(){
	case "$1" in
		""|--help|-h)        __shellib_info;;
		--list|-l)           __shellib_plugin --list;;
		--init)              __shellib_init;;
		--plugin-active|-p)  shift; __shellib_plugin_is_loaded "$@";;
		*)                   shift; __shellib_plugin "$@";;
	esac
}

__shellib_info(){
	cat 1>&2 <<-INFO
		Shellib Shellscript Library $SL_VERSION (plugins: $SL_PLUGINS_LOADED)
		
		Usage: shellib [OPTIONS] [PLUGIN]
		
		Options/Arguments:
		
		   PLUGIN                 loads and registers $SL_DIR/<PLUGIN>.sh
		
		   --help | -h            show this info
		   --init                 loads and registers SL_PLUGINS: '$SL_PLUGINS'
		   --list | -l            prints active plugin names
		
		   --plugin-active | -p   test if PLUGIN is active
		
	INFO
}

__shellib_plugin_is_loaded() {
	local plugin="$@" p
	for p in $SL_PLUGINS_LOADED; do
		if test "$p" = "$plugin"; then debug "$plugin loaded"; return 0; fi
	done
	debug "$plugin not loaded"; return 1
}

__shellib_plugin() {
	test "$@" = "--list" && { echo "$SL_PLUGINS_LOADED"; return 0; }
	local p="$@"
	local script="$SL_DIR/$p.sh"
	if ! $SL_RELOAD_PLUGINS && __shellib_plugin_is_loaded $p
	then debug "plugin: $p already loaded use 'export SL_RELOAD_PLUGINS=true' to override"; return 0
	elif ! test -f "$script"
	then "could not source '$script'" 1>&2; return 1
	elif $SL_DEBUG
	then
		local t_libstart t_libsource
		(( t_libstart  = `date +%s%3N` ))
		source "$script"
		(( t_libsource = `date +%s%3N` - t_libstart ))
		debug "SL_SOURCE: '$script' $t_libsource (ms)"
	else source "$script"
	fi

	__shellib_plugin_is_loaded "$p" || export SL_PLUGINS_LOADED="$p $SL_PLUGINS_LOADED"
	return 0
}


__shellib_init() {
	if $SL_DEBUG
	then debug "SL_INIT: start `date +%F:%T.%3N`"
	fi
	local p; for p in $SL_PLUGINS; do
		__shellib_plugin "$p"
	done

	if $SL_DEBUG
	then
		(( t_slsend   = `date +%s%3N` ))
		(( t_slsource = $t_slsend - $t_slstart ))
		export LAST_SHELLIB_SOURCE_DURATION="$t_slsource (ms)"
		export LAST_SHELLIB_SOURCE_TIME="`date`"
		debug "SL_INIT: PATH      =  $PATH"
		debug "SL_INIT: duration  =  $t_slsource (ms)"
		debug "SL_INIT: end       =  `date +%F:%T.%3N`"
		debug "SL_INIT: plugins   =  `shellib -l`"
	fi

	isZsh && source $SL_DIR/omz-plugins/shellib.zsh
	return 0
}

shellib --init

