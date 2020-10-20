-- takes as input result of execution of readdir
-- and changes numeric key to the name of the file
name_as_key = function(listing)
    local new_listing = {}
    for k, v in pairs(listing) do new_listing[v.name] = v end
    return new_listing
end
