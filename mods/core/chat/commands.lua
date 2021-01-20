minetest.register_chatcommand("cd", {
    func = function(player_name, path_from_chat)
        local player = minetest.get_player_by_name(player_name)
        local player_graph = graphs:get_player_graph(player_name)
        local platform = player_graph:get_platform(
                             common.get_platform_string(player))
        if not platform then return false, "No platform nearby" end
        local path = platform:get_path()
        if not path_from_chat:match("^/") then
            path = path == "/" and path .. path_from_chat or path .. "/" ..
                       path_from_chat
        else
            path = path_from_chat
        end
        platform:spawn_path(path, player)
        return true
    end
})

minetest.register_chatcommand("whereis", {
    func = function(player_name, params)
        local response = ""
        local matched = {}
        local player_graph = graphs:get_player_graph(player_name)
        local graph = player_graph:get_graph()

        for n in graph:walknodes() do
            if n.entry then
                if n.entry.stat.name:match(params) then
                    table.insert(matched, n.entry)
                end
            end
        end
        for k, v in pairs(matched) do
            minetest.chat_send_player(player_name, v:get_entry_string())
        end
        spawn_matched(player_name, matched)
        return true, "\n"
    end
})

stop = function(entity, p)
    local y = entity:get_pos().y
    if (y - p) < 3 then
        entity:set_velocity({x = 0, y = 0, z = 0})
    else
        minetest.after(0.05, stop, entity, p)
    end
end

spawn_matched = function(name, matched)
    local player = minetest.get_player_by_name(name)
    local position = player:get_pos()
    local look_dir = player:get_look_dir()
    local direction = vector.multiply(look_dir, 6)
    local destination = vector.add(vector.add(position, direction),
                                   {x = 0, y = 2, z = 0})

    local rot_dir = vector.rotate(look_dir, {x = 0, y = math.pi / 2, z = 0})

    local spawn_line = {}
    local remove_line = {}
    for i = -4, 4 do table.insert(spawn_line, vector.multiply(rot_dir, i)) end
    table.shuffle(spawn_line)

    for k, entry in pairs(matched) do
        local index, spawn_dest = next(spawn_line)
        if not spawn_dest then return end
        table.remove(spawn_line, index)
        local spawn_pos = vector.add(destination, spawn_dest)

        table.insert(remove_line, spawn_pos)
        spawn_pos.y = spawn_pos.y + 10
        local name = entry.platform_string .. "\n" .. entry.stat.name
        local entity = minetest.add_entity(spawn_pos, "core:stat")
        entity:set_properties({
            nametag = name,
            textures = {
                entry.stat.qid.type == 128 and "core_dir.png" or "core_file.png"
            }
        })
        entity:set_armor_groups({immortal = 0})
        entity:set_properties({physical = false})
        entity:set_velocity({x = 0, y = -9.81, z = 0})
        entity:get_luaentity().entry_string = entry.entry_string

        local front_of_entity =
            vector.subtract(entry.pos, {x = 0, y = 0, z = 2})

        entity:get_luaentity().on_punch =
            function(self, puncher)
                for k, v in pairs(remove_line) do
                    v.y = v.y - 10
                    local objects = minetest.get_objects_inside_radius(v, 4)
                    while next(objects) ~= nil do
                        local x, y = next(objects)
                        if y:is_player() then
                        else
                            y:remove()
                        end
                        table.remove(objects, x)
                    end
                end

                local state = puncher:set_look_vertical(0.3490)
                puncher:set_look_horizontal(0)
                puncher:set_pos(front_of_entity)
            end

        minetest.after(0.05, stop, entity, position.y)
    end

end

