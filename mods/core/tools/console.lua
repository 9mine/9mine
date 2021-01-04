minetest.register_tool("core:console", {
    desription = "Spawn Console Cube",
    inventory_image = "core_console.png",
    wield_image = "core_console.png",

    on_use = function(itemstack, player, pointed_thing)
        minetest.show_formspec(player:get_player_name(), "core:spawn_console",
            table.concat({
                "formspec_version[3]size[10,3,false]", 
                "field[0.5,0.5;9,1;addr;Remote host if form of tcp!host!port;]",
                "button_exit[7,1.8;2.5,0.9;connect;connect]"}, ""))
    end
})

local function spawn_console(player, formname, fields)
    if formname == "core:spawn_console" then
        if not fields.addr then 
            minetest.chat_send_player(player:get_player_name(), "No addr field")
            return
        end
        local attach_string = split_connection_string(fields.addr)
        local tx = "core_console.png"
        local connection = connections:get_connection(player:get_player_name(), attach_string, true)
        if not connection then
            return
        end
        if not connection.cmdchan then
            local cmdchan = cmdchan(connection, core_conf:get("cmdchan_path"))
            connection:set_cmdchan(cmdchan)
        end

        local dir = player:get_look_dir()
        local dis = vector.multiply(dir, 5)
        local pp = player:get_pos()
        local fp = vector.add(pp, dis)
        fp.y = fp.y + 2
        local entity = minetest.add_entity(fp, "core:console")
        entity:set_properties({
            nametag = attach_string,
            textures = {
                tx, tx, tx, tx, tx, tx
            }
        })
        entity:get_luaentity().addr = attach_string
    end
end

register.add_form_handler("core:spawn_console", spawn_console)

local function console(player, formname, fields)
    if formname == "core:console" then
        if not (fields.key_enter or fields.send) then
            return
        end
        local player_name = player:get_player_name()
        local pos = minetest.deserialize(fields.entity_pos)
        local index, entity = next(minetest.get_objects_inside_radius(pos, 0.5))
        local lua_entity = entity:get_luaentity()
        local response = connections:get_connection(player_name, lua_entity.addr):get_cmdchan():execute(fields.input:gsub("; ", ""))
        lua_entity.output = fields.input .. ": " .. response .. "\n" .. lua_entity.output
        minetest.show_formspec(player_name, "core:console", table.concat({
            "formspec_version[4]", 
            "size[13,13,false]",
            "textarea[0.5,0.5;12.0,10;;;", minetest.formspec_escape(lua_entity.output), "]", 
            "field[0.5,10.5;12,1;input;;\\; ]", 
            "field_close_on_enter[input;false]",
            "button[10,11.6;2.5,0.9;send;send]",
            "field[13,13;0,0;entity_pos;;", minetest.formspec_escape(fields.entity_pos), "]"
        }, ""))
    end
end

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:console") then
        inventory:add_item("main", "core:console")
    end
end)

register.add_form_handler("core:console", console)
