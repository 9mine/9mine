function table.clone(org) return {table.unpack(org)} end
spawn_npc = function(spawned, count)
    local tcp = socket:tcp()
    local connection, err = tcp:connect("inferno", 31000)
    if (err ~= nil) then print("Connection error: " .. dump(err)) end
    local conn = np.attach(tcp, "dievri", "")
    local result, dir = pcall(readdir, conn, "/users")
    tcp:close()
    local leftover = table.copy(spawned)
    if result and dir ~= nil then
        for n, file in pairs(dir) do
            if file.qid.type == 128 then
                if spawned[file.name] ~= nil then
                    leftover[file.name] = nil
                else
                    local ref = {
                        id = count,
                        pos = {
                            x = math.random(0, 16),
                            y = 1,
                            z = math.random(0, 16)
                        },
                        yaw = 0,
                        name = "npcf_p9:npc",
                        title = {text = file.name, color = "#000000"},
                        owner = "dievri" -- optional
                    }
                    npcf:add_npc(ref)
                    npcf:add_title(ref)
                    spawned[file.name] = count
                    count = count + 1
                end
            end
        end
    end
    if next(leftover) ~= nil then
        for k, v in pairs(leftover) do
            spawned[k] = nil
            npcf:delete(v)
        end
    end
    minetest.after(2, spawn_npc, spawned, count)
end

function table.clone(org) return {table.unpack(org)} end


local count = 0
local spawned = {} 
for k, v in pairs(npcf.npcs) do 
    spawned[v.title.text] = count
    count = count + 1
end
minetest.after(2, spawn_npc, spawned, count)