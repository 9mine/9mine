cache = nil
username = nil
minetest.register_authentication_handler(
    {
        get_auth = function(name)
            if username ~= nil and name ~= username then
                local tcp, conn = np_connect()
                -- GET PASSWORD HASH FROM LOCAL STORE
                local password = read_file(conn, "/n/client/users/" .. name ..
                                               "/password")

                -- GET AUTHENTICATION INFORMATION
                write_file(conn, "/tmp/cmdchan/export/cmd",
                           "getauthinfo default auth " .. name .. " " ..
                               password)

                -- GET RESPONSE FROM AUTH CENTER 
                local response = read_file(conn, "/tmp/cmdchan/export/cmd")
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
            local tcp, conn = np_connect()

            -- CREATE NEW USER 
            write_file(conn, "/n/client/tmp/cmdchan/export/newuser", name .. " " .. password)
            local content = read_file(conn, "/n/client/tmp/cmdchan/export/newuser")
            print("content of newuser is " .. content)
    
            global_cache = {
                password = password,
                privileges = get_privileges(),
                last_login = 1600767360
            }
            print("authentication created")
            tcp:close()
            username = name
        end,
        set_password = function(name, password) print("setting password") end
    })
