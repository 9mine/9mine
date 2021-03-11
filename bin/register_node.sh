(cd graphviz/textures/; find . -name "country_*" | sed 's/^\.\///;s/\.png$//' ) | awk '{printf("minetest.register_node(\"graphviz:%s\", {\n\ttiles = { \"%s.png\" }\n})\n", $1, $1)}'
