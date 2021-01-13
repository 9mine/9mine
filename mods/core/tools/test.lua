minetest.register_tool(
    "core:test",
    {
        desription = "Test tool for Development",
        inventory_image = "core_test.png",
        wield_image = "core_test.png",
        tool_capabilities = {
            punch_attack_uses = 0,
            damage_groups = {
                test = 1
            }
        },
        on_use = function(_, player, _)
            local player_name = player:get_player_name()
            local player_graph = graphs:get_player_graph(player_name)
            local conn = player_graph:get_platform(common.get_platform_string(player)):get_conn()
            local response, content = pcall(np_prot.file_read, conn, "/9minegrid/search")
            if not response then
                minetest.chat_send_player(player:get_player_name(), content)
                return
            else
                minetest.show_formspec(
                    player:get_player_name(),
                    "core:test",
                    table.concat(
                        {
                            "formspec_version[3]",
                            "size[13,13,false]",
                            "textarea[0.5,0.5;12.0,12.0;;;",
                            minetest.formspec_escape(content),
                            "]"
                        },
                        ""
                    )
                )
                return
            end
        end
    }
)

minetest.register_on_joinplayer(
    function(player)
        local inventory = player:get_inventory()
        if not inventory:contains_item("main", "core:test") then
            inventory:add_item("main", "core:test")
        end
    end
)
