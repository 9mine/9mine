class "texture"

texture.path = minetest.get_modpath("core") .. "/textures/"

function texture.set_texture(entity, texture, visual)
    visual = visual or entity:get_properties().visual
    if visual == "cube" then
        entity:set_properties({
            visual = visual,
            textures = {texture, texture, texture, texture, texture, texture}
        })
    elseif visual == "sprite" then
        entity:set_properties({visual = visual, textures = {texture}})
    end
    return true
end

function texture.exists(name, directory)
    local path = directory and texture.path .. directory .. "/" or texture.path
    local f = io.open(path .. name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function texture.download(url, secure, name, directory)
    if url == nil then return false, "No URL" end
    local path = directory and texture.path .. directory .. "/" or texture.path
    lfs.mkdir(path)
    local http = secure and require("ssl.https") or require("socket.http")
    if not texture.exists(name, directory) then
        local body = http.request(url)
        if not body then return end
        local f = assert(io.open(path .. name, "wb"))
        f:write(body)
        f:close()
    end
    minetest.dynamic_add_media(path .. name)
end

function texture.download_from_9p(conn, source_path, name, directory)
    if not texture.exists(name, directory) then
        local result, texture_string = pcall(np_prot.file_read, conn, source_path)
        if not result then return false end
        if directory then lfs.mkdir(texture.path .. directory) end
        local path = directory and texture.path .. directory .. "/" .. name or texture.path .. name
        local file = io.open(path, "w")
        file:write(texture_string)
        file:close()
        minetest.dynamic_add_media(path)
        return true
    end
end
