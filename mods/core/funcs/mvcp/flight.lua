flight = function(entity, to)
    local from = entity:get_pos()
    local dir = vector.direction(from, to)
    local fast_dir = vector.multiply(dir, 20)
    fast_dir.y = fast_dir.y + 9
    entity:set_acceleration({x = 0, y = -9, z = 0})
    entity:set_velocity(fast_dir)
    minetest.after(0.5, flight_correction, entity, to)
end
