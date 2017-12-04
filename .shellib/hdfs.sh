# hdcp copies files to hadoop user dir
# currently it supports only zsh
hdcp() {
	local force=false
	while true; do case $1 in 
		--force|-f) force=true; shift;;
		--help|-h)  cat 1>&2 <<-EOF
			Usage:   $0 [-fh] hdcp FILE1 FILE2...
			Options: --force|-f   do not ask before each file
			         --help|-h    show this info
			EOF
			return 1;;
		*) break;; #no options should follow
	esac done

	for f in $@; do
		if $force
		then local key=y
		else warn -n "copy $f to hadoop? "; read -k 1 key; echo
		fi
		case $key in
			y|Y) scp -r $f name-node:dev/$f;;
			*)   warn "skipping to copy $f";;
		esac
	done
}

hdfs_du() {
	log_debug "running hdfs dfs -du" "$@"
	hdfs dfs -du $@ | sort -n | awk '
		{ print int($1/1e9), int($2/1e9), $3 }
	'
}

hdfs_space() {
	log_debug "running hdfs_space" "$@"
	local min_space=1, max_space=1e22 duargs=""
	while test $# -gt 0; do case $1 in
		--min)  min_space=$2; shift;;
		--max)  max_space=$2; shift;;
		--help) log_info "Usage: $0 --min MIN --max MAX <hdfs dfs -du args>"; return;;
		*)      duargs="$duargs $1";;
	esac; shift; done
	hdfs_du $duargs | awk -v max_space=$max_space -v min_space=$min_space '
		$1 > min_space && $1 < max_space { print $0 }
	'
}

hdfs_suckers() {
	log_debug "running hdfs_sucker" "$@"
	local hdfs_depth=1 space_args="" min_space=500
	while test $# -gt 0; do case $1 in
		--depth) hdfs_depth=$2; shift;;
		--min)   min_space=$2;  shift;;
		--help)  log_info "Usage: $0 --depth DEPTH --min MIN <hdfs_space args>"
			      hdfs_space --help
			      return;;
		*)       space_args="$space_args $1";;
	esac; shift; done

	# get and print level X suckers:
	local space_out="`hdfs_space --min $min_space $space_args`"
	log_debug "level $hdfs_depth suckers:"
	test -n "$space_out" && echo "$space_out" | sort -n

	# traverse suckers
	((hdfs_depth++))
	if test $hdfs_depth -lt 4; then
		for sucker in `echo "$space_out" | cut -d" " -f 3`; do 
			hdfs_suckers "$sucker" --min $min_space --depth $hdfs_depth
		done
	fi
}

ssh_hadoop(){ log_error "not implemented"; }

alias shadoop=ssh_hadoop

