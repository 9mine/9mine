process_urls = function(name, entity)
    local urls = entity.content
    if not urls then return end
    local thumbs = {}
    for url in urls:gmatch("[^\n]+") do
        local thumb = save_thumb(url)
        table.insert(thumbs, thumb)
    end
    entity.object:set_properties({automatic_rotate = 0, nametag = "Query: " .. entity.req})
    show_thumbs(name, thumbs)
end

