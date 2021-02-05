RegistryTool = {
    desription = "Show registry",
    inventory_image = "core_registry.png",
    wield_image = "core_registry.png"
}

function RegistryTool.on_use(_, player)
    local connection = connections:get_connection(player:get_player_name(),
                                                  common.get_env(core_conf, "GRIDFILES_ADDR"), true)
    if connection then
        local lua = np_prot.file_read(connection.conn, '/9mine/welcomefs/registry.lua')
        if lua then loadstring(lua)() end
    end
end

minetest.register_tool("core:registry", RegistryTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:registry") then
        inventory:add_item("main", "core:registry")
    end
end)
