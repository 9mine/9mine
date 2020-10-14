process_urls = function(name, urls)
    if not urls then return end
    local thumbs = {}
    for url in urls:gmatch("[^\n]+") do
        print("DUMP URL" .. dump(url))
        local thumb = save_thumb(url)
        table.insert(thumbs, thumb)
    end
    show_thumbs(name, thumbs)
end

