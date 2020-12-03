minetest.register_on_chat_message(function(player_name, message)
    local player = minetest.get_player_by_name(player_name)
    local player_graph = graphs:get_player_graph(player_name)
    local platform = player_graph:get_platform(common.get_platform_string(player))
    if not platform then 
        minetest.chat_send_player(player_name, "No platform found nearby")
        return end
    local cmdchan = platform:get_cmdchan()
    if not cmdchan then
        return
    end
    local path = platform:get_path()
    local commands = core_conf:get("pcmd")
    local command = message:match("[^ ]+")
    if commands:match(command) then
        if message:match("| minetest$") then
            message = message:gsub("| minetest", "")
            local result = cmdchan:execute(message, path)
            cmdchan:show_response(result, player_name)
        elseif message:match(" | inventory$") then
            message = message:gsub("| inventory", "")
            local result = cmdchan:execute(message)
            common.add_ns_to_inventory(player, result)
        else
            local result = cmdchan:execute(message, path)
            minetest.chat_send_all(result .. "\n")
            if result:match("^/") then
                result = result:gsub("\n", "")
                platform:spawn_path(result, player)
            end
        end
        return true
    end
end)
