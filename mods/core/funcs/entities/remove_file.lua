remove_file = function(p)
    local new_p = {x = p.x, y = p.y + 1, z = p.z}
    local e = minetest.get_objects_inside_radius(new_p, 1)[1]
    e:set_acceleration({x = 0, y = -9, z = 0})
    minetest.after(3, function(e) e:remove() end, e)
end
