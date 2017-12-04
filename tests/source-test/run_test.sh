#!/bin/sh
log(){ echo $@ 1>&2; true; }

# Test if sourcing of relative dirs is supported
error=false
for sh in bash zsh; do
	log "testing $sh"
	if test -n `which $sh`
	then
		if $sh run.sh
		then log "OK"
		else log "FAIL"; error=true
		fi
	else
		log "$sh test skipped"
	fi
done

if $error
then log "some tests failed, see output above"; exit 1
else log "all tests passed"; exit 0
fi

