plt.resize = function(root, slots, old_size, size, addr, path)
    local size_diff = (size - old_size)
    local size = size_diff % 2 == 1 and size - 1 or size
    local p1 = {
        x = root.x - (size - old_size) / 2,
        y = root.y,
        z = root.z - (size - old_size) / 2
    }
    local p2 = {
        x = p1.x + size,
        y = p1.y,
        z = p1.z + size
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                if ((x >= root.x and x <= root.x + old_size) and (z >= root.z and z <= root.z + old_size)) then
                else
                    local p = {
                        x = x,
                        y = y,
                        z = z
                    }
                    minetest.add_node(p, {
                        name = "core:plt"
                    })
                    local node = minetest.get_meta(p)
                    node:set_string("addr", addr)
                    node:set_string("path", path)
                    table.insert(slots, p)
                end
            end
        end
    end
    table.shuffle(slots)
    return p1, size
end
