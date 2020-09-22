print("checkoint 1")
minetest.register_authentication_handler(
    {
        get_auth = function(name)
            if authenticated == true then return end
            -- GET PASSWORD HASH FROM LOCAL STORE
            local success, password = pcall(read_file, "/tmp/" .. name)
            print("checkoint -1")
            if success == false then return end
            -- GET AUTHENTICATION INFORMATION
            write_file("/tmp/cmdchan/export/cmd", "getauthinfo default auth " ..
                           name .. " " .. "'" .. password .. "'")
            print("checkoint -2")
            -- GET RESPONSE FROM AUTH CENTER 
            local response = read_file("/tmp/cmdchan/export/cmd")
            print("RESPONSE FROM GETAUTHINFO .. " .. response)

            print("checkoint -3")
            print("PASSWORD FROM READFILE " .. password)
            local new_password = password
            local cache = {
                password = new_password,
                privileges = get_privileges(),
                last_login = 1600767360
            }
            return cache
        end,

        create_auth = function(name, password)
            write_file("/tmp/cmdchan/export/cmd", "getauthinfo default auth " ..
                           name .. " " .. "'" .. password .. "'")
            print("checkoint 2")
            local response = read_file("/tmp/cmdchan/export/cmd")
            print("RESPONSE FROM GETAUTHINFO IN CREATE_AUTH .. " .. response)
            if string.match(response, "Auth fail") then
                print("FAILED TO AUTHENTICATE")
                write_file("/tmp/cmdchan/export/cmd",
                           "touch " .. "/tmp/" .. name)
                write_file("/tmp/" .. name, "FAILED TO AUTHENTICATE")
                return
            end

            print("checkoint 4")
            write_file("/tmp/cmdchan/export/cmd", "touch " .. "/tmp/" .. name)
            print("checkoint 5")
            read_file("/tmp/cmdchan/export/cmd")
            print("checkoint 6")

            write_file("/tmp/" .. name, password)
            print("checkoint 7")
            write_file("/n/client/tmp/cmdchan/export/newuser",
                       name .. " " .. password)
            print("checkoint 8")
            local content = read_file("/n/client/tmp/cmdchan/export/newuser")
            print("checkoint 9")
            print("NEW USER IS: " .. content)

            print("authentication created")
            username = name
            authenticated = true
        end,
        set_password = function(name, password) print("setting password") end
    })

minetest.register_on_leaveplayer(function(ObjectRef, timed_out)
    authenticated = false
end)
