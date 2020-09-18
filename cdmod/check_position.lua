check_position = function(route, packet, dest_pos, route_entry)
    local current_pos = packet:get_pos()
    local x = dest_pos.x - current_pos.x
    local y = dest_pos.y - current_pos.y
    local z = dest_pos.z - current_pos.z
    if math.abs(x) < 1 and math.abs(y) < 1 and math.abs(z) < 1 then
        if route_entry == #route then
            local entity = minetest.add_entity(route[#route], "cdmod:host")
            entity:set_nametag_attributes({
                color = "black",
                text = route[route_entry].t
            })
            entity:set_armor_groups({immortal = 0})
            entity:get_luaentity().ip = route[route_entry].t
            packet:set_velocity({x = 0, y = 0, z = 0})
            packet:set_pos(dest_pos)
            return
        end
        packet:set_pos(dest_pos)
        local entity = minetest.add_entity(route[route_entry], "cdmod:host")
        entity:set_nametag_attributes({
            color = "black",
            text = route[route_entry].t
        })
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = route[route_entry].t

        local pos = dest_pos
        route_entry = route_entry + 1
        dest_pos = route[route_entry]
        move(pos, dest_pos, packet)
        minetest.after(0.1, check_position, route, packet, dest_pos, route_entry)
    else
        minetest.after(0.1, check_position, route, packet, dest_pos, route_entry)

    end

end
