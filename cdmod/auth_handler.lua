cache = nil
username = nil
minetest.register_authentication_handler(
    {
        get_auth = function(name)
            if username ~= nil and name ~= username then
                -- GET PASSWORD HASH FROM LOCAL STORE
                local success, password = pcall(read_file, "/tmp" .. name)
                if success == nil then return end
                -- GET AUTHENTICATION INFORMATION
                write_file("/tmp/cmdchan/export/cmd",
                           "getauthinfo default auth " .. name .. " " ..
                               password)

                -- GET RESPONSE FROM AUTH CENTER 
                local response = read_file("/tmp/cmdchan/export/cmd")
                print(response)
                tcp:close()
                cache = {
                    password = password,
                    privileges = get_privileges(),
                    last_login = 1600767360
                }
            end
            return cache
        end,

        create_auth = function(name, password)
            write_file("/tmp/cmdchan/export/cmd", "touch " .. "/tmp/" .. name)
            read_file("/tmp/cmdchan/export/cmd")
            print("after creating")

            write_file("/tmp/" .. name, pass)
            -- CREATE NEW USER 
            write_file("/n/client/tmp/cmdchan/export/newuser",
                       name .. " " .. pass)
            local content = read_file(conn,
                                      "/n/client/tmp/cmdchan/export/newuser")
            print("content of newuser is " .. content)

            cache = {
                password = pass,
                privileges = get_privileges(),
                last_login = 1600767360
            }
            print("authentication created")
            tcp:close()
            username = name
        end,
        set_password = function(name, password) print("setting password") end
    })
