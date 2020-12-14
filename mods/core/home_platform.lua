local show_home_platform_formspec = function(player)
    local player_name = player:get_player_name()
    minetest.show_formspec(player_name, "core:home_platform",
        table.concat({
            "formspec_version[4]", 
            "size[20.5,9.7,false]", 
            "hypertext[0.5, 0.2; 19.5, 1;;<big><center>Select Home Platform<center><big>]",
            "style[inferno,nfront;textcolor=red;font=bold;font_size=+59]",
            "image_button[0.5, 1.2; 9.5, 8;core_infernoos.png;inferno;INFERNO OS;false;true]",
            "image_button[10.5, 1.2; 9.5, 8;core_9front.png;nfront;9FRONT;false;true]"
        }, ""))
end

local home_platform_event = function(player, formname, fields)
    if formname == "core:home_platform" then
        if fields.quit then return end 
        local home_platform = fields.inferno ~= nil and "INFERNO" or "9FRONT"
            minetest.show_formspec(player:get_player_name(), "core:some_form", table.concat({
                "formspec_version[4]", 
                "size[10, 0.9,false]", 
                "hypertext[0, 0.2; 10, 0.5;;<big><center>You selected ", home_platform, "<center><big>]",
            }, ""))
    end
end
register.add_onjoin_func("show_home_platform_formspec", show_home_platform_formspec)
register.add_form_handler("core:home_platform", home_platform_event)
