simple_clock()  {
	echo -ne "\r"
	case "$1" in
		1|2|7|8)   echo -n '/';;
		3|9)       echo -n '—';;
		4|5|10|11) echo -n '\';;
		6|12|0)    echo -n '|';;
	esac
}

uni_clock()  {
	echo -ne "\r";
	case "$1" in
		1) echo -n '🕐 ';;  5) echo -n '🕔 ';;  9)    echo -n '🕘 ';;
		2) echo -n '🕑 ';;  6) echo -n '🕕 ';;  10)   echo -n '🕙 ';;
		3) echo -n '🕒 ';;  7) echo -n '🕖 ';;  11)   echo -n '🕚 ';;
		4) echo -n '🕓 ';;  8) echo -n '🕗 ';;  12|0) echo -n '🕛 ';;
	esac
}

pie_clock(){
	echo -ne "\r"
	case $1 in
		1|5|9)    echo -n '◴ ';;
		2|6|10)   echo -n '◵ ';;
		3|7|11)   echo -n '◶ ';;
		4|8|12|0) echo -n '◷ ';;
	esac
}
