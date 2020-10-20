list_path = function(addr, path, player)
    local second = 1
    local partial_path = "/"
    list_directory(addr, partial_path, player)
    for directory in path:gmatch("[^/]+") do
        partial_path = partial_path .. directory
        minetest.after(second, list_directory, addr, partial_path, player)
        partial_path = partial_path .. "/"
        second = second + 1
    end
    return second
end
