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