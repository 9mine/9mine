move = function(p1, p2, entity)
    local vector_distance = vector.distance(p1, p2)
    local p = 1 / (vector_distance / 20)
    local plot_point = vector.multiply(vector.subtract(p2, p1), p)
    if entity ~= nil then
        entity:set_velocity(plot_point, true)
    else
        return vector.add(p1, vector.multiply(vector.subtract(p2, p1), 0.3))
    end
end
