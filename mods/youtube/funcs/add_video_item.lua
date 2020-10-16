add_video_item = function(ID, player)
    local item = ItemStack("youtube:video")
    local item_meta = item:get_meta()
    item_meta:set_string("ID", ID)
    item_meta:set_string("description", ID)
    item_meta:set_string("texture", ID .. ".png")
    player:get_inventory():add_item("main", item)
end
