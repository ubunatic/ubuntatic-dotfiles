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
	warn "SL_BENCH:  '$@' $t_bench (ms)"
	return $ret
}

test -f "$HOME/.hosts" && export HOSTALIASES="$HOME/.hosts" # setup host aliases
