minetest.register_tool("core:connect", {
    desription = "Connect to 9p fs",
    inventory_image = "core_connect.png",
    wield_image = "core_connect.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            connect = 1
        }
    },

    on_use = function(_, player, _)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "core:connect",
            table.concat({"formspec_version[3]", "size[10,3,false]", "field[0.5,0.5;9,1;connection_string;",
                          "Enter address and path like 'tcp!localhost!1917 /tmp';", "tcp!localhost!1917 /]",
                          "button_exit[7,1.8;2.5,0.9;connect;connect]"}, ""))
    end
})

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:connect") then
        inventory:add_item("main", "core:connect")
    end
end)
