create_platform = function(p, size)
    local first_end = p.x + size
    local second_end = p.z + size

    for first = p.x, first_end do
        for second = p.z, second_end do
            minetest.set_node({x = first, y = p.y, z = second},
                              {name = "cdmod:platform"})
        end
    end
end