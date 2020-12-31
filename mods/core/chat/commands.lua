minetest.register_chatcommand("cd", {
    func = function(player_name, path_from_chat)
        local player = minetest.get_player_by_name(player_name)
        local player_graph = graphs:get_player_graph(player_name)
        local platform = player_graph:get_platform(common.get_platform_string(player))
        local path = platform:get_path()
        if not path_from_chat:match("^/") then
            path = path == "/" and path .. path_from_chat or path .. "/" .. path_from_chat
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
        return true, "\n"
    end
})