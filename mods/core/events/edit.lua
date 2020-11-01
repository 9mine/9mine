edit = function(player, fields)
    local player_name = player:get_player_name()
    local addr = fields["addr"]
    local file_path = fields["file_path"]
    local content = fields["content"]
    if not addr or not file_path or not content then return end
    local result, response  = pcall(file_write, addr, file_path, player_name, content)
    if result then 
        minetest.chat_send_player(player_name, "File successfully saved")
    else 
        send_warning(player_name, "Editing file failed: " .. response)
    end
end

