minetest.register_chatcommand("cd", {
    func = function(player_name, path_from_chat)
        local player = minetest.get_player_by_name(player_name)
        local platform = platforms:get_platform(common:get_platform_string(player))
        local path = platform:get_path()
        if not path_from_chat:match("^/") then
            path = path == "/" and path .. path_from_chat or path .. "/" .. path_from_chat
        end
        platform:spawn_path(path_from_chat, player)
        return true
    end
})
