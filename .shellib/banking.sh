#!/bin/bash

DEBUG=true

if which shellib > /dev/null
then debug "BANKING: using shellib utils"
else
	SL_DEBUG=$DEBUG
	source `dirname $0`/utils.sh
	debug "BANKING: sourced shellib utils directly"
fi

echo $0

usage(){
	cat 1>&2 <<-USAGE
		Usage: $0 [EXPR...] [-f FILE] [-o FILE]

		EXPR     a multi-argument list a strings that defined how to convert the input FILE

		-f FILE  define the input file
		-o FILE  define the output file

	USAGE
}


while (( $# > 0 )); do
	case "$1" in
		--help|-h)   usage; exit 1;;
		-f) shift;   SRC=$1;;
		-o) shift;   TRG=$1;;
		from) shift; FROM=$1; lastExpr="FROM";;
		to)   shift; TO=$1;   lastExpr="TO";;
		lang) shift; 
			case "$lastExpr" in
				FROM) FROM_LANG=$1;;
				TO)   TO_LANG=$1;;
				*)    warn "ignoring unexpected 'lang' expression";;
			esac ;;
		*) ;;
	esac
	shift
done

big='\.'
rest=','
dig3='[0-9][0-9][0-9]'
dig2='[0-9][0-9]'
digs='[0-9]+'
frac="$rest$dig2"
end='[^0-9]'

bignum="($digs)($big$dig3)+($frac)?($end)"

bignum_sed=`echo "$bignum" | sed 's#\([()?+*]\)#\\\\\\1#g'`

$DEBUG && cat <<-DEBUG
	FROM:       $FROM
	FROM_LANG:  $FROM_LANG
	TOM:        $TO
	TO_LANG:    $TO_LANG
	SRC:        $SRC
	TRG:        $TRG

	composable expressions:

	big:  $big
	rest: $rest
	dig3: $dig3
	dig2: $dig2
	digs: $digs
	frac: $frac
	end:  $end

	bignum:     $bignum
	bignum_sed: $bignum_sed
DEBUG

to_utf8(){ iconv -f iso-8859-1 -t utf-8 $@; }

find_bignum()    { grep -oE "$bignum"; }
replace_bignum() { sed  "s#($bignum_sed)#BIGNUM#"; }

selftest(){
	csv_de="
		100.000,00
		 10.000,00
		  1.000,00
		100.000
		 10.000
		  1.000
	"
	csv_en="
		100,000.00
		 10,000.00
		  1,000.00
		100,000
		 10,000
		  1,000
	"

	echo "$csv_de" | find_bignum
	echo "$csv_en" | find_bignum

}

# cat $SRC | to_utf8 | replace_bignum

selftest

