#!/bin/sh

fix_country_names() {
	sed 's/,*//g;s/Virgin Islands U.S./British Virgin Islands/;' 
} 

xmllint --nowarning  --html --xpath '//div[@class="container-fluid"]/div/div/a/text()' /tmp/bitnodes.io 2>/dev/null | fix_country_names 
