minetest.register_tool("core:read", {
    desription = "Read file",
    inventory_image = "core_read.png",
    wield_image = "core_read.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {read = 1}}
})