-- create platform from root point to the 
-- root+size point in x an z directions  
plt.create = function(root, size, addr, path)
    local slots = {}
    local p1 = root
    local p2 = {x = p1.x + size, y = p1.y, z = p1.z + size}
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local p = {x = x, y = y, z = z}
                minetest.add_node(p, {name = "control9p:plt"})
                local node = minetest.get_meta(p)
                node:set_string("addr", addr)
                node:set_string("path", path)
                table.insert(slots, p)
            end
        end
    end
    table.shuffle(slots)
    return slots, root, size
end
