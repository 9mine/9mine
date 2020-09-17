check_position = function(route, packet, dest_pos, route_entry, route_entries)
    local current_pos = packet:get_pos()
    x = dest_pos.x - current_pos.x
    y = dest_pos.y - current_pos.y
    z = dest_pos.z - current_pos.z
    local delta = {x = x, y = y, z = z}
    print(dump(delta))
    minetest.after(1, check_position, route, packet, dest_pos, route_entry,
                   route_entries)
end
