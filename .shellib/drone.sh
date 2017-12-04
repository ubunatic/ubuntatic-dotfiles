
drone_last_build_number () {
	drone build list $DRONE_PROJECT | head -n1 | cut -d" " -f 2 | grep -o '[0-9]\+'
}

drone_last_build_logs () {
	drone build info $DRONE_PROJECT `drone_last_build_number`
	drone build logs $DRONE_PROJECT `drone_last_build_number`
}

