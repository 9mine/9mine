minetest.register_tool("youtube:youtube", {
    desription = "show youtube",
    inventory_image = "youtube_youtube.png",
    wield_image = "youtube_youtube.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {youtube = 1}},

    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()
        local formspec = {
            "formspec_version[3]", "size[10,3,false]",
            "field[0.5,0.5;9,1;video_id;Enter video ID;rrI7tOhoVzA QJOwalufjUs zlbVXi3o-2Y i1R4R84-EPA]",
            "button_exit[7,1.8;2.5,0.9;show_thumb;show]" }
        local form = table.concat(formspec, "")
        minetest.show_formspec(player_name, "youtube:video_id", form)
    end
})


