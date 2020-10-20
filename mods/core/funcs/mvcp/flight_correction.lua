-- correct flying path during mv/cp commands
flight_correction = function(entity, dst_p)
    local current_pos = entity:get_pos()
    local distance = vector.distance(current_pos, dst_p)

    if distance < 3 then
        entity:set_velocity(vector.new())
        local final_dst = {x = dst_p.x, y = dst_p.y + 2, z = dst_p.z}
        entity:set_pos(final_dst)
        return
    end
    local dir = vector.direction(current_pos, dst_p)

    local speed = distance > 5 and 20 or 8
    local fast_dir = vector.multiply(dir, speed)
    fast_dir.y = fast_dir.y + 9
    entity:set_acceleration({x = 0, y = -9, z = 0})
    entity:set_velocity(fast_dir)
    minetest.after(0.3, flight_correction, entity, dst_p)
end
