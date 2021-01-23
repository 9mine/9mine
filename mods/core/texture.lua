--- textures handler
class "texture"
--- path to mod textures directory
texture.path = minetest.get_modpath("core") .. "/textures/"

--- set texture on entity
-- @tparam LuaEntity entity LuaEntity on which texture should be set
-- @tparam string texture name of the texture file to be set on entity
-- @tparam[opt] string visual set visual. If not provided, entity original visual will be used
-- @treturn bool true
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

--- check if texture with given name exists
-- @tparam string name texture file name
-- @tparam[opt] string directory name of subdirectory inside textures directory. By default @{path}
-- @treturn bool true texture file exists
-- @treturn bool false texture not exists
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

--- download texture from url save and load
-- @tparam string url url of the texture file
-- @tparam bool secure is url uses https
-- @tparam string name name of texture file to be saved
-- @tparam[opt] string directory name of subdirectory inside @{path}
-- @treturn bool true (successfully downloaded and saved)
-- @error[1] error message
function texture.download(url, secure, name, directory)
    if url == nil then return nil, "No URL" end
    local path = directory and texture.path .. directory .. "/" or texture.path
    lfs.mkdir(path)
    local http = secure and require("ssl.https") or require("socket.http")
    if not texture.exists(name, directory) then
        local body = http.request(url)
        if not body then return nil, "no body downloaded from provided url" end
        local f = assert(io.open(path .. name, "wb"))
        f:write(body)
        f:close()
    end
    minetest.dynamic_add_media(path .. name)
    return true
end

--- download texture over 9p
-- @tparam conn conn 9p connection
-- @tparam string source_path path to the texture
-- @tparam string name name of texture file to be saved
-- @tparam[opt] string directory name of subdirectory inside @{path}
-- @treturn bool true (successfully downloaded and saved)
-- @error[1] error message
function texture.download_from_9p(conn, source_path, name, directory)
    if not texture.exists(name, directory) then
        local result, texture_string = pcall(np_prot.file_read, conn, source_path)
        if not result then return nil, "9p read was unsuccessfull" end
        if directory then lfs.mkdir(texture.path .. directory) end
        local path = directory and texture.path .. directory .. "/" .. name or texture.path .. name
        local file = io.open(path, "w")
        file:write(texture_string)
        file:close()
        minetest.dynamic_add_media(path)
    end
    return true
end
