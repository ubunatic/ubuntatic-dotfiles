# Author: Uwe Jugel, uwe.jugel@gmail.com

epoch(){
	case $1 in
		ms|mil*)        date +%s%3N ;;
		ns|nano*)       date +%s%N  ;;
		µs|us|mic*)     date +%s%6N ;;
		s|sec*)         date +%s    ;;
		-h|--help|help)
			cat 1>&2 <<-EOF
			Usage: epoch [s|ms|us|ns|sec*|mil*|mic*|nano*|-h|--help|help]
			prints seconds (default), millis, micros, or nanos since unix epoch
			EOF
			;;
		*)              date +%s    ;;
	esac
}

isZsh && source $SL_DIR/omz-plugins/epoch.zsh

