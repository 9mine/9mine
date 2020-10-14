show_thumbnails = function(player_name, thumbnails)
    local vid1 = thumbnails[1]
    local vid2 = thumbnails[2]
    local vid3 = thumbnails[3]
    local vid4 = thumbnails[4]

    local formspec = {
        "formspec_version[3]", "size[16,11,false]",
        "image_button[0.5, 0.5; 7.5, 5;" .. vid1 .. ";" .. vid1 .. ";]",
        "image_button[8.0, 0.5; 7.5, 5;" .. vid2 .. ";" .. vid2 .. ";]",
        "image_button[0.5, 5.5; 7.5, 5;" .. vid3 .. ";" .. vid3 .. ";]",
        "image_button[8.0, 5.5; 7.5, 5;" .. vid4 .. ";" .. vid4 .. ";]",
        "button_exit[13,11;2.5,0.9;close;close]"
    }
    local form = table.concat(formspec, "")
    minetest.show_formspec(player_name, "youtube:youtube", form)
end
