class 'automount'

function automount:automount()
    self.user_registry_addr = common.get_env("USER_REGISTRY_ADDR")
    self.registry_addr = common.get_env("REGISTRY_ADDR")
    self.inferno_addr = common.get_env("INFERNO_ADDR")
end

function automount:connect_to_root()
    local connection = connections:get_root_connection(self.inferno_addr)
    if not connection then error("Failed connecting to the inferno os " .. self.inferno_addr) end

    -- check for presence of cmdchan
    local root_cmdchan = cmdchan(connection, core_conf:get("cmdchan_path"))
    connections:set_root_cmdchan(root_cmdchan)
    if not root_cmdchan:is_present() then error("cmdchan is not present") end

    -- mount registry
    root_cmdchan:execute("mkdir -p /n/9mine /mnt/registry")
    automount.root_cmdchan = root_cmdchan
    automount:mount_registry()
    return root_cmdchan
end

function automount:mount_registry()
    local root_cmdchan = self.root_cmdchan
    local response =
        root_cmdchan:execute("mount -A " .. self.user_registry_addr .. " /mnt/registry"):gsub("%s+",
                                                                                              "")
    if response == "" then
        local user_management =
            root_cmdchan:execute("ndb/regquery -n description 'user management'"):gsub("\n", "")
        if user_management:match(".*!.*!.*") then
            print(user_management)
            print("mount -A " .. user_management .. " /n/9mine")
            print(root_cmdchan:execute("mount -A " .. user_management .. " /n/9mine"))
        else
            minetest.after(1, automount.poll_user_management, self)
        end
    else
        print("Registry mount failed. Retry")
        minetest.after(1, automount.mount_registry, self)
        return
    end
    minetest.after(1.5, automount.mount_manuals, self, nil, 0)
end

function automount:mount_manuals(cmdchan, count)
    if count and count > 5 then
        return
    elseif not count then
        count = 1
    end

    local root_cmdchan = cmdchan or self.root_cmdchan
    root_cmdchan:execute("mkdir -p " .. core_conf:get("mans_path"))
    local man_addr = root_cmdchan:execute("ndb/regquery -n description 'manuals'"):gsub("\n", "")
    if man_addr:match(".*!.*!.*") then
        root_cmdchan:execute("mount -A " .. man_addr .. " " .. core_conf:get("mans_path"))
    else
        count = count + 1
        minetest.after(1.5, automount.mount_manuals, self, cmdchan, count)
    end
end

function automount:poll_user_management()
    local root_cmdchan = self.root_cmdchan
    print("Polling user management . . .")
    local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'")
        :gsub("\n", "")
    if user_management:match(".*!.*!.*") then
        print(user_management)
        print("mount -A " .. user_management .. " /n/9mine")
        print(root_cmdchan:execute("mount -A " .. user_management .. " /n/9mine"))
    else
        minetest.after(1, automount.poll_user_management, self)
    end
end

function automount:poll_regquery(player, counter, last_login, home_platform)
    local player_name = player:get_player_name()
    if counter > 10 then
        minetest.kick_player(player_name, "Error creating NS. Try again later. Log: \n" .. select(2,
                                                                                                  pcall(
            np_prot.file_read, self.root_cmdchan.connection.conn, "/n/9mine/" .. home_platform
                == "inferno" and "user" or (home_platform == "nfront" and "9front"))))
        return
    end
    counter = counter + 1
    local user_addr = root_cmdchan:execute("ndb/regquery -n "
                                               .. ((home_platform == "inferno" and "user")
                                                   or (home_platform == "nfront" and "is")) .. " "
                                               .. player_name):gsub("\n", "")
    if user_addr:match(".*!.*!.*") then
        minetest.chat_send_player(player_name, user_addr .. " mounted")
        minetest.show_formspec(player_name, "core:some_form",
                               table.concat({"formspec_version[4]", "size[20, 1.2,false]",
            "hypertext[0, 0.3; 20, 1;; <bigger><center>User addr ", user_addr,
            " found.<center><bigger>]"}, ""))
        minetest.after(3, automount.spawn_root_platform, self, user_addr, player, last_login, true)
    else
        minetest.after(2, automount.poll_regquery, self, player, counter, last_login, home_platform)
    end
end

function automount:spawn_root_platform(attach_string, player, _, random)
    local player_name = player:get_player_name()
    local connection = connections:get_connection(player_name, attach_string, true)
    if not connection then
        minetest.chat_send_player(player_name, "no connection established with user namespace")
        print("no connection established with user namespace")
        return
    end
    local player_graph = graphs:get_player_graph(player_name)
    local player_host_node = player_graph:add_host(attach_string)

    local user_cmdchan_path = tostring(core_conf:get("user_cmdchan"))
    local user_cmdchan = cmdchan(connection, user_cmdchan_path)
    if not user_cmdchan:is_present() then
        minetest.chat_send_player(player_name,
                                  "cmdchan at path " .. user_cmdchan_path .. " is not available")
    else
        minetest.chat_send_player(player_name, "cmdchan is available")
    end
    if player_graph:get_node(attach_string .. "/") then
        local root_platform = player_graph:get_platform(attach_string .. "/")
        minetest.show_formspec(player_name, "", "")
        common.goto_platform(player, root_platform:get_root_point())
    else
        if random then
            player:set_pos({
                x = math.random(-30000, 30000),
                y = math.random(-30000, 30000),
                z = math.random(-30000, 30000)
            })
        end
        local result = player:get_pos()
        minetest.after(1.5, automount.mount_manuals, self, user_cmdchan, 0)
        minetest.after(2, function()
            local root_platform = platform(connection, "/", user_cmdchan, player_host_node)
            root_platform:set_player(player_name)
            root_platform.origin_point = result
            root_platform:set_node(player_graph:add_platform(root_platform, nil, player_host_node))
            local point = vector.round(player:get_pos())
            root_platform.root_point = point
            root_platform:spawn(point, player, math.random(0, 255))
        end)
    end

end

