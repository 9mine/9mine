minetest.register_on_authplayer(function(name, ip, is_success)
    if is_success then authenticated = true end
end)

minetest.register_authentication_handler(
    {
        get_auth = function(name)
            if authenticated == true then return cache end
            -- check if password is in local storage 
            local success, password = pcall(read_file, "/tmp/users/" .. name ..
                                                "/password")
            -- if not, go to create_auth
            if success == false then return nil end
            -- try to authenticate with local password
            write_file("/tmp/file2chan/cmd",
                       "getauthinfo default auth " .. name .. " " .. "'" ..
                           password .. "'")
            local response = read_file("/tmp/file2chan/cmd")
            -- if not successfull, authentication fail
            if string.match(response, "Auth fail") then
                password = 'nil'
            end
            local privs = {}
            if string.match(response, "Auth ok") then
                write_file("/n/client/cmd", "cat /users/" .. name .. "/privs")
                privs = read_file("/n/client/cmd")
            end
            cache = {
                password = password,
                privileges = minetest.string_to_privs(privs),
                last_login = -1
            }
            return cache
        end,

        create_auth = function(name, password)
            -- check if user with given name already exists
            write_file("/n/client/cmd", "ls /users/" .. name)
            local exists = read_file("/n/client/cmd")
            -- if exists, try to authenticate with minetest client provided password
            if string.match(exists, "does not exists") then
                write_file("/tmp/file2chan/cmd", "getauthinfo default auth " ..
                               name .. " " .. "'" .. password .. "'")
                local response = read_file("/tmp/file2chan/cmd")
                -- if password is not match, authentication fails
                if string.match(response, "Auth fail") then
                    password = 'nil'
                end
                cache = {password = password, privileges = {}, last_login = -1}
                return cache
                -- if user with not exists with a given name, create one. Authentication Ok.
            else
                write_file("/tmp/file2chan/cmd",
                           "mkdir " .. "/tmp/users/" .. name)
                read_file("/tmp/file2chan/cmd")
                write_file("/tmp/file2chan/cmd",
                           "touch " .. "/tmp/users/" .. name .. "/password")
                read_file("/tmp/file2chan/cmd")
                write_file("/tmp/users/" .. name .. "/password", password)
                local privs = minetest.settings:get("default_privs")
                write_file("/n/client/newuser",
                           name .. " " .. password .. " " .. privs .. "")
                cache = {
                    password = password,
                    privileges = minetest.string_to_privs(privs),
                    last_login = -1
                }
                authenticated = true
                return cache
            end

        end,
        set_password = function(name, password)
            print("setting password failed")
        end
    })

minetest.register_on_leaveplayer(function(ObjectRef, timed_out)
    authenticated = false
end)
