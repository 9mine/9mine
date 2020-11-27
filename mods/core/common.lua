class 'common'
function common.set_look(player, destination)
    local d = vector.direction(player:get_pos(), destination)
    player:set_look_vertical(-math.atan2(d.y, math.sqrt(d.x * d.x + d.z * d.z)))
    player:set_look_horizontal(-math.atan2(d.x, d.z))
end

function common.goto_platform(player, pos)
    if not pos then
        minetest.chat_send_player(player:get_player_name(), "No position provided for goto_platform")
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
    local node_pos = minetest.find_node_near(player:get_pos(), 6, {"core:platform"})
    local meta = minetest.get_meta(node_pos)
    return meta:get_string("platform_string")
end

function common.qid_as_key(dir)
    if not dir then
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
