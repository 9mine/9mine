minetest.register_on_prejoinplayer(function(name, ip)
    local attach_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                              core_conf:get("inferno_address")
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
        if not conn:attach() then
            return "Failed connecting to the inferno os"
        end
    elseif conn:is_alive() then
        print("Already attached. Connection is alive")
    elseif conn.tcp then
        print("Connection is not alive. Reconnecting")
        conn:reattach()
    else
        conn:attach()
    end
end)

