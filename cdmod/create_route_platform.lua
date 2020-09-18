create_route_platform = function(p, size, parent_center)
    local corner = {
        x = p.x - (size / 2),
        y = p.y,
        z = p.z - (size / 2)
    }
    local first_end = corner.x + size
    local second_end = corner.z + size

    for first = corner.x, first_end do
        for second = corner.z, second_end do

            minetest.set_node({x = first, y = p.y, z = second},
                              {name = "cdmod:platform"})
        end
    end
    if parent_center ~= nil then
        connect(parent_center, p)
    end
end