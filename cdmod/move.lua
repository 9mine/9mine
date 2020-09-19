move = function(p1, p2, entity)
    local vector_distance = vector.distance(p1, p2)
    local p = 1 / (vector_distance / 8)
    local plot_point = vector.multiply(vector.subtract(p2, p1), p)
    if entity ~= nil then
        entity:set_velocity(plot_point, true)
    else
        local v_zero = vector.new(0, 0, 0)
        local direction = vector.normalize(p2)
        local next_hop = 3
        return vector.add(p1, vector.multiply(vector.add(v_zero, next_hop),
                                              direction))
    end
end
