class 'connections'

function connections:connections()
    -- main connection between minetest server 
    -- and paired inferno instance 
    self.root_connection = nil

    -- main cmdchan 
    self.root_cmdchan = nil

    -- holds player connections
    self.connections = {}
end

function connections:set_root_connection(connection)
    self.root_connection = connection
end

function connections:get_root_connection()
    return self.root_connection
end

function connections:set_root_cmdchan(cmdchan)
    self.root_cmdchan = cmdchan
end

function connections:get_root_cmdchan()
    return self.root_cmdchan
end

function connections:get_connection(player_name, addr)
    return self.connections[player_name][addr]
end

function connections:add_connection(player_name, conn)
    if not self.connections[player_name][conn.addr] then
        self.connections[player_name][conn.addr] = conn
    end
    return self.connections[player_name][conn.addr]
end

function connections:add_player(player_name)
    if not self.connections[player_name] then
        self.connections[player_name] = {}
    end
end
