class 'common'
function common.set_look(player, destination)
    local d = vector.direction(player:get_pos(), destination)
    player:set_look_vertical(-math.atan2(d.y, math.sqrt(d.x * d.x + d.z * d.z)))
    player:set_look_horizontal(-math.atan2(d.x, d.z))
end

function common.goto_platform(player, pos)
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
    local new_dir = {}
    for _, stat in pairs(dir) do
        new_dir[stat.qid.path_hex] = stat
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
function common.flight_correction(entity, dst_p, stat)
    entity:set_properties({
        nametag = stat.stat.name
    })
    local current_pos = entity:get_pos()
    local distance = vector.distance(current_pos, dst_p)
    if distance < 3 then
        entity:set_velocity(vector.new())
        local final_dst = {
            x = dst_p.x,
            y = dst_p.y + 2,
            z = dst_p.z
        }
        entity:set_pos(final_dst)
        return
    end
    local dir = vector.direction(current_pos, dst_p)
    local speed = distance > 5 and 20 or 8
    local fast_dir = vector.multiply(dir, speed)
    fast_dir.y = fast_dir.y + 9
    entity:set_acceleration({
        x = 0,
        y = -9,
        z = 0
    })
    entity:set_velocity(fast_dir)
    minetest.after(0.3, common.flight_correction, entity, dst_p)
end
