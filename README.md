# Minetest-Inferno user observer

1. Run `docker-compose up`. Minetest game will be listening on port `:30000/udp` and Inferno fileserver on port `:31000`
2. Join game with Minetest client.
3. Create text file which will be used to track users, for example `data`.
3. `cd client`
4. tail the file with awk `tail -f data | ./remote_users.awk`
- `echo "JOIN <username>" >> data` for adding user.
- `echo "PART <username>" >> data` for deleting user.

To specify custom inferno connection settings, mount `config.lua`  on path `/root/.minetest/mods/9mine_npc/config.lua`