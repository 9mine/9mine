function beatify_long_string(str, size) {
  match(str, /^(....).*(....)$/, start_end) 
  return sprintf("%s...%s", start_end[1], start_end[2])
} 

function beatify_hash(hash) {
  return beatify_long_string(hash, 8)
} 

{
  hash = beatify_hash($1) 
  from_list = $2
  to_list = $3

  split(from_list, from, ",")

  for (i in from) {
#    if (data ~ /non-standart/) {
#      continue
#    } 
    match(from[i], /([^:]+):(.*)/, data)
    if (data[1] != "" && data[2] != "") {
      printf("%s %s %s\n", data[1], hash, data[2])
    } 
  } 

  split(to_list, to, ",")

  for (i in to) {

#    if (data ~ /non-standart/) {
#      continue
#    } 

    match(to[i], /([^:]+):(.*)/, data)
    if (data[1] != "" && data[2] != "") {
      printf("%s %s %s\n", hash, data[1], data[2])
    } 
  } 
  
} 
