#!/usr/bin/bash
#
# upward search for lib and src dirs
#
#

outdir=$PWD # set dir to start dir
updir_count=0
while true; do
	if [ -d "./lib" ] && [ -d "./src" ]; then
		outdir=$PWD
		echo $outdir
		exit 0		
		break
	fi
	
	if [ $updir_count = 100 ] || [ $PWD = $HOME ]; then
		echo $outdir
		exit 1
		break		
	fi
	
	updir_count=$(expr $updir_count + 1);
	cd ..
done;



