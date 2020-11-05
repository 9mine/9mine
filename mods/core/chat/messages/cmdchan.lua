minetest.register_on_chat_message(function(player_name, message)
    if string.match(message, "^[%a%d]+") then
        local cmd = string.match(message, "^[%a][%a%d/]+")
        local pcmd = tostring(core_conf:get("pcmd"))
        local lcmd = tostring(core_conf:get("lcmd"))
        if string.match(pcmd, cmd) then
            local addr, path, player = plt_by_name(player_name)
            local response = nil
            if message:match("| minetest$") then
                local message = message:gsub("| minetest", "")
                cmd_write(addr, path, player_name, message, lcmd)
                local response = cmd_read(addr, player_name, lcmd)
                show_output(player_name, response)
                return
            else
                cmd_write(addr, path, player_name, message, lcmd)
                response = cmd_read(addr, player_name, lcmd)
                minetest.chat_send_player(player_name, "\n" .. response .. "\n")
            end
            if response:match("^/") then
                response = response:gsub("\n", "")
                local node = graph:findnode(hex(addr .. response))
                if node and node.p then
                    if node.stat.qid.type ~= 128 then
                        local pp = table.copy(node.p)
                        pp.x = pp.x - 2
                        pp.y = pp.y + 1
                        pp.z = pp.z - 2
                        player:set_pos(pp)
                        set_look(player, node.p)
                        return
                    else
                        list_directory(addr, response, player)
                        return
                    end
                else
                    local result, call_response = pcall(stat_read, addr, response, player_name)
                    if result then
                        if call_response.qid.type == 128 then
                            list_path(addr, response, player)
                        else
                            local parent_path = get_parent_path(response)
                            local seconds = list_path(addr, parent_path, player) + 0.5
                            minetest.after(seconds, function(addr, response, player)
                                local node = graph:findnode(hex(addr .. response))
                                local pp = table.copy(node.p)
                                pp.x = pp.x - 2
                                pp.y = pp.y + 1
                                pp.z = pp.z - 2
                                player:set_pos(pp)
                                set_look(player, node.p)
                            end, addr, response, player)

                        end
                    end
                end
            end
            return true
        else
            return false
        end
    end
end)
