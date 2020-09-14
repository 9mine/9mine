read_directory = function(conn, dir_path)
    local root_dir = nil
    if dir_path == "." then
        root_dir = readdir(conn, "./")
    else
        result, root_dir = pcall(readdir, conn, dir_path)
        if not result then return nil end
    end
    if root_dir == nil then return end
    local folder_content = {}
    local size = 0
    for n, file in pairs(root_dir) do
        size = size + 1
        if file.qid.type == 128 then
            table.insert(folder_content, {
                name = file.name,
                path = dir_path .. "/" .. file.name,
                type = 128
            })
        else
            table.insert(folder_content, {
                name = file.name,
                path = dir_path .. "/" .. file.name,
                type = 0
            })
        end
    end
    return folder_content
end
