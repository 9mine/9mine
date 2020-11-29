automount = function(player)
    local connection_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                                  core_conf:get("inferno_address")
    -- local fields = {
    --     connection_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
    --         core_conf:get("inferno_address"),
    --     connect = true
    -- }
    -- connect(player, fields)
    connection:connection(connection_string)
end

minetest.register_on_joinplayer(function(player)
    minetest.after(2, automount, player)
end)
