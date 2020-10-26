automount = function(player) 
    local fields = { remote_address = core_conf:get("automount"), spawn_attach = true }
    local addr, path, player = connect(player, fields)
    if addr and path and player then list_directory(addr, path, player) end
end