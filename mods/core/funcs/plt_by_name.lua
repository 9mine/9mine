-- get addr, path of the platform and reference 
-- to the player from player name 
plt_by_name = function(player_name)
    local player = minetest.get_player_by_name(player_name)
    local node_pos = minetest.find_node_near(player:get_pos(), 6, {"control9p:plt"})
    local meta = minetest.get_meta(node_pos)
    local addr = meta:get_string("addr")
    local path = meta:get_string("path")
    return addr, path, player
end