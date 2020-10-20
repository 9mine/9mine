get_changes = function(destination, addr, player_name)
    local conn = connections[player_name][addr]
    local child_diff = {}
    local parent_diff = {}
    local destination_path, destination_value = next(destination)

    if destination_value.node and destination_value.node.listing then
        local old_listing = destination_value.node.listing
        local result, response = pcall(readdir, conn,
                                       destination_path == "/" and "../" or
                                           destination_path)
        if not result then
            send_warning(player_name, response)
            return
        end
        local new_listing = name_as_key(response or {})
        child_diff = get_diff(old_listing, new_listing, destination_path)
        if child_diff ~= nil then return child_diff, destination_path end
    end

    if destination_value.parent_node and destination_value.parent_node.listing then
        local old_listing = destination_value.parent_node.listing
        local path = destination_value.parent_path
        local result, response = pcall(readdir, conn,
                                       path == "/" and "../" or path)
        if not result then
            send_warning(player_name, response)
            return
        end

        local new_listing = name_as_key(response or {})
        parent_diff = get_diff(old_listing, new_listing, path)
        return parent_diff, path
    end
end
