CopyTool = {
    desription = "Copy file",
    inventory_image = "core_copy.png",
    wield_image = "core_copy.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            copy = 1
        }
    }
}

function CopyTool.copy(entity, player)
    local type = entity.stat.qid.type == 128 and "core:dir_node" or "core:file_node"
    local item = ItemStack(type)
    local item_meta = item:get_meta()
    item_meta:set_string("name", entity.object:get_nametag_attributes().text)
    item_meta:set_string("entity_string", entity.entry_string)
    player:get_inventory():add_item("main", item)
end

minetest.register_tool("core:copy", CopyTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:copy") then
        inventory:add_item("main", "core:copy")
    end
end)
