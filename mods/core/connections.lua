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

function connections:make_new(player_name, addr)
    local connection = self.connections[player_name][addr]
    if not connection then
        connection = np_over_tcp(addr, player_name)
        if connection:attach() then
            self:add_connection(player_name, connection)
            return connection
        else
            return nil
        end
    else
        return connection
    end
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

function connections:get_connection(player_name, addr, create)
    local connection = self.connections[player_name][addr]
    if not connection and create then
        connection = self:make_new(player_name, addr)
    end
    return connection
end

function connections:add_connection(player_name, connection)
    if not self.connections[player_name][connection.addr] then
        self.connections[player_name][connection.addr] = connection
    end
    return self.connections[player_name][connection.addr]
end

function connections:add_player(player_name)
    if not self.connections[player_name] then
        self.connections[player_name] = {}
    end
end
