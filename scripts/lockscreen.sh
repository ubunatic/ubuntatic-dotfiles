#!/bin/bash

case $1 in
	lock)   action=lock-session;;
	unlock) action=unlock-session;;
	*) echo "Usage: $0 [lock|unlock]"; exit 1;;
esac

session=`loginctl show-user $SUDO_USER | sed -n '/Display/ s/Display=//p'`
loginctl $action $session
