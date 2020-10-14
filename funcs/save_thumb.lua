save_thumb = function(url)
    local hx = md5.sumhexa(url):sub(1, 8)
    local http = require("socket.http")
    local body, code = http.request(url)
    if not body then return end
    -- save the content to a file
    local path = minetest.get_modpath("youtube") .. "/textures/thumbnails/"
    local name = hx .. ".png"
    local f = assert(io.open(path .. name, 'wb')) -- open in "binary" mode
    f:write(body)
    f:close()
    minetest.dynamic_add_media(path .. name)
    return name
end
