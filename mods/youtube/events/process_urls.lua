process_urls = function(name, entity)
    --local modpath = minetest.get_modpath("youtube")
    --local file = io.open(modpath .. "/urls.txt", "r")
    --local urls = file:read("*all")
    --file:close()
    local urls = entity.content
    if not urls then return end
    if entity.thumbs then
        local thumbs = minetest.deserialize(entity.thumbs)
        table.shuffle(thumbs)
        entity.object:set_properties({
            automatic_rotate = 0,
            nametag = "Query: " .. entity.req,
            textures = {
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png"
            }
        })
        show_thumbs(name, thumbs)
    else

        local thumbs = {}
        for url in urls:gmatch("[^\n]+") do
            local thumb = save_thumb(url)
            table.insert(thumbs, thumb)
        end
        if #thumbs == 0 then
            entity.object:set_properties(
                {automatic_rotate = 0, nametag = "Query: " .. entity.req})
            send_warning(name, "No video found")
            return
        end
        table.shuffle(thumbs)
        entity.object:set_properties({
            automatic_rotate = 0,
            nametag = "Query: " .. entity.req,
            textures = {
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png",
                thumbs[math.random(#thumbs)] .. ".png"
            }
        })

        entity.thumbs = minetest.serialize(thumbs)
        show_thumbs(name, thumbs)
    end
end

