local write = function(player, fields)
    local player_name = player:get_player_name()
    local file_path = fields["file_path"]
    local content = fields["content"]

    if not file_path or not content then
        return
    end
    local player_graph = graphs:get_player_graph(player_name)
    local attachment = player_graph:get_platform(common.get_platform_string(player)):get_attachment()
    local result, response = pcall(np_prot.file_write, attachment, file_path, content)
    if result then
        minetest.chat_send_player(player_name, "File successfully saved")
    else
        minetest.chat_send_player(player_name, "Editing file failed: " .. response)
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "stat:write" or "stat:edit" then
        write(player, fields)
    end
end)
