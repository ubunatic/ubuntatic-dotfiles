# Step 2: depending on the shell use the script name to determine
# the scripts dir and source another relative script from there
if test -n "$BASH_SOURCE"; then
	echo "test1 (bash), source: $BASH_SOURCE"
	dir=`dirname "$BASH_SOURCE"`
	source "$dir/subdir/test2.sh"
else
	echo "test1 (non-bash), source: $0"
	dir=`dirname $0`
	source "$dir/subdir/test2.sh"
fi
