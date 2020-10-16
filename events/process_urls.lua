process_urls = function(name, entity)
    local urls = entity.content
    if not urls then return end
    if entity.thumbs then
        entity.object:set_properties({
            automatic_rotate = 0,
            nametag = "Query: " .. entity.req
        })
        show_thumbs(name, minetest.deserialize(entity.thumbs))
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
        local rtx = table.copy(thumbs)
        table.shuffle(rtx)
        entity.object:set_properties({
            automatic_rotate = 0,
            nametag = "Query: " .. entity.req,
            textures = {
                rtx[math.random(#rtx)] .. ".png",
                rtx[math.random(#rtx)] .. ".png",
                rtx[math.random(#rtx)] .. ".png",
                rtx[math.random(#rtx)] .. ".png",
                rtx[math.random(#rtx)] .. ".png",
                rtx[math.random(#rtx)] .. ".png"
            }
        })

        entity.thumbs = minetest.serialize(thumbs)
        show_thumbs(name, thumbs)
    end
end

