awk '/^["JOIN", "PART"]/ { if ($1 == "JOIN") { system("./mkdir.sh "$2); print $2, "has joined"; } else { system("./rmdir.sh "$2); print $2, "has left"; }} '
