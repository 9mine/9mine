class 'platform'

function platform:platform(conn, path, cmdchan)
    self.conn = conn
    self.cmdchan = cmdchan
    self.path = path
    self.connection_string = conn.addr .. self.path
end

function platform:readdir()
    local result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
    if not result then
        if self.conn.attachment:is_alive() then
            minetest.chat_send_all("Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.conn.attachment:reattach() then
                result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
                if result then
                    content = content or {}
                end
            end
        end
    else
        self.content = content
    end
    return content
end

function platform:set_size(size)
    if size then
        self.size = size
    else
        local dir_size = math.ceil(math.sqrt((#self.content / 15) * 100))
        self.size = dir_size < 3 and 3 or dir_size
    end
end

function platform:draw(root_point)
    local slots = {}
    local p1 = root_point
    local p2 = {
        x = p1.x + self.size,
        y = p1.y,
        z = p1.z + self.size
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local p = {
                    x = x,
                    y = y,
                    z = z
                }
                minetest.add_node(p, {
                    name = "core:platform"
                })
                local node = minetest.get_meta(p)
                node:set_string("connection_string", self.connection_string)
                table.insert(slots, p)
            end
        end
    end
    table.shuffle(slots)
    self.slots = slots
    self.root_point = root_point
end

function platform:enlarge(new_size)
    local root = self.root_point
    local slots = self.slots
    local old_size = self.size
    local size = new_size or old_size * 2

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
                        name = "core:platform"
                    })
                    local node = minetest.get_meta(p)
                    node:set_string("connection_string", self.connection_string)
                    table.insert(slots, p)
                end
            end
        end
    end
    self.size = size
    self.root_point = p1
    table.shuffle(slots)
end
