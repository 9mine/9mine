StatTool = {
    desription = "Show file statistics",
    inventory_image = "core_stat.png",
    wield_image = "core_stat.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {stat = 1}}
}

function StatTool.parse_mode_bits(mode)
    local res = {}
    local perms = {
        ["DIR"] = 0x80,
        ["APPEND"] = 0x40,
        ["EXCL"] = 0x20,
        ["MOUNT"] = 0x10,
        ["AUTH"] = 0x08,
        ["TMP"] = 0x04,
        ["LINK"] = 0x02
    }

    local owner = {}
    table.insert(owner, {["r"] = 0x0100})
    table.insert(owner, {["w"] = 0x0080})
    table.insert(owner, {["x"] = 0x0040})
    local group = {}
    table.insert(group, {["r"] = 0x0020})
    table.insert(group, {["w"] = 0x0010})
    table.insert(group, {["x"] = 0x0008})
    local others = {}
    table.insert(others, {["r"] = 0x0004})
    table.insert(others, {["w"] = 0x0002})
    table.insert(others, {["x"] = 0x0001})

    local permissions = {}
    table.insert(permissions, owner)
    table.insert(permissions, group)
    table.insert(permissions, others)

    local bytes = {}
    for i = 0, 3 do bytes[i + 1] = bit.band(bit.rshift(mode, i * 8), 0xff) end
    local d = data.new {unpack(bytes)}

    local l = data.layout {bits = {24, 8, 'number', 'le'}, permissions = {0, 16, 'number', 'le'}}

    local result = d:layout(l)

    local mode_bits = {}
    for k, v in pairs(perms) do
        local _ = (bit.band(result.bits, v) ~= 0) and table.insert(mode_bits, k)
    end
    res["mode_bits"] = mode_bits

    local p = ""
    for _, v in pairs(permissions) do
        for _, b in pairs(v) do
            for y, z in pairs(b) do
                local r = (bit.band(result.permissions, z) ~= 0) and y or "-"
                p = p .. r
            end
        end
    end

    res["perms"] = p

    return res
end

function StatTool.show_stat(entity, player, player_name)
    local player_graph = graphs:get_player_graph(player_name)
    local directory_entry = player_graph:get_entry(entity.entry_string)
    local platform = player_graph:get_platform(directory_entry:get_platform_string())
    local conn = platform:get_conn()

    local s = np_prot.stat_read(conn, directory_entry:get_path())
    local result = StatTool.parse_mode_bits(s.mode)
    local mode_bits = ""
    for _, v in ipairs(result["mode_bits"]) do mode_bits = mode_bits .. v .. " " end
    local perms = result["perms"]
    if current_hud[player_name] then player:hud_remove(current_hud[player_name]) end
    local stats = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.8, y = 0.2},
        offset = {x = 0, y = 0},
        text = table.concat({"name:\t\t" .. s.name, "length:\t\t" .. filesize(s.length),
            "owner:\t\t" .. s.uid, "group:\t\t" .. s.gid,
            "access:\t\t" .. os.date("%x %X", s.atime),
            "modified:\t\t" .. os.date("%x %X", s.mtime),
            "mod. by:\t\t" .. (s.muid == "" and "-" or s.muid),
            "mode:\t\t" .. (mode_bits == "" and "FILE" or mode_bits), "perms:\t\t" .. perms,
            "type:\t\t" .. s.type, "qid:\t\t", "       type:\t" .. s.qid.type,
            "       version:\t" .. s.qid.version, "       path:\t" .. "0x" .. s.qid.path_hex}, "\n"),

        alignment = {x = 1, y = 0}
    })
    current_hud[player_name] = stats
end

minetest.register_tool("core:stat", StatTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:stat") then
        inventory:add_item("main", "core:stat")
    end
end)
