console = function(player, formname, fields)
    if fields["quit"] then return end
    local player_name = player:get_player_name()
    local p = fields["entity_pos"]
    local pos = minetest.deserialize(p)
    local entity = get_entity(pos)
    local addr = entity:get_luaentity().addr
    local path = entity:get_luaentity().path
    local lcmd = tostring(core_conf:get("lcmd"))
    local inpt = fields["input"]:gsub("; ", "")
    cmd_write(addr, path, player_name, fields["input"], lcmd)
    local response = cmd_read(addr, player_name, lcmd)
    entity:get_luaentity().output =
        fields["input"] .. ": " .. response .. "\n" ..
            entity:get_luaentity().output
    local formspec = {
        "formspec_version[3]", "size[13,13,false]",
        "textarea[0.5,0.5;12.0,10;;;" ..
            minetest.formspec_escape(entity:get_luaentity().output) .. "]",
        "field[0.5,10.5;12,1;input;;\\; ]", "field_close_on_enter[input;false]",
        "button[10,11.6;2.5,0.9;send;send]",
        "field[13,13;0,0;entity_pos;;" .. minetest.formspec_escape(p) .. "]"
    }
    local form = table.concat(formspec, "")

    minetest.show_formspec(player_name, "core:console", form)
end
