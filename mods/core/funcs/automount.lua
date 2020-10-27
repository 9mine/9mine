automount = function(player) 
    local fields = { remote_address = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or core_conf:get("inferno_address"), spawn_attach = true }
    local addr, path, player = connect(player, fields)
    if addr and path and player then list_directory(addr, path, player) end
end