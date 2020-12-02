minetest.register_chatcommand("graph", {
    func = function(player_name, params)
        local player_graph = graphs:get_player_graph(player_name)
        local graph = player_graph:get_node()
        minetest.chat_send_player(player_name, "Layout . . . \n")
        graph:layout("circo")
        minetest.chat_send_player(player_name, "Render . . . \n")
        local pfx = minetest.get_modpath("core")
        local name = os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
        local full_name = pfx .. "/rendered_graphs/" .. name

        graph:render("png", full_name)
        minetest.dynamic_add_media(full_name)
        minetest.chat_send_player(player_name, "Graph rendered to " .. name .. "\n")

        if params == "show" then
            minetest.show_formspec(player_name, "core:graph", table.concat(
                {"formspec_version[3]", "size[30, 20,false]", "image_button[0.5,0.5;29,19;" .. name .. ";;]"}, ""))
        end
    end
})

