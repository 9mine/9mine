print("checkoint 1")

minetest.register_on_authplayer(function(name, ip, is_success)
    if is_success then authenticated = true end
end)

minetest.register_authentication_handler(
    {
        get_auth = function(name)
            if authenticated == true then return cache end
            -- check if password is in local storage 
            local success, password = pcall(read_file, "/tmp/" .. name)
            -- if not, go to create_auth
            if success == false then return nil end
            -- try to authenticate with local password
            write_file("/tmp/cmdchan/export/cmd", "getauthinfo default auth " ..
                           name .. " " .. "'" .. password .. "'")
            local response = read_file("/tmp/cmdchan/export/cmd")
            -- if not successfull, authentication fail
            if string.match(response, "Auth fail") then
                password = 'nil'
            end
            cache = {
                password = password,
                privileges = get_privileges(),
                last_login = -1
            }
            return cache
        end,

        create_auth = function(name, password)
            -- check if user with given name already exists
            local success_remote, password_local =
                pcall(read_file, "/n/client/users/" .. name)
            -- if exists, try to authenticate with minetest client provided password
            if success_remote == true then
                write_file("/tmp/cmdchan/export/cmd",
                           "getauthinfo default auth " .. name .. " " .. "'" ..
                               password .. "'")
                local response = read_file("/tmp/cmdchan/export/cmd")
                -- if password is not match, authentication fails
                if string.match(response, "Auth fail") then
                    password = 'nil'
                end
                cache = {
                    password = password,
                    privileges = get_privileges(),
                    last_login = -1
                }
                return cache
                -- if user with not exists with a given name, create one. Authentication Ok.
            else
                write_file("/tmp/cmdchan/export/cmd",
                           "touch " .. "/tmp/" .. name)
                read_file("/tmp/cmdchan/export/cmd")
                write_file("/tmp/" .. name, password)
                write_file("/n/client/tmp/cmdchan/export/newuser",
                           name .. " " .. password)
                local content =
                    read_file("/n/client/tmp/cmdchan/export/newuser")
                cache = {
                    password = password,
                    privileges = get_privileges(),
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
