save_thumb = function(url)
    local wo_host = url:gsub("https://img.youtube.com/vi/", "")
    local ID = wo_host:gsub("/maxresdefault.jpg", "")
    local http = require("socket.http")
    local body, code = http.request(url)
    if not body then return end
    -- save the content to a file
    local path = minetest.get_modpath("youtube") .. "/textures/thumbnails/"
    local name = ID .. ".png"
    local f = assert(io.open(path .. name, 'wb')) -- open in "binary" mode
    f:write(body)
    f:close()
    minetest.dynamic_add_media(path .. name)
    return ID
end
