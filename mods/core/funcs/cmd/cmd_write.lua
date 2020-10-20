-- function for executing commands on 9p machine
-- writes <cmd> from minetest console to the cmdchan (lcmd - path to cmdchan)
-- before command execution on 9p machine, navigates to the 
-- path taken from platform
cmd_write = function(addr, path, player_name, cmd, lcmd)
    local conn = connections[player_name][addr]
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, lcmd)
    conn:open(f, 1)
    local buf = data.new("cd " .. path .. " ; " .. cmd)
    conn:write(f, 0, buf)
    conn:clunk(f)
end
