export SL_ERRORS=0
export SL_BENCH_RESULT=""

math(){ (( $@ )) || true; }

log()      {                        { echo -n "INFO:";  echo "$@"; } 1>&2; }
warn()     {                        { echo -n "WARN:";  echo "$@"; } 1>&2; }
error()    { math SHELLIB_ERRORS++; { echo -n "ERROR:"; echo "$@"; } 1>&2; }
fail()     { math SHELLIB_ERRORS++; { echo -n "ERROR:"; echo "$@"; } 1>&2; false; }
panic()    { math SHELLIB_ERRORS++; { echo -n "PANIC:"; echo "$@"; } 1>&2; exit 1; }
debug()    {           $SL_DEBUG && { echo -n "DEBUG:"; echo "$@"; } 1>&2; }

# TODO: refactor usage of any log_* functions to log/warn/error/fail above
log_info() { { echo -n "INFO:";  echo "$@"; } 1>&2; }
log_warn() { { echo -n "WARN:";  echo "$@"; } 1>&2; }
log_error(){ { echo -n "ERROR:"; echo "$@"; } 1>&2; }
log_debug(){
	if test -n "$DEBUG" -a "$DEBUG" = true
	then { echo -n "DEBUG:"; echo "$@"; } 1>&2
	fi
}

isEmpty()  {   test  -z "$*"; }
notEmpty() { ! test  -z "$*"; }
isFile()   {   test  -f "$@"; }
isDir()    {   test  -d "$@"; }
canTouch() {   touch -c "$@"; }

bench() {
	local t_start t_bench ret
	math t_start = `date +%s%3N`
	"$@"; ret=$?
	math t_bench = `date +%s%3N` - t_start
	log "SL_BENCH: '$@' SL_BENCH_RESULT=${t_bench} (ms)"
	export SL_BENCH_RESULT="$t_bench"
	return $ret
}

assert()   {
	case "$1" in
		true)   shift;   expr "$@"        || fail "assert fail: '$@' not true"  ;;
		false)  shift; ! expr "$@"        || fail "assert fail: '$@' not false" ;;
		equals) shift; test "$1" = "$2"   || fail "assert fail: '$1' != '$2'"   ;;
		*)      fail "assert fail: unknown assertion type, '$1' not in [true|false|equals]";;
	esac 1> /dev/null
}

