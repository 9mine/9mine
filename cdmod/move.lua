move = function(p1, p2, entity)
    local x1 = p1.x
    local y1 = p1.y
    local z1 = p1.z
    local x2 = p2.x
    local y2 = p2.y
    local z2 = p2.z
    local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 1)
    local step = 1 / (distance/4)
    local p = step
    local plot_point = {x = p * (x2 - x1), y = p * (y2 - y1), z = p * (z2 - z1)}
    entity:set_velocity(plot_point, true)
    p = p + step
end
