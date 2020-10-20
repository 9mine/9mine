-- handle connection string received from attach tool
spawn_attach = function(player, formname, fields)
    local addr, path, player = connect(player, formname, fields)
    if addr and path and player then list_directory(addr, path, player) end
end

