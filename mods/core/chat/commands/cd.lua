minetest.register_chatcommand("cd", {
    func = function(name, params)
        local addr, path, player = plt_by_name(name)
        path = path == "/" and "../" or path
        local dst = string.match(params, "^/") and params or path .. "/" ..
                        params
        list_directory(addr, dst, player)
        return true
    end
})
