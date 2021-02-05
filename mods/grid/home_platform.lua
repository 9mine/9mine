local show_home_platform_formspec = function(player, last_login)
    local player_name = player:get_player_name()
    minetest.show_formspec(player_name, "core:home_platform",
                           table.concat({"formspec_version[4]", "size[20.5,9.7,false]",
        "field[0, 0; 0, 0;last_login;;", last_login or "", "]",
        "hypertext[0.5, 0.2; 19.5, 1;;<big><center>Select Home Platform<center><big>]",
        "style[inferno,nfront;textcolor=red;font=bold;font_size=+59]",
        "image_button[0.5,1.2;9.5,8;core_infernoos.png;inferno;INFERNO OS;false;true]",
        "image_button[10.5,1.2;9.5,8;core_9front.png;nfront;9FRONT;false;true]"}, ""))
end

local home_platform_event = function(player, formname, fields)
    if formname == "core:home_platform" then
        if fields.quit then return end
        local player_name = player:get_player_name()
        automount.root_cmdchan:execute("mkdir /n/" .. player_name)
        local home_platform = fields.inferno ~= nil and "inferno" or fields.nfront ~= nil
                                  and "nfront"
        minetest.show_formspec(player:get_player_name(), "core:some_form",
                               table.concat({"formspec_version[4]", "size[20, 1.2,false]",
            "hypertext[0, 0.3; 20, 1;;",
            "<bigger><center>Executing requests. Please, wait...<center><bigger>]"}, ""))
        local user_addr = automount.root_cmdchan:execute(
            "ndb/regquery -n "
                .. ((home_platform == "inferno" and "user") or (home_platform == "nfront" and "is"))
                .. " " .. player_name):gsub("\n", "")
        if not user_addr or user_addr == "" then
            automount.root_cmdchan:write("echo -n " .. player_name .. " >> /n/9mine/"
                                             .. ((home_platform == "inferno" and "user")
                                                 or (home_platform == "nfront" and "9front")))
            minetest.show_formspec(player:get_player_name(), "core:some_form",
                                   table.concat({"formspec_version[4]", "size[20, 1.2,false]",
                "hypertext[0, 0.3; 20, 1;;", "<bigger><center>Request sent for new user create.",
                " Please, wait...<center><bigger>]"}, ""))
            minetest.after(3, automount.poll_regquery, automount, player, 0, fields.last_login,
                           home_platform)
        else
            minetest.show_formspec(player:get_player_name(), "core:some_form",
                                   table.concat({"formspec_version[4]", "size[20, 1.2,false]",
                "hypertext[0, 0.3; 20, 1;; <bigger><center>User addr is: ", user_addr,
                "<center><bigger>]"}, ""))
            automount.spawn_root_platform(automount, user_addr, player, fields.last_login, true)

        end
    end
end
register.add_onjoin_func("show_home_platform_formspec", show_home_platform_formspec)
register.add_form_handler("core:home_platform", home_platform_event)
