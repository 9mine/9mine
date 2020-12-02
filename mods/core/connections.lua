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
