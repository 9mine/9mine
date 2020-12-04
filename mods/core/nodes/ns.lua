local function on_drop(itemstack, dropper, pos)
    local item_meta = itemstack:get_meta()
    local namespace = item_meta:get_string("ns")
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
    stat_entity:set_acceleration({
        x = 0,
        y = -9.81,
        z = 0
    })
    stat_entity:set_properties({
        visual = "cube",
        textures = {"core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png"},
        nametag = "NameSpace"
    })
    stat_entity:get_luaentity().ns = namespace

    minetest.after(1, NsNode.newns, stat_entity, dropper)
    return itemstack
end

NsNode = {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png", "core_ns.png"},
    inventory_image = "core_ns.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = on_drop
}

function NsNode.newns(entity, player)
    local player_name = player:get_player_name()
    local player_graph = graphs:get_player_graph(player_name)
    local platform_string = common.get_platform_string_near(entity, player)
    local platform = player_graph:get_platform(platform_string)
    local cmdchan = platform:get_cmdchan()
    local conn = platform:get_conn()
    local ns = entity:get_luaentity().ns
    local platform_path = platform:get_path()
    cmdchan:execute("touch /tmp/ns")
    np_prot.file_write(conn, "/tmp/ns", ns)
    minetest.chat_send_player(player_name, cmdchan:execute("auth/newns -n /tmp/ns ns"))
    entity:set_acceleration({
        x = 0,
        y = 9,
        z = 0
    })
    minetest.after(1.5, function(entity)
        entity:remove()
    end, entity)
end

minetest.register_node("core:ns_node", NsNode)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:ns_node") then
        local ns = ItemStack("core:ns_node")
        local ns_meta = ns:get_meta()
        ns_meta:set_string("ns", "")
        ns_meta:set_string("description", "newns")
        inventory:add_item("main", ns)
    end
end)

