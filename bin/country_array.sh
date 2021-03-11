(cd graphviz/textures/; find . -name "country_*" | sed 's/^\.\///;s/\.png$//' ) | awk 'BEGIN {printf("countries = {")} {printf("\"%s\",", $1)} END {printf("}\n")}' | sed 's/,}/}/'

