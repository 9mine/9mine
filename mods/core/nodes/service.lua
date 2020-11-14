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
}


minetest.register_node("core:service_node", ServiceNode)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:service_node") then
        inventory:add_item("main", "core:service_node")
    end
end)
