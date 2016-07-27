# install in /etc/zsh/zshrc or your personal .zshrc

__shellib_complete() {	
	local SL_DEBUG=false
	typeset -a commands
	for p in `echo "$SL_PLUGINS" | sed 's# #\n#g'`; do
		test -n "$p" && ! shellib -p "$p" &&
			commands+=( $p'[load plugin '$SL_DIR'/'$p'.sh]' )
	done
	if test -n "$SL_PLUGINS_LOADED"
	then commands+=( '--list[list active plugins: '$SL_PLUGINS_LOADED']' )
	else commands+=( '--list[list active plugins]' )
	fi
	commands+=(
		   '--help[show usage info]'
		   '--init[loads and registers SL_PLUGINS: '$SL_PLUGINS']'
		   '--plugin-active[test if PLUGIN is active]'
	)

	if (( CURRENT == 2 )); then
		# explain shellib commands
		_values 'shellib commands' ${commands[@]}
		return
	fi
}

compdef __shellib_complete shellib

