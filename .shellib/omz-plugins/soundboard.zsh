# install in /etc/zsh/zshrc or your personal .zshrc

__soundboard_complete() {
  typeset -a commands
  cwd=$PWD
  if cd ~/git/sounds; then
	  for f in **/*; do commands+=( "$f" ); done
  fi
  cd $cwd
  if (( CURRENT == 2 )); then
    # list sounds
    _values 'soundboard sounds' ${commands[@]}
    return
  fi
}

compdef __soundboard_complete soundboard

