local function on_drop(itemstack, dropper, pos)
    local item_meta = itemstack:get_meta()
    local name = item_meta:get_string("service")
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
        textures = {"core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png",
                    "core_kubernetes.png", "core_kubernetes.png"},
        nametag = name
    })
    stat_entity:get_luaentity().service = name
    minetest.after(2, Kubernetes.mount, stat_entity, dropper)
    return itemstack
end

Kubernetes = {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png",
             "core_kubernetes.png", "core_kubernetes.png"},
    inventory_image = "core_kubernetes.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = on_drop
}

function Kubernetes.mount(entity, player)
    local platform_string = common.get_platform_string_near(entity, player)
    if not platform_string then
        local item = ItemStack("core:kubernetes")
        local kubernetes = item:get_meta()
        kubernetes:set_string("service", entity:get_luaentity().service)
        kubernetes:set_string("description", entity:get_luaentity().service)
        local inventory = player.get_inventory(player)
        inventory:add_item("main", item)
        entity:remove()
        return
    end
    minetest.chat_send_all(platform_string)

    local cmdchan = platforms:get_cmdchan(platform_string)
    local platform = platforms:get_platform(platform_string)
    local platform_path = platform:get_path()

    platform:set_external_handler_flag(true)
    minetest.chat_send_all(cmdchan:execute("mount -A " .. entity:get_luaentity().service .. " " .. platform_path, "/"))
    entity:set_acceleration({
        x = 0,
        y = 9,
        z = 0
    })
    minetest.after(1.5, function(entity)
        entity:remove()
    end, entity)
    platform:set_external_handler_flag(false)
end

minetest.register_node("core:kubernetes", Kubernetes)
