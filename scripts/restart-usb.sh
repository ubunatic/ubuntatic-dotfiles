#!/bin/sh
# restart-usb.sh looks for usb controllers and unbinds and binds them
# at their correspondng /sys/bus/pci/drivers/*hci*/{bind,unbind} paths. 
# The program helps to reactive broken usb devices like mice that won't
# work even after unplugging and replugging them.
#
# Autor: uwe.jugel@gmail.com
#
# Usage: 1. unplug misbehaving USB device
#        2. run this script
#        3. plugin your USB device
#        4. the device should be workng again
# 

info() { echo $@ 1>&2; true;   }
warn() { echo $@ 1>&2; true;   }
fail() { echo $@ 1>&2; exit 1; }

rebind(){
	for ext in "-pci" "_pci" "-hcd" "_hcd"; do
		hci=/sys/bus/pci/drivers/$2$ext
		test -d $hci && break
	done
	if ! test -d $hci; then 
		warn "cannot find hci dir $hci"; return
	fi
	info "rebinding $1 at $hci (requires sudo access)"
	echo -n "$1" | sudo tee $hci/unbind 2> /dev/null
   echo -n "$1" | sudo tee $hci/bind
}

lspci | awk '
	/USB controller/ {
	   if ($1 ~ /[0-9]+:[0-9a-z]+\.[0-9]/) {
			dev = "0000:"$1
		}
		hci = "ehci"
		for(i=2;i<=NF;i++) {
			if ($i ~ /^.HCI$/) {
				hci = tolower($i) 
			}
		}
		print dev,hci
   }
' | while read line; do rebind $line 1> /dev/null; done

info "done"
