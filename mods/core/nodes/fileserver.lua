minetest.register_node("core:fileserver", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_fileserver.png", "core_fileserver.png", "core_fileserver.png", "core_fileserver.png",
             "core_fileserver.png", "core_fileserver.png"},
    inventory_image = "core_fileserver.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true
})

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:fileserver") then
       local connection_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                                core_conf:get("inferno_address")
        local item = ItemStack("core:fileserver")
        local item_meta = item:get_meta()
        item_meta:set_string("connection_string", connection_string)
        -- inventory:add_item("main", item)
    end
end)
