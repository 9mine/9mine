local show_home_platform_formspec = function(player)
    local player_name = player:get_player_name()
    minetest.show_formspec(player_name, "core:home_platform",
        table.concat({
            "formspec_version[4]", 
            "size[10,5,false]", 
        }, ""))
end

register.add_onjoin_func("show_home_platform_formspec", show_home_platform_formspec)