CopyTool = {
    desription = "Copy file",
    inventory_image = "core_copy.png",
    wield_image = "core_copy.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            copy = 1
        }
    }
}

function CopyTool.on_drop(stat_entity, name, player_name, command)
    -- if no platform node found nearby, delete dropped entity
    local node_pos = minetest.find_node_near(stat_entity:get_pos(), 1, {"core:platform"})
    if not node_pos then
        minetest.chat_send_player(player_name, "No platform found")
        stat_entity:remove()
        return
    end

    local entry_string = stat_entity:get_luaentity().entry_string
    local meta = minetest.get_meta(node_pos)
    local platform_string = meta:get_string("platform_string")
    local platform = platforms:get_platform(platform_string)
    local directory_entry = platforms:get_entry(entry_string)
    directory_entry = directory_entry:copy()

    -- check if place, where entity was dropped, is free slot
    local spawned = false
    local slot = {}
    for index, pos in pairs(platform.slots) do
        if pos.x == node_pos.x and pos.z == node_pos.z then
            minetest.chat_send_player(player_name, "Free slot found: " .. dump(pos))
            spawned = true
            table.remove(platform.slots, index)
            slot = pos
            local spawn_pos = table.copy(pos)
            spawn_pos.y = spawn_pos.y + 1
            stat_entity:set_pos(spawn_pos)
            break
        end
    end

    -- if not free slot then remove entity
    if not spawned then
        minetest.chat_send_player(player_name, "No free slots found")
        entity:remove()
        return
    end

    -- execute copy command 
    local cmdchan = platform:get_cmdchan()
    platform:set_external_handler_flag(true)
    minetest.chat_send_all(cmdchan:execute(command .. " " .. directory_entry.path .. " " .. platform.path))
    local new_path = platform.path == "/" and platform.path .. directory_entry.stat.name or platform.path .. "/" ..
                         directory_entry.stat.name
    if platforms:get_entry(platform.addr .. new_path) then
        minetest.chat_send_all("Already exist. Replacing")
        platform:remove_entity(platforms:get_entry(platform.addr .. new_path):get_qid())
    end
    -- read stat of copied entry
    local result, stat = pcall(np_prot.stat_read, platform:get_attachment(), new_path)
    directory_entry:set_pos(slot):set_stat(stat)

    -- configure and set source entry to the destination platform
    platform:inject_entry(directory_entry)
    directory_entry:filter(stat_entity)
    -- update graph
    platforms:add_directory_entry(platform, directory_entry)
    platform:set_external_handler_flag(false)
end

function CopyTool.node_on_drop(itemstack, dropper, pos)
    local item_meta = itemstack:get_meta()
    local name = item_meta:get_string("name")
    local texture = item_meta:get_string("texture")
    local entry_string = item_meta:get_string("entry_string")
    itemstack:take_item(1)
    local pos = dropper:get_pos()
    local p = table.copy(pos)
    local dir = dropper:get_look_dir()
    dir.x = dir.x * 2.9
    dir.y = dir.y * 2.9 + 2
    dir.z = dir.z * 2.9
    p.x = p.x + dir.x
    p.y = p.y + dir.y
    p.z = p.z + dir.z
    local stat_entity = minetest.add_entity(p, "core:stat")
    stat_entity:get_luaentity().texture = texture
    stat_entity:get_luaentity().entry_string = entry_string
    stat_entity:set_properties({
        textures = {texture},
        nametag = name,
        nametag_color = "black"
    })
    stat_entity:set_acceleration({
        x = 0,
        y = -9.81,
        z = 0
    })
    minetest.after(2, CopyTool.on_drop, stat_entity, name, dropper:get_player_name(), "cp -r")
    return itemstack
end

function CopyTool.copy(entity, player)
    local directory_entry = platforms:get_entry(entity.entry_string)
    local type = directory_entry.stat.qid.type == 128 and "core:dir_node" or "core:file_node"
    local item = ItemStack(type)
    local item_meta = item:get_meta()
    item_meta:set_string("name", entity.object:get_nametag_attributes().text)
    item_meta:set_string("texture", entity.texture)
    item_meta:set_string("path", directory_entry.path)
    item_meta:set_string("entry_string", entity.entry_string)
    item_meta:set_string("description", entity.entry_string)
    player:get_inventory():add_item("main", item)
end

minetest.register_tool("core:copy", CopyTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:copy") then
        inventory:add_item("main", "core:copy")
    end
end)
