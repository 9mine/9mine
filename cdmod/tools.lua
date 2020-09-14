minetest.register_tool("cdmod:flip", {
    desription = "Flip platform",
    inventory_image = "cdmod_flip.png",
    wield_image = "cdmod_flip.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {flip = 1}}
})

minetest.register_tool("cdmod:createdir", {
    desription = "create directory",
    inventory_image = "cdmod_createdir.png",
    wield_image = "cdmod_createdir.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {createdir = 1}},
    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()

        local formspec = {
            "formspec_version[3]", "size[10,3,false]",
            "field[0.5,0.5;9,1;dirname;Enter directory name;]",
            "button_exit[7,1.8;2.5,0.9;createdir;createdir]"
        }
        local form = table.concat(formspec, "")
        minetest.show_formspec(player_name, "cdmod:createdir", form)

    end
})

minetest.register_tool("cdmod:enter", {
    desription = "Enter key",
    inventory_image = "cdmod_enter.png",
    wield_image = "cdmod_enter.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {enter = 1}}
})

minetest.register_tool("cdmod:wipe", {
    desription = "Wipe platform",
    inventory_image = "cdmod_wipe.png",
    wield_image = "cdmod_wipe.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {wipe = 1}}
})

minetest.register_tool("cdmod:walk", {
    desription = "walk NPC",
    inventory_image = "cdmod_walk.png",
    wield_image = "cdmod_walk.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {walk = 1}},
    on_use = function(itemstack, player, pointed_thing)
       -- local npc = npcf:get_luaentity(1)
       -- local mvobj = npcf.movement.getControl(npc)
       -- mvobj:walk({x = 15, y = 1, z = 15}, 3)
    end

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
