save_thumbnail = function(video_id)
    local http = require("socket.http")
    local url = "https://img.youtube.com/vi/" .. video_id ..
                    "/maxresdefault.jpg"
    local body, code = http.request(url)
    if not body then return end
    -- save the content to a file
    local path = minetest.get_modpath("youtube") .. "/textures/thumbnails/"
    local file_name = video_id .. ".png"
    local f = assert(io.open(path .. file_name, 'wb')) -- open in "binary" mode
    f:write(body)
    f:close()
    minetest.dynamic_add_media(path .. file_name)
    return file_name
end
