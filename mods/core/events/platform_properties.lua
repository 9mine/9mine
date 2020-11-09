platform_properties = function(fields)
    if not (fields.key_enter or fields.save) then
        return
    end
    local platform = platforms:get_platform(fields.platform_string)
    platform:set_refresh_time(tonumber(fields.refresh_time))
    minetest.chat_send_all("For " .. fields.platform_string .. "refresh time is: " .. fields.refresh_time)
end

