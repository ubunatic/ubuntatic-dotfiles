error()    { echo $@ 1>&2; false; }
warn()     { echo $@ 1>&2; true;  }
debug()    { $SL_DEBUG && echo $@ 1>&2; true; }

isEmpty()  { test  -z "$@"; }
notEmpty() { test  -n "$@"; }
isFile()   { test  -f "$@"; }
isDir()    { test  -d "$@"; }
canTouch() { touch -c "$@"; }

bench() {
	(( t_start = `date +%s%3N` ))
	$@
	ret=$?
	(( t_bench = `date +%s%3N` - t_start ))
	warn "SL_BENCH:  '$@' ${t_bench}ms"
	return $ret
}

assert()   {
	case $1 in
		true)   shift;   expr $@          || error "assert fail: '$@' not true"  ;;
		false)  shift; ! expr $@          || error "assert fail: '$@' not false" ;;
		equals) shift; test "$1" = "$2"   || error "assert fail: '$1' != '$2'"   ;;
		*)      error "assert fail: unknown assertion '$1' not in [true|false|equals]";;
	esac 1> /dev/null
}

test -f "$HOME/.hosts" && export HOSTALIASES="$HOME/.hosts" # setup host aliases
