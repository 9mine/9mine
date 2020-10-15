save_thumb = function(url)
    local path = minetest.get_modpath("youtube") .. "/textures/thumbnails/"
    local wo_host = url:gsub("https://img.youtube.com/vi/", "")
    local ID = wo_host:gsub("/maxresdefault.jpg", "")
    local name = ID .. ".png"
    
    if not tx_exists(ID) then
        local http = require("socket.http")
        local body, code = http.request(url)
        if not body then return end
        local f = assert(io.open(path .. name, 'wb'))
        f:write(body)
        f:close()
    end

    minetest.dynamic_add_media(path .. name)
    return ID
end
