-- handle connection string received from attach tool
youtube_grid = function(player, formname, fields)
    local pn = player:get_player_name()
    local ID, rsp = next(fields)
    if ID == "quit" then return end
    local item = ItemStack("youtube:video")
    local item_meta = item:get_meta()
    item_meta:set_string("ID", ID)
    item_meta:set_string("description", ID)
    player:get_inventory():add_item("main", item)

    local formspec = {
        "formspec_version[3]", "size[10,2,false]",
        "label[0.5,0.5;VideoID " .. ID .. " added to inventory]",
        "button_exit[7,1.0;2.5,0.7;close;close]"
    }
    local form = table.concat(formspec, "")
    minetest.show_formspec(pn, "youtube:warning", form)

    -- local a, p, player = plt_by_name(pn)

    -- local result, response = pcall(file_create, a, "/subs", pn, ID)
    -- if (not result) and response:match("File exists") then
    --     minetest.chat_send_player(pn, "Subs for " .. ID .. " already exists")
    --     local formspec = {
    --         "formspec_version[3]", "size[10,2,false]",
    --         "label[0.5,0.5;Subs for " .. ID .. " already exists]",
    --         "button_exit[7,1.0;2.5,0.7;close;close]"
    --     }
    --     local form = table.concat(formspec, "")
    --     minetest.show_formspec(pn, "youtube:warning", form)

    -- elseif result then
    --     local formspec = {
    --         "formspec_version[3]", "size[10,2,false]",
    --         "label[0.5,0.5;Subs for Video " .. ID .. " sent for processing]",
    --         "button_exit[7,1.0;2.5,0.7;close;close]"
    --     }
    --     local form = table.concat(formspec, "")
    --     minetest.show_formspec(pn, "youtube:warning", form)
    -- end
end

