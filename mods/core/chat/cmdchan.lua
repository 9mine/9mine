minetest.register_on_chat_message(function(player_name, message)
    local platform = platforms:get_platform(common:get_platform_string(minetest.get_player_by_name(player_name)))
    local cmdchan = platform:get_cmdchan()
    local path = platform:get_path()
    local commands = core_conf:get("pcmd")

    local command = message:match("[^ ]+")
    if commands:match(command) then

        if message:match("| minetest$") then
            message = message:gsub("| minetest", "")
            local result = cmdchan:execute(message, path)
            cmdchan:show_response(result, player_name)
        else
            local result = cmdchan:execute(message, path)
            minetest.chat_send_all(result .. "\n")
            if result:match("^/") then
                result = result:gsub("\n", "")               
            end
        end
        return true
    end
end)
