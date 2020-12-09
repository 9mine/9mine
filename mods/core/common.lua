class 'common'
function common.set_look(player, destination)
    local d = vector.direction(player:get_pos(), destination)
    player:set_look_vertical(-math.atan2(d.y, math.sqrt(d.x * d.x + d.z * d.z)))
    player:set_look_horizontal(-math.atan2(d.x, d.z))
end

function common.goto_platform(player, pos)
    if not pos then
        return
    end
    local destination = table.copy(pos)
    pos.x = pos.x - 2
    pos.y = pos.y + 1
    pos.z = pos.z - 2
    player:set_pos(pos)
    common.set_look(player, destination)
end

function common.get_platform_string(player)
    local player_pos = player:get_pos()
    if not player_pos then
        return nil, "Error"
    end
    local node_pos = minetest.find_node_near(player:get_pos(), 6, {"core:platform"})
    if not node_pos then
        return
    end
    local area = area_store:get_areas_for_pos(node_pos, false, true)
    local index, value = next(area)
    if not value then
        minetest.chat_send_player(player:get_player_name(), "No platform for this position in AreaStore")
        return
    end
    return value.data
end

function common.qid_as_key(dir)
    if not dir or type(dir) == "string" then
        return
    end
    local new_dir = {}
    for _, stat in pairs(dir) do
        new_dir[stat.qid.path_hex] = stat
    end
    return new_dir
end

function common.name_as_key(dir)
    local new_dir = {}
    for _, stat in pairs(dir) do
        new_dir[stat.name] = stat
    end
    return new_dir
end

function common.path_to_table(path)
    local i = 1
    local paths = {}
    if path:match("^/") then
        table.insert(paths, 1, "/")
    end
    while true do
        i = path:find("/", i + 1)
        if not i then
            table.insert(paths, 1, path)
            break
        end
        table.insert(paths, 1, path:sub(1, i - 1))
    end
    return paths
end

function common.send_warning(player_name, warning)
    minetest.chat_send_player(player_name, warning)
    minetest.show_formspec(player_name, "core:warning",
        table.concat({"formspec_version[3]", "size[10,2,false]",
                      "label[0.5,0.5;" .. minetest.formspec_escape(warning) .. "]",
                      "button_exit[7,1.0;2.5,0.7;close;close]"}, ""))
end

function common.flight(entity, directory_entry)
    local to = directory_entry:get_pos()
    local from = entity:get_pos()
    local dir = vector.direction(from, to)
    local fast_dir = vector.multiply(dir, 20)
    fast_dir.y = fast_dir.y + 9
    entity:set_acceleration({
        x = 0,
        y = -9,
        z = 0
    })
    entity:set_velocity(fast_dir)
    minetest.after(0.5, common.flight_correction, entity, to, directory_entry)
end

-- correct flying path during mv/cp commands
function common.flight_correction(entity, to, directory_entry)
    entity:set_properties({
        nametag = directory_entry.stat.name
    })
    local current_pos = entity:get_pos()
    local distance = vector.distance(current_pos, to)
    if distance < 3 then
        entity:set_velocity(vector.new())
        local final_dst = {
            x = to.x,
            y = to.y + 2,
            z = to.z
        }
        entity:set_pos(final_dst)
        directory_entry:filter(entity)
        return
    end
    local dir = vector.direction(current_pos, to)
    local speed = distance > 5 and 20 or 8
    local fast_dir = vector.multiply(dir, speed)
    fast_dir.y = fast_dir.y + 9
    entity:set_acceleration({
        x = 0,
        y = -9,
        z = 0
    })
    entity:set_velocity(fast_dir)
    minetest.after(0.3, common.flight_correction, entity, to, directory_entry)
end

function common.hex(value)
    return md5.sumhexa(value):sub(1, 16)
end

function common.table_length(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

function common.show_info(player_name, info)
    -- minetest.chat_send_player(player_name, warning)
    minetest.show_formspec(player_name, "core:info",
        table.concat({"formspec_version[3]", "size[10,2,false]",
                      "label[0.5,0.5;" .. minetest.formspec_escape(info) .. "]",
                      "button_exit[7,1.0;2.5,0.7;close;close]"}, ""))
end

function common.show_wait_notification(player_name, info)
    -- minetest.chat_send_player(player_name, warning)
    minetest.show_formspec(player_name, "core:info",
        table.concat({"formspec_version[4]", "size[10,3,false]", "hypertext[0.5,0.5;9,2;;<big><center>Hello ",
                      player_name, "\n", minetest.formspec_escape(info), "<center><big>]"}))
end

-- finds core:platform nearby (in radius of 1) and reads it's platform_string from metadata
function common.get_platform_string_near(entity, player)
    local node_pos = minetest.find_node_near(entity:get_pos(), 1, {"core:platform"})
    if not node_pos then
        minetest.chat_send_player(player:get_player_name(), "No platform found")
        return
    end
    local meta = minetest.get_meta(node_pos)
    return meta:get_string("platform_string")
end

function common.add_ns_to_inventory(player, result)
    local inventory = player:get_inventory()
    local ns = ItemStack("core:ns_node")
    local ns_meta = ns:get_meta()
    ns_meta:set_string("ns", result)
    ns_meta:set_string("description", result)
    inventory:add_item("main", ns)
end

-- Shows absolute path of the platform nearby 
-- in right lower corner 
function common.update_path_hud(player, id, addr_id, bg_id)
    local platform_string, error = common.get_platform_string(player)
    if error then
        return
    end
    local player_graph = graphs:get_player_graph(player:get_player_name())
    local platform = player_graph:get_platform(platform_string)
    local root_node = player_graph:get_root_node()
    if not platform_string then
        if id then
            player:hud_remove(bg_id)
            player:hud_remove(id)
            player:hud_remove(addr_id)
            id = nil
        end
    else
        if id then
            player:hud_change(bg_id, "number", (#platform.addr) > (#platform.path) and (#platform.addr) or (#platform.path))
            player:hud_change(addr_id, "text", platform.addr)
            player:hud_change(addr_id, "offset", {
                x = -(#platform.addr * 10),
                y = 20
            })
            player:hud_change(id, "text", platform.path)
            player:hud_change(id, "offset", {
                x = -(#platform.path * 10) - 5,
                y = 60
            })
        else
            id = player:hud_add({
                hud_elem_type = "text",
                position = {
                    x = 1,
                    y = 0
                },
                offset = {
                    x = -(#platform.path * 10) - 5,
                    y = 60
                },
                text = platform.path,
                number = 0x00FF00,
                size = {
                    x = 2
                },
                scale = {
                    x = 100,
                    y = 100
                }
            })

            addr_id = player:hud_add({
                hud_elem_type = "text",
                position = {
                    x = 1,
                    y = 0
                },
                offset = {
                    x = -(#platform.addr * 10),
                    y = 20
                },
                text = platform.addr,
                number = 0x00FF00,
                size = {
                    x = 2
                },
                scale = {
                    x = 100,
                    y = 100
                }
            })

            bg_id = player:hud_add({
                hud_elem_type = "statbar",
                z_index = -400,
                direction = 1, 
                number = (#platform.addr) > (#platform.path) and (#platform.addr) or (#platform.path),
                position = {
                    x = 1,
                    y = 0
                },
                size = {
                    x = 45, 
                    y = 85
                },
                text = "core_hud_bg.png"
            })
        end
    end
    minetest.after(1, common.update_path_hud, player, id, addr_id, bg_id)
end
