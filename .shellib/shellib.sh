#
# Author: Uwe Jugel, uwe.jugel@gmail.com
#


# === Setup Minimal Environment ===
SL_VERSION=0.0.1
test -z "$SL_RCFILE" && SL_RCFILE=.shellibrc
test -f "$SL_RCFILE" || SL_RCFILE=$HOME/.shellibrc
test -f "$SL_RCFILE" || SL_RCFILE=/etc/shellib/shellibrc
test -f "$SL_RCFILE" && source "$SL_RCFILE"

test -z "$SL_DIR"    && SL_DIR=`dirname $0`

# === Setup Remaining Environment ===

if test -n "$DEBUG" && ! test "$DEBUG" = "false" || test "$SL_DEBUG" = "true"
then SL_DEBUG=true
else SL_DEBUG=false
fi

test -z "$SL_RELOAD_PLUGINS" && SL_RELOAD_PLUGINS=true

warn()     {              echo $@ 1>&2; }
debug()    { $SL_DEBUG && echo $@ 1>&2; }
isBash()   { test -n "$BASH_VERSION"; }
isZsh()    { test -n "$ZSH_VERSION";  }

if $SL_DEBUG
then
	(( t_slstart   = `date +%s%3N`  ))
	(( t_slsource  = t_slstart ))
	debug "SL_DIR=$SL_DIR"
	debug "SL_RCFILE=$SL_RCFILE"
	debug "SL_DEBUG=$SL_DEBUG"
	debug "SL_RELOAD_PLUGINS=$SL_RELOAD_PLUGINS"
fi

shellib(){
	if test -z "$1"
	then __shellib_info
	else case $1 in
		--help|-h)           __shellib_info;;
		--list|-l)           __shellib_plugin --list;;
		--init)              __shellib_init $SL_PLUGINS;;
		--plugin-active|-p)  shift; __shellib_plugin_is_loaded $@;;
		*)                   shift; __shellib_plugin $@;;
	esac fi
}

__shellib_info(){
	cat 1>&2 <<-INFO
		Shellib Shellscript Library $SL_VERSION (plugins: $SL_PLUGINS_LOADED)
		
		Usage: shellib [OPTIONS] [PLUGIN]
		
		Options/Arguments:
		
		   PLUGIN        # loads and registers $SL_DIR/PLUGIN.sh
		
		   --help | -h   # show this info
		   --init        # loads and registers SL_PLUGINS: '$SL_PLUGINS'
		   --list | -l   # prints active plugin names
		
		   --plugin-active | -p   # test if PLUGIN is active
		
	INFO
}

__shellib_plugin_is_loaded() {
	case " $SL_PLUGINS_LOADED " in
		*" $@ "*) debug "$@ loaded";     return 0;;
		*)        debug "$@ not loaded"; return 1;;
	esac
}

__shellib_plugin() {
	test "$@" = "--list" && echo "$SL_PLUGINS_LOADED" && return 0
	p="$@"
	f="$SL_DIR/$p.sh"
	if ! $SL_RELOAD_PLUGINS && __shellib_plugin_is_loaded $p
	then debug "plugin: $p already loaded use 'export SL_RELOAD_PLUGINS=true' to override"; return 0
	elif ! test -f "$f"
	then warn "could not source '$f'"; return 1
	elif $SL_DEBUG
	then
		(( t_libstart = `date +%s%3N` ))
		source "$f"
		(( t_libsource = `date +%s%3N` - t_libstart ))
		debug "SL_SOURCE: '$f' $t_libsource (ms)"
	else source "$f"
	fi

	__shellib_plugin_is_loaded $p || export SL_PLUGINS_LOADED="$p $SL_PLUGINS_LOADED"
}


__shellib_init() {
	if $SL_DEBUG
	then debug "SL_INIT: start `date +%T.%3N`"
	fi

	for p in `echo "$SL_PLUGINS" | sed 's# #\n#g'`; do
		__shellib_plugin $p
	done

	if $SL_DEBUG
	then
		(( t_slsource = `date +%s%3N` - t_slstart ))
		export LAST_SHELLIB_SOURCE_DURATION="$t_slsource (ms)"
		export LAST_SHELLIB_SOURCE_TIME="`date`"
		debug "SL_INIT: PATH     $PATH"
		debug "SL_INIT: total    $t_slsource (ms)"
		debug "SL_INIT: end      `date +%T.%3N`"
		debug "SL_INIT: plugins  `shellib -l`"
	fi

	isZsh && source $SL_DIR/omz-plugins/shellib.zsh
}

shellib --init

