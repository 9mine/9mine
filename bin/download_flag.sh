#!/bin/sh

COUNTRY=$1

test -z "$COUNTRY" && { 
	echo "use $0 country"
	exit 1 
} 

download_link1() {
	lynx -dump "https://flagpedia.net/s?q=$1&submit=Search" | grep -E 'https://flagpedia.net/[^/]+/download' | awk '{print $2}'
} 

download_link2() {
	lynx --dump $1 | grep -i '\.png' | awk '{print $2}'
} 

link1=`download_link1 "$COUNTRY"`

test -z "$link1" && {
	echo "no link1"
	exit 1
} 

png_link=`download_link2 $link1`

test -z "$png_link" && {
	echo "no png_link"
	exit 1
} 

country_name=`echo $COUNTRY | sed 's/ /_/g;s/\(.*\)/\L\1/;'`

curl -Lo "graphviz/textures/country_$country_name.png" $png_link
