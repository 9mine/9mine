move = function(p1, p2, entity)
    local x1 = p1.x
    local y1 = p1.y
    local z1 = p1.z
    local x2 = p2.x
    local y2 = p2.y
    local z2 = p2.z
    local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    local step = 1 / (distance / 10)
    local p = step
    local plot_point = {
        x = p * (x2 - x1),
        y = p * (y2 - y1),
        z = p * (z2 - z1)
    }
    if entity ~= nil then
        entity:set_velocity(plot_point, true)
    else
        local return_point = {
            x = x1 + 0.3 * (x2 - x1),
            y = y1 + 0.3 * (y2 - y1),
            z = z1 + 0.3 * (z2 - z1)
        }
        print("return point is: " .. dump(return_point))
        return return_point
    end
end

function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
