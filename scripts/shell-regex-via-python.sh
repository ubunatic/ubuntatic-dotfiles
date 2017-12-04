#!/usr/bin/env bash

match() {
	python <(cat <<-PY
		import re, sys, json
		for line in sys.stdin:
		   m = re.match(sys.argv[1], line)
		   if m: print(" ".join(m.groups()))
	PY
	) "$@"
}

echo -e "a1\nb2\nbad" | match '(\w+)(\d)'
