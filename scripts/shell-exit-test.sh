#!/bin/bash

# exit on all errors
set -e
# This will not work with commands in if condition or when used with boolean operators.
# For more details, see: `bash -c "help set"`.

usage() {
	cat 1>&2 <<-DOC
	Usage: $0 [func|help]
	
	This script tests and demonstrates 'set -e' behavior.
	It tests the cases where -e will have no effect and should exit after the a final
	failing test case where -e is effective. It should always exit with return code 1.

	Detailed usage:
	
	   $0       # run tests and exec failing command in main script
	   $0 func  # run tests and exec failing command inside function
	   $0 help  # show this help

	DOC
}

if test "$1" = "help"; then usage; exit 1; fi

isTrue()    { test "$1" = "true"; }

runTests() {
   echo "TEST: cmd=$cmd"

	echo -n "if:       "
	if $cmd
	then echo true
	else echo false
	fi

	echo -n "not-if:   "
	if ! $cmd
	then echo not true
	else echo not false
	fi
	
	echo -n "bool:     "
	$cmd && echo true || echo false

	echo -n "not-bool: "
	! $cmd && echo not true || echo not false
	
	echo -n "no-else-bool-and: "
     $cmd && echo true
	! $cmd && echo not true
	echo -n "no-else-bool-or: "
     $cmd || echo false
	! $cmd || echo not false

	echo OK

}

execInFunc() { echo "TEST: executing $cmd in func..."; $cmd; echo OK; }

echo START
cmd=true  runTests
cmd=false runTests
cmd="isTrue true"  runTests
cmd="isTrue false" runTests

cmd=false
case $1 in
	func)
		execInFunc
		echo "ERROR: executing of '$cmd' in function should have failed";;
	*)
		echo "TEST: executing $cmd directly"; $cmd; echo OK
		echo "ERROR: direct executing of '$cmd' should have failed";;
esac

