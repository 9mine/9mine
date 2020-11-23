class 'texture'

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
end
