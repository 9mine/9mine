connect = function(p1, p2)
    local x1 = p1.x
    local y1 = p1.y
    local z1 = p1.z
    local x2 = p2.x
    local y2 = p2.y
    local z2 = p2.z
    local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 1)
    local step = 1 / (distance * 2)
    local p = step
    while p < 1 do
        local plot_point = {
            x = x1 + (p * (x2 - x1)),
            y = y1 + (p * (y2 - y1)),
            z = z1 + (p * (z2 - z1))
        }
        minetest.add_entity(plot_point, "cdmod:graph_edge")
        p = p + step
    end

end
