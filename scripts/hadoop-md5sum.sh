#!/usr/bin/env bash
#
# Hadoop MD5 and SHA1 Appender Script
# =================================
#
# Author: Uwe Jugel, https://github.com/ubunatic
#
# Description
# ----------- 
# This script runs a SQL query and pipes `|` the output to `python`
# to compute and append the md5 and sha1 of a data column using `hashlib`.
#
# The script appends three columns to your selected data:
# - the md5  hash of data colum no. `hashed_column`
# - the sha1 hash of data colum no. `hashed_column`
# - the resulting number of fields (columns) in each output row
# 
# Limitations
# -----------
# If your selected columns contain spaces, tabs, pipes, commas, etc.
# and you define `safe_delimiter` or `output_delimiter` to be one of those,
# you will mess up the number of columns in the output.
#
# Usage
# -----
# 1. Copy all code below and adjust the parameters.
# 2. Paste your edited code in the command line and run it,
#

( # run in a subshell to avoid funny effects

# Adjustable Parameters
# ---------------------
query="SELECT id, hash, state FROM input.abtests_json" # query to run in hadoop
safe_delimiter="|"                # safe delimiter used to separate table content
output_delimiter="|"              # delimiter used in the final output
hashed_column=1                   # number of the data column to be hashed
output_file="/dev/stdout"         # where to store or print the output

impala-shell --delimited --output_delimiter="$safe_delimiter" --query="$query" |
python -c '
import hashlib, sys; fs, ofs, col = sys.argv[1:]; col = int(col)
for line in sys.stdin:
   cols = line.replace("\n","").split(fs)
   cols.extend([
      hashlib.md5( cols[col]).hexdigest(),
      hashlib.sha1(cols[col]).hexdigest(),
      str(len(cols) + 3)
   ])
   print ofs.join(cols)
' "$safe_delimiter" "$output_delimiter" "$hashed_column" > "$output_file"

) # close the subshell

#
# Legacy Awk Version
# ------------------
#
# impala-shell --delimited --output_delimiter="$safe_delimiter" --query="$query" |
# awk -v col="$hashed_column" -v FS="$safe_delimiter" -v OFS="$output_delimiter" '
# {
#    esc  = "__HEREDOC__"int(rand()* 1e30)"__"   # make sure nothing escapes the hashed_column
#    gsub(esc, "", $col)                         # even if an attacker tries to
#    doc  = esc"\n"$col"\n"esc
#    md5  = "(md5sum  | cut -f1 -d\\ ) <<-"doc   # md5  hash it and cleanup
#    sha1 = "(sha1sum | cut -f1 -d\\ ) <<-"doc   # sha1 hash it and cleanup
#    md5  | getline md5hash;  close(md5)
#    sha1 | getline sha1hash; close(sha1)
#    $1=$1                                       # rebuild the record with new OFS
#    print $0, md5hash, sha1hash, NF + 3         # print record, hashes, and count
# }
# '
