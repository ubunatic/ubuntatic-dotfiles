findJDK() {
	(  # run in subshell and fail early
		set -o errexit
		java=`which java`                    # find java
		java=`readlink -e "$java"`           # really find java
		readlink -e "`dirname $java`/../.."  # and determine the JDK path
	) 2> /dev/null                          # ignore any errors
}

