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
        textures = {"core_service.png", "core_service.png", "core_service.png", "core_service.png", "core_service.png",
                    "core_service.png"},
        nametag = name
    })
    stat_entity:get_luaentity().service = name
    minetest.after(2, ServiceNode.mount, stat_entity, dropper)
    return itemstack
end

ServiceNode = {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_service.png", "core_service.png", "core_service.png", "core_service.png", "core_service.png",
             "core_service.png"},
    inventory_image = "core_service.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = on_drop
}

function ServiceNode.mount(entity, player)
    local platform_string = common.get_platform_string_near(entity, player)
    if not platform_string then
        local item = ItemStack("core:service_node")
        local service = item:get_meta()
        service:set_string("service", entity:get_luaentity().service)
        service:set_string("description", entity:get_luaentity().service)
        local inventory = player:get_inventory()
        inventory:add_item("main", item)
        entity:remove()
        return
    end
    local player_name = player:get_player_name()
    minetest.chat_send_player(player_name, platform_string)
    local player_graph = graphs:get_player_graph(player_name)
    local platform = player_graph:get_platform(platform_string)
    local cmdchan = platform:get_cmdchan()
    local platform_path = platform:get_path()

    platform:set_external_handler_flag(true)
    minetest.chat_send_player(player_name, cmdchan:execute("mount -c -A " .. entity:get_luaentity().service .. " " .. platform_path, "/"))
    entity:set_acceleration({
        x = 0,
        y = 9,
        z = 0
    })
    minetest.after(1.5, function()
        local item = ItemStack("core:service_node")
        local service = item:get_meta()
        service:set_string("service", entity:get_luaentity().service)
        service:set_string("path", platform_path)
        service:set_string("description", entity:get_luaentity().service .. platform_path)
        local inventory = player:get_inventory()
        inventory:add_item("main", item)
        entity:remove()

    end)
    minetest.after(3, function()
        platform.mount_point = platform_path
        platform:set_external_handler_flag(false)
    end)

end

minetest.register_node("core:service_node", ServiceNode)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:service_node") then
        local item = ItemStack("core:service_node")
        local service = item:get_meta()

        service:set_string("service", "tcp!localhost!2100")
        service:set_string("description", "tcp!localhost!2100")

        inventory:add_item("main", item)
    end
end)

