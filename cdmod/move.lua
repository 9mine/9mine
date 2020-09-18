move = function(p1, p2, entity)
    local x1 = p1.x
    local y1 = p1.y
    local z1 = p1.z
    local x2 = p2.x
    local y2 = p2.y
    local z2 = p2.z
    print(x1)
    print(y1)
    print(z1)
    print(x2)
    print(y2)
    print(z2)
    local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    local step = 1 / (distance / 6)
    local p = step
    local plot_point = {
        x = round(p * (x2 - x1), 2),
        y = round(p * (y2 - y1), 2),
        z = round(p * (z2 - z1), 2)
    }
    print(dump(plot_point))
    entity:set_velocity(plot_point, true)
    p = p + step
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
