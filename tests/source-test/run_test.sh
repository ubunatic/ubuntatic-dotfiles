#!/bin/sh
warn(){ echo $@ 1>&2; true; }

# Test if sourcing of relative dirs is supported
error=false
for sh in bash zsh; do
	warn "testing $sh"
	if test -n `which $sh`
	then
		if $sh run.sh
		then warn "OK"
		else warn "FAIL"; error=true
		fi
	else
		warn "$sh test skipped"
	fi
done

if $error
then warn "some tests failed, see output above"; exit 1
else warn "all tests passed"; exit 0
fi

