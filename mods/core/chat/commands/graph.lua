minetest.register_chatcommand("graph", {
    func = function(player_name, params)
        local graph = graphs[player_name]
        graph:layout("circo")
        minetest.chat_send_player(player_name, "\nLayout . . . \n")
        graph:layout("circo")
        minetest.chat_send_player(player_name, "\nRender . . . \n")
        local time = os.date("*t")
        local time_str = table.concat({
            time.year, "-", time.month, "-", time.day, "-", " ", time.hour, ":",
            time.min, ":", time.sec
        }, "")

        local pfx = minetest.get_modpath("core")
        local name = os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
        local full_name = pfx .. "/rendered_graphs/" .. name

        graph:render("png", full_name)
        minetest.dynamic_add_media(full_name)
        minetest.chat_send_player(player_name,
                                  "\nGraph rendered to " .. name .. "\n")

        if params == "show" then
            minetest.show_formspec(player_name, "youtube:warning",
                                   table.concat(
                                       {
                    "formspec_version[3]", "size[30, 20,false]",
                    "image_button[0.5,0.5;29,19;" .. name .. ";;]"
                }, ""))
        end
    end
})

