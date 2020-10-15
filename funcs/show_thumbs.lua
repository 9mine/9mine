show_thumbs = function(name, ids)
    local max_thumbs = tonumber(youtube_conf:get("max_thumbs"))
    local ids_num = #ids > max_thumbs and max_thumbs or #ids
    local padding_left = 0.5
    local padding_top = 0.5
    local spacing_h = 0.5
    local spacing_v = 0.5
    local row = 0
    local column = 0
    local max_column = math.ceil(math.sqrt(#ids)) - 1
    local max_row = math.ceil(#ids / (max_column + 1)) - 1
    local video_width = 10
    local video_height = 6
    local w = 2 * padding_left + max_column * spacing_h + video_width *
                  (max_column + 1)
    local h = 2 * padding_top + max_row * spacing_v + video_height *
                  (max_row + 1)
    local size = "size[" .. w .. "," .. h .. ",false]"

    local thumbnails = ""
    for i, id in pairs(ids) do
        if row > max_row then break end
        local w = padding_left + column * (video_width + spacing_h)
        local h = padding_top + row * (video_height + spacing_v)
        thumbnails = thumbnails .. table.concat(
                         {
                "image_button[", w, ",", h, ";", video_width, ",", video_height,
                ";", id, ".png;", id, ";]"
            })
        if column < max_column then
            column = column + 1
        else
            column = 0
            row = row + 1
        end
    end

    local formspec = {
        "formspec_version[3]", size, thumbnails
        -- , "button_exit[13,11;2.5,0.9;close;close]"
    }
    local form = table.concat(formspec, "")
    minetest.show_formspec(name, "youtube:grid", form)
end
