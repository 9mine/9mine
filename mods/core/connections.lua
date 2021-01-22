--- Connections store
-- @module connections
class 'connections'

--- constructor
function connections:connections()
    --- connectin between minetest and inferno
    self.root_connection = nil
    --- main cmdchan
    self.root_cmdchan = nil
    --- table with all connections
    self.connections = {}
end

--- create new connection for given player
-- @tparam string player_name name of player
-- @tparam string addr address in for protocol!hostname!port
-- @treturn connection new connection if successfully connected
-- @error[1] error message
function connections:make_new(player_name, addr)
    local connection = self.connections[player_name][addr]
    if not connection then
        connection = np_over_tcp(addr, player_name)
        local result = pcall(np_over_tcp.attach, connection)
        if result then
            self:add_connection(player_name, connection)
            return connection
        else
            return nil, "Connection failed"
        end
    else
        return connection
    end
end
--- set root connection
-- @tparam connection connection to be set
function connections:set_root_connection(connection) self.root_connection = connection end

--- get root connection
-- @tparam string inferno_addr in form of protocol!hostname!port
-- @treturn connection root connection
-- @error[1] error message
function connections:get_root_connection(inferno_addr)
    local connection = self.root_connection
    if not connection then
        connection = np_over_tcp(inferno_addr)
        if connection:attach() then
            self:set_root_connection(connection)
            return connection
        else
            return nil, "Failed to connect to " .. inferno_addr
        end
    else
        return connection
    end
end

--- set cmdchan of the root connection
-- @tparam cmdchan cmdchan root cmdchan object
function connections:set_root_cmdchan(cmdchan) self.root_cmdchan = cmdchan end

--- get cmdchan of the root connection
-- @treturn cmdchan root cmdchan
function connections:get_root_cmdchan() return self.root_cmdchan end

--- retrive connection for the specified player and addr
-- @tparam string player_name name of the player who holds connection
-- @tparam string addr address in form of protocol!hostname!port
-- @tparam bool create is to create new connection if not exists
-- @treturn connection requested connection
function connections:get_connection(player_name, addr, create)
    local connection = self.connections[player_name][addr]
    if not connection and create then connection = self:make_new(player_name, addr) end
    return connection
end

--- store provided connection for player specified
-- @tparam string player_name name of the player for which connection will be stored
-- @tparam connection connection connection object
-- @treturn connection connection provided
function connections:add_connection(player_name, connection)
    if not self.connections[player_name][connection.addr] then
        self.connections[player_name][connection.addr] = connection
    end
    return self.connections[player_name][connection.addr]
end

--- create table for player in connections store
-- @tparam string player_name name of the player for which table will be created
function connections:add_player(player_name)
    if not self.connections[player_name] then self.connections[player_name] = {} end
end
