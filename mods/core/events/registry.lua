local global_registry = function(player, formname, fields)
    if not fields.server_list then return end 
    local event = core.explode_table_event(fields["9p_server"])
    local server_list = minetest.deserialize(fields.server_list)
    minetest.chat_send_player(player:get_player_name(), server_list[event.row])
    return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:global_registry" then
        global_registry(player, formname, fields)
    end
end)
