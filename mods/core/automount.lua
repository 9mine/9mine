automount = function(player) 
    local fields = { connection_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or core_conf:get("inferno_address"), connect = true }
    connect(player, fields)
end

minetest.register_on_joinplayer(function(player)
    minetest.after(1, automount, player)
end)