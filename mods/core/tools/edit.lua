minetest.register_tool("core:edit", {
    desription = "Edit file",
    inventory_image = "core_edit.png",
    wield_image = "core_edit.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {edit = 1}}
})