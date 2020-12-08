local write = function(player, fields)
    local player_name = player:get_player_name()
    local file_path = fields["file_path"]
    local content = fields["content"]

    if not file_path or not content then
        return
    end
    local player_graph = graphs:get_player_graph(player_name)
    local conn = player_graph:get_platform(common.get_platform_string(player)):get_conn()
    local result, response = pcall(np_prot.file_write, conn, file_path, content)
    if result then
        minetest.chat_send_player(player_name, "File successfully saved")
    else
        minetest.chat_send_player(player_name, "Editing file failed: " .. response)
    end
end

local write_rc = function(player, fields)
    local player_name = player:get_player_name()
    local file_path = fields["file_path"]
    local content = fields["content"]

    if not file_path or not content then
        return
    end
    local player_graph = graphs:get_player_graph(player_name)
    local platform = player_graph:get_platform(common.get_platform_string(player))
    local conn = platform:get_conn()
    local cmdchan = platform:get_cmdchan()
    local result, response = pcall(np_prot.file_write, conn, file_path, content)
    if result then
        minetest.chat_send_player(player_name, "File successfully saved")
    else
        minetest.chat_send_player(player_name, "Editing file failed: " .. response)
    end
    local execute_result = cmdchan:execute("rc " .. file_path)
    minetest.show_formspec(player:get_player_name(), "core:file_content",
        table.concat({"formspec_version[3]", "size[13,13,false]", "textarea[0.5,0.5;12.0,12.0;;;",
                      minetest.formspec_escape(execute_result), "]"}, ""))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "stat:write" or formname == "stat:edit" then
        write(player, fields)
    end
    if formname == "stat:write_rc" or formname == "stat:edit_rc" then
        write_rc(player, fields)
    end
end)
