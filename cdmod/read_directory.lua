read_directory = function(conn, dir_path)
    local root_dir = nil
    local result = nil
    print("dir_path" .. dir_path)
    if dir_path == "." then
        root_dir = readdir(conn, "./")
    else
        result, root_dir = pcall(readdir, conn, dir_path)
    end
    print("dump root dir")
    print(dump(root_dir))
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
