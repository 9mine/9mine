minetest.register_tool("cdmod:trace", {
    desription = "Trace route",
    inventory_image = "cdmod_trace.png",
    wield_image = "cdmod_trace.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {trace = 1}}
})

minetest.register_tool("cdmod:connect", {
    desription = "Connect to inferno",
    inventory_image = "cdmod_connect.png",
    wield_image = "cdmod_connect.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {connect = 1}},

    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()
        local formspec = {
            "formspec_version[3]", "size[10,3,false]",
            "field[0.5,0.5;9,1;conn_string;Enter connection string;]",
            "button_exit[7,1.8;2.5,0.9;connect;connect]"
        }
        local form = table.concat(formspec, "")
        minetest.show_formspec(player_name, "cdmod:connect", form)
    end
})

minetest.register_tool("cdmod:write", {
    desription = "Write to file",
    inventory_image = "cdmod_write.png",
    wield_image = "cdmod_write.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {write = 1}}
})
