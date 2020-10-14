minetest.register_tool("youtube:youtube_connect", {
    desription = "Connect to YouTube",
    inventory_image = "youtube_connect.png",
    wield_image = "youtube_connect.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {attach = 1}},

    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()

        local formspec = {
            "formspec_version[3]", "size[10,3,false]",
            "field[0.5,0.5;9,1;remote_address;Enter address and path like 'tcp!localhost!1917 /tmp';tcp!localhost!1000 /youtube]",
            "button_exit[7,1.8;2.5,0.9;spawn_attach;connect]"
        }
        local form = table.concat(formspec, "")
        minetest.show_formspec(player_name, "youtube:youtube_connect", form)
    end
})

