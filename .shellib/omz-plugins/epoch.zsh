# install in /etc/zsh/zshrc or your personal .zshrc

__epoch_complete() {
  typeset -a commands
  commands+=(
    'help[display help]'
	 's[display seconds since epoch]'
	 'ms[display milliseconds since epoch]'
	 'us[display miroseconds since epoch]'
	 'ns[display nanoseconds since epoch]'
  )
  if (( CURRENT == 2 )); then
    # explain epoch commands
    _values 'epoch commands' ${commands[@]}
    return
  fi
}

compdef __epoch_complete epoch

