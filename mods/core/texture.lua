class 'texture'

texture.path = minetest.get_modpath("core") .. "/textures/"

function texture.set_texture(entity, texture, visual)
    local visual = visual or entity:get_properties().visual
    local lua_entity = entity:get_luaentity()
    if visual == "cube" then
        entity:set_properties({
            visual = visual,
            textures = {texture, texture, texture, texture, texture, texture}
        })
    elseif visual == "sprite" then
        entity:set_properties({
            visual = visual,
            textures = {texture}
        })
    end
    return true
end

function texture.exists(name, directory)
    local path = directory and texture.path .. directory .. "/" or texture.path
    local f = io.open(path .. name, "r")
    if f ~= nil then
        io.close(f)
        minetest.dynamic_add_media(path .. name)
        return true
    else
        return false
    end
end

function texture.download(url, secure, name, directory)
    local path = directory and texture.path .. directory .. "/" or texture.path
    local http = secure and require("ssl.https") or require('socket.http')
    local body, code = http.request(url)
    if not body then
        return
    end
    local f = assert(io.open(path .. name, 'wb'))
    f:write(body)
    f:close()
    minetest.dynamic_add_media(path .. name)
end

function texture.download_from_9p(conn, source_path, destination_name, destination_directory)
    local result, texture_string = pcall(np_prot.file_read, conn, source_path)
    if not texture.exists(destination_name) then
        local path = destination_directory and texture.path .. destination_directory .. "/" .. destination_name or
                         texture.path .. destination_name
        local file = io.open(path, "w")
        file:write(texture_string)
        file:close()
        minetest.dynamic_add_media(path)
    end
end
