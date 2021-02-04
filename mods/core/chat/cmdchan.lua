minetest.register_on_chat_message(function(player_name, message)
    local player = minetest.get_player_by_name(player_name)
    local player_graph = graphs:get_player_graph(player_name)
    local platform = player_graph:get_platform(common.get_platform_string(player))
    print("before")
    print(dump(platform:get_cmdchan()))
    local response = register.call_message_handlers(player_name, message)
    print("after")
    if response then return true end
    if not platform then return false end
    local commands = core_conf:get("pcmd")
    local command = message:match("[^ ]+")
    if command:match("man") and message:match(" | man$") then
        message = message:gsub(" | man", "")
        local conn = platform:get_conn()
        local section = message:match("man %d+ ") and message:match("man %d+ "):match("%d+")
        message = message:gsub("man ", ""):gsub("%d+ ", "")
        local mans_path = core_conf:get("mans_path")
        local result, manpage
        if not section then
            for s = 1, 10 do
                result, manpage = pcall(np_prot.file_read, conn,
                                        mans_path .. "/" .. s .. "/" .. message)
                if result then break end
            end
            if not result then
                minetest.chat_send_player(player_name,
                                          "Error reading accross all sections: " .. manpage)
                return true
            end
        else
            result, manpage = pcall(np_prot.file_read, conn,
                                    mans_path .. "/" .. section .. "/" .. message)
        end
        if not result then
            minetest.chat_send_player(player_name, "Error reading manual: " .. manpage)
            return true
        end
        common.show_man(player_name, manpage)
        return true

    end
    local cmdchan = platform:get_cmdchan()
    if not cmdchan then return end
    local path = platform:get_path()
    if commands:match(command) then
        if message:match("| minetest$") then
            message = message:gsub("| minetest", "")
            local result = cmdchan:execute(message, path)
            cmdchan.show_response(result, player_name)
        elseif message:match(" | inventory$") then
            message = message:gsub("| inventory", "")
            local result = cmdchan:execute(message)
            common.add_ns_to_inventory(player, result)
        else
            local result = cmdchan:execute(message, path)
            minetest.chat_send_player(player_name, result .. "\n")
            if result:match("^/") then
                result = result:gsub("\n", "")
                platform:spawn_path(result, player)
            end
        end
        return true
    end
end)

local man_event = function(player, formname, fields)
    if formname == "core:man" then
        if fields.quit then return end
        local player_name = player:get_player_name()
        local player_graph = graphs:get_player_graph(player_name)
        local platform = player_graph:get_platform(common.get_platform_string(player))
        if not platform then
            minetest.chat_send_player(player_name, "No platform found nearby")
            return true
        end
        local v = select(2, next(fields))
        v = v:gsub("action:", "")
        local c = v:match("%(%d+%)")
        local section = c:match("%d+")
        local man = v:gsub("%(%d+%)", "")
        local conn = platform:get_conn()
        local result, manpage = pcall(np_prot.file_read, conn,
                                      core_conf:get("mans_path") .. "/" .. section .. "/" .. man)
        if not result then
            minetest.chat_send_player(player_name, "Error reading manpage: " .. manpage)
        else
            common.show_man(player_name, manpage)
        end
    end
end

register.add_form_handler("core:man", man_event)
