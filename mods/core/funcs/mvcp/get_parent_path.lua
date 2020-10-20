-- returns parent path for provided path
get_parent_path = function(dst)
    if dst == "/" then return "/" end
    local parent = string.match(dst, '.*/')
    if parent == "/" then return "/" end
    local result = string.match(parent, '.*[^/]')
    return result
end
