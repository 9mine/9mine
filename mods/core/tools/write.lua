minetest.register_tool("core:write", {
    desription = "Write to file",
    inventory_image = "core_write.png",
    wield_image = "core_write.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {write = 1}}
})