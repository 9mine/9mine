RegistryTool = {
    desription = "Show registry",
    inventory_image = "core_registry.png",
    wield_image = "core_registry.png"
}

function RegistryTool.on_use(itemstack, player)
    draw_welcome_screen(player)
end

minetest.register_tool("core:registry", RegistryTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:registry") then
        inventory:add_item("main", "core:registry")
    end
end)