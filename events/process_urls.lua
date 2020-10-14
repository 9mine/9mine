process_urls = function(player_name, urls)
    if not urls then return end
    local thumbnails = {}
    for id in string.gmatch(urls, "[^ ]+") do
        local thumb_name = save_thumbnail(id)
        table.insert(thumbnails, thumb_name)
    end
    show_thumbnails(player_name, thumbnails)
end

