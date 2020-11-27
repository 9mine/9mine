local function on_drop(itemstack, dropper, pos)
    local item_meta = itemstack:get_meta()
    local name = item_meta:get_string("ns")
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
    stat_entity:get_luaentity().service = name
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
    local platform_string = common.get_platform_string_near(entity, player)
    local cmdchan = platforms:get_cmdchan(platform_string)
    local platform = platforms:get_platform(platform_string)
    local platform_path = platform:get_path()
    minetest.chat_send_all(cmdchan:execute("echo fork\nmount -A tcp!45.63.75.148!9564 /n/client > /tmp/ns"))
    minetest.chat_send_all(cmdchan:execute("auth/newns -n /tmp/ns ns"))
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
