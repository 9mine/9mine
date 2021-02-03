minetest.register_tool("core:console", {
    desription = "Spawn Console Cube",
    inventory_image = "core_console.png",
    wield_image = "core_console.png",

    on_use = function(_, player, _)
        minetest.show_formspec(player:get_player_name(), "core:spawn_console",
                               table.concat({"formspec_version[3]size[10,3,false]",
            "field[0.5,0.5;9,1;addr;Remote host if form of tcp!host!port;]",
            "button_exit[7,1.8;2.5,0.9;connect;connect]"}, ""))
    end
})

local function spawn_console(player, formname, fields)
    if formname == "core:spawn_console" then
        local player_name = player:get_player_name()
        if not fields.addr then
            minetest.chat_send_player(player_name, "No addr field")
            return
        end
        local attach_string = split_connection_string(fields.addr)
        local tx = "core_console.png"
        local connection = connections:get_connection(player_name, attach_string, true)
        if not connection then return end
        local dis = vector.multiply(player:get_look_dir(), 5)
        local fp = vector.add(player:get_pos(), dis)
        fp.y = fp.y + 2
        local entity = minetest.add_entity(fp, "core:console")
        entity:set_properties({nametag = attach_string, textures = {tx, tx, tx, tx, tx, tx}})
        entity:get_luaentity().addr = attach_string

        local response, include_string = pcall(np_prot.file_read, connection.conn, "/.console.lua")
        if response then
            local lua_console_code, error = loadstring(include_string)
            if lua_console_code then
                minetest.chat_send_player(player_name, "Loaded /.console.lua")
            else
                print("error loading /.console.lua: " .. error)
            end
            setfenv(lua_console_code,
                    setmetatable({connection = connection, entity = entity}, {__index = _G}))
            lua_console_code()
        else
            local user
            if not connection.cmdchan then
                local cmdchan = cmdchan(connection, core_conf:get("cmdchan_path"))
                connection:set_cmdchan(cmdchan)
                user = cmdchan:execute("cat /dev/user")
                entity:get_luaentity().user = user
            end
        end
    end
end
register.add_form_handler("core:spawn_console", spawn_console)

local function console(player, formname, fields)
    if formname == "core:console" then
        if not (fields.key_enter or fields.send) then return end
        local player_name = player:get_player_name()
        local pos = minetest.deserialize(fields.entity_pos)
        local lua_entity =
            select(2, next(minetest.get_objects_inside_radius(pos, 0.5))):get_luaentity()
        local request = lua_entity.user == "glenda" and "%" or "\\;"
        local response = connections:get_connection(player_name, lua_entity.addr):get_cmdchan()
            :execute(fields.input:gsub(lua_entity.user == "glenda" and "%% " or "; ", ""))
        lua_entity.output = fields.input .. ": " .. response .. "\n" .. lua_entity.output
        minetest.show_formspec(player_name, "core:console",
                               table.concat({"formspec_version[4]", "size[13,13,false]",
            "textarea[0.5,0.5;12.0,10;;;", minetest.formspec_escape(lua_entity.output), "]",
            "field[0.5,10.5;12,1;input;;" .. request .. " ]", "field_close_on_enter[input;false]",
            "button[10,11.6;2.5,0.9;send;send]", "field[13,13;0,0;entity_pos;;",
            minetest.formspec_escape(fields.entity_pos), "]"}, ""))
    end
end
register.add_form_handler("core:console", console)
minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:console") then
        inventory:add_item("main", "core:console")
    end
end)

