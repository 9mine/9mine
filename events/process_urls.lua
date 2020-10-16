process_urls = function(name, entity)
    local urls = entity.content
    if not urls then return end
    local thumbs = {}
    for url in urls:gmatch("[^\n]+") do
        local thumb = save_thumb(url)
        table.insert(thumbs, thumb)
    end
    local rtx = table.copy(thumbs)
    table.shuffle(rtx)
    entity.object:set_properties({
        automatic_rotate = 0,
        nametag = "Query: " .. entity.req,
        textures = {
            rtx[math.random(#rtx)] .. ".png", rtx[math.random(#rtx)] .. ".png",
            rtx[math.random(#rtx)] .. ".png", rtx[math.random(#rtx)] .. ".png",
            rtx[math.random(#rtx)] .. ".png", rtx[math.random(#rtx)] .. ".png"
        }
    })
    show_thumbs(name, thumbs)
end

