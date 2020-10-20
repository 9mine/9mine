parse_mvcp_params = function(chat_string, path)
    local destination = {}
    local sources = {}
    local params = {}
    for w in chat_string:gmatch("[^ ]+") do
        if w:match("^%-") then
            table.insert(params, w)
        else
            w = w:match("^%./") and
                    w:gsub("^%./", path == "/" and path or path .. "/") or w
            if not w:match("^/") then
                w = path:match("/$") and path .. w or path .. "/" .. w
            end
            destination = w
            sources[w] = {path = w}
        end
    end

    sources[destination] = nil
    if destination:len() > 1 and destination:match('/$') then
        destination = destination:match('.*[^/]')
    end
    if destination:match('^%.$') then destination = path end
    local dst = {}
    dst[destination] = {path = destination}

    return sources, dst, params
end
