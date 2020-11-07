local function modload(modulename)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "%.", "/")
    do
        local path = minetest.get_modpath("core") .. "/?.lua"
        local filename = string.gsub(path, "%?", modulepath)
        local file = io.open(filename, "rb")
        if file then
            -- Compile and return the module
            return assert(loadstring(assert(file:read("*a")), filename))
        end
        errmsg = errmsg .. "\n\tno file '" .. filename .. "' (checked with custom loader)"
    end
    return errmsg
end
table.insert(package.loaders, modload)
