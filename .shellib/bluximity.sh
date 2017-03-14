bluximity() {
	case $1 in
		add)     shift; __bluximity_add   $@;;
		rm)      shift; __bluximity_rm    $@;;
		watch)   shift; __bluximity_watch $@;;
		list)    shift; __bluximity_list  $@;;
		devices) shift; __bluximity_listdevices $@;;
		details) shift; __bluximity_details $@;;
	esac
}

__bluximity_config="$HOME/.bluximity/config"

__bluximity_savemac(){
	mac=`echo "$@" | grep -io '(.*)' | grep -io '[0-9a-z:]\+'`
	if test -z "$mac"; then
		warn "MAC is empty"; return 1
	fi
	name=`echo "$@" | sed -e "s/ ($mac)//"`
	mkdir -p "`dirname $__bluximity_config`" 2> /dev/null
	num=`cat $__bluximity_config | grep '^[0-9]' | tail -n1 | awk '{print $1}'`
	test -z "$num" && num=0; (( num = num + 1 ))
	#if grep -e "$mac" $__bluximity_config > /dev/null; then
	#	warn "MAC $mac found in $__bluximity_config"; return
	#fi
	if echo "$num $mac $name" >> "$__bluximity_config"; then
		echo "'$num $mac $name' written to $__bluximity_config"
	fi
}

__bluximity_list()        { cat $__bluximity_config;      }
__bluximity_listdevices() { bt-device -l | grep "(.*)";   }
__bluximity_details()     { bt-device -i `__bluximity_list | awk -v num="$@" '$1 == num {print $2}'`; }

__bluximity_add(){
	if ! test -z "$@"; then
		__bluximity_listdevices | grep -i "$@" | while read d; do
			warn "adding device $d"
			__bluximity_savemac $d
		done
	else
		devices=`__bluximity_listdevices`
		for d in $devices; do
			warn -n "add device $d? [yN]"
			read key && case $key in
				y*|Y*) warn "adding $d"; __bluximity_savemac $d;;
				*)     ;;
			esac
		done
	fi
}

__bluximity_rm(){
	if ! test -z "$@"; then
		warn "removing device number '$@'"
		sed -i "/^$@ /d" $__bluximity_config
	else
		warn "Usage: bluximity rm DEVICE_NUMBER"
	fi
	warn "current $__bluximity_config is"
	cat $__bluximity_config
}
