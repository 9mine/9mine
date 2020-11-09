class 'common'

function common:common()
end

function common:set_look(player, destination)
    local d = vector.direction(player:get_pos(), destination)
    player:set_look_vertical(-math.atan2(d.y, math.sqrt(d.x * d.x + d.z * d.z)))
    player:set_look_horizontal(-math.atan2(d.x, d.z))
end

function common:goto_platform(player, pos)
    local destination = table.copy(pos)
    pos.x = pos.x - 2
    pos.y = pos.y + 1
    pos.z = pos.z - 2
    player:set_pos(pos)
    self:set_look(player, destination)
end

function common:get_platform_string(player)
    local node_pos = minetest.find_node_near(player:get_pos(), 6, {"core:platform"})
    local meta = minetest.get_meta(node_pos)
    return meta:get_string("platform_string")
end

function common:qid_as_key(dir)
    local new_dir = {}
    for _, stat in pairs(dir) do
        new_dir[stat.qid.path_hex] = stat
    end
    return new_dir
end
