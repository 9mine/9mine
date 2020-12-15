class 'automount'

function automount:automount()
    self.registry_addr = os.getenv("REGISTRY_ADDR") ~= "" and os.getenv("REGISTRY_ADDR") or
                             core_conf:get("REGISTRY_ADDR")
    self.inferno_addr = os.getenv("INFERNO_ADDR") ~= "" and os.getenv("INFERNO_ADDR") or core_conf:get("INFERNO_ADDR")
end

function automount:connect_to_root()
    local connection = connections:get_root_connection(self.inferno_addr)
    if not connection then
        error("Failed connecting to the inferno os")
    end

    -- check for presence of cmdchan
    local root_cmdchan = cmdchan(connection, core_conf:get("cmdchan_path"))
    connections:set_root_cmdchan(root_cmdchan)
    if not root_cmdchan:is_present() then
        error("cmdchan is not present")
    end

    -- mount registry
    root_cmdchan:execute("mkdir -p /n/9mine /mnt/registry")
    automount.root_cmdchan = root_cmdchan
    automount:mount_registry()
    return root_cmdchan
end

function automount:mount_registry()
    local root_cmdchan = self.root_cmdchan
    local response = root_cmdchan:execute("mount -A " .. self.registry_addr .. " /mnt/registry"):gsub("%s+", "")
    if response == "" then
        local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'"):gsub("\n", "")
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
    end
end

function automount:poll_user_management()
    local root_cmdchan = self.root_cmdchan
    print("Polling user management . . .")
    print(root_cmdchan:execute("mount -A tcp!registry.dev.metacoma.io!30100 /mnt/registry"))
    local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'"):gsub("\n", "")
    if user_management:match(".*!.*!.*") then
        print(user_management)
        print("mount -A " .. user_management .. " /n/9mine")
        print(root_cmdchan:execute("mount -A " .. user_management .. " /n/9mine"))
    else
        minetest.after(1, automount.poll_user_management)
    end
end

function automount:poll_regquery(player, counter, last_login)
    local player_name = player:get_player_name()
    if counter > 10 then
        local result, ns_create_output = pcall(np_prot.file_read, self.root_cmdchan.connection.conn, "/n/9mine/user")
        minetest.kick_player(player_name, "Error creating NS. Try again later. Log: \n" .. ns_create_output)
        return
    end
    counter = counter + 1
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. player_name):gsub("\n", "")
    local response = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. player_name)
    if response == "" then
        minetest.chat_send_player(player_name, user_addr .. " mounted")
        minetest.show_formspec(player_name, "core:some_form",
        table.concat({"formspec_version[4]", "size[15, 1.2,false]",
                      "hypertext[0, 0.2; 15, 1;; <big><center>User addr ", user_addr, " mounted.<center><big>]"}, ""))
    
    else
        minetest.after(2, automount.poll_regquery, self, player, counter, last_login)
    end
end

spawn_root_platform = function(attach_string, player, last_login, random)
    local player_name = player:get_player_name()
    local connection = connections:get_connection(player_name, attach_string, true)
    if not connection then
        return
    end
    local player_graph = graphs:get_player_graph(player_name) or
                             graphs:add_player_graph(player_graph(player_name), player_name)
    local player_host_node = player_graph:add_host(attach_string)

    local user_cmdchan_path = tostring(core_conf:get("user_cmdchan"))
    local user_cmdchan = cmdchan(connection, user_cmdchan_path)
    if not user_cmdchan:is_present() then
        minetest.chat_send_player(player_name, "cmdchan at path " .. user_cmdchan_path .. " is not available")
    else
        minetest.chat_send_player(player_name, "cmdchan is available")
    end

    if not last_login then
        if player_graph:get_node(attach_string .. "/") then
            local root_platform = player_graph:get_platform(attach_string .. "/")
            common.goto_platform(player, root_platform:get_root_point())
        else
            local result
            if random then
                local result = player:set_pos({
                    x = math.random(-30000, 30000),
                    y = math.random(-30000, 30000),
                    z = math.random(-30000, 30000)
                })
            else
                local result = player:get_pos()
            end
            minetest.after(1.5, function()
                local root_platform = platform(connection, "/", user_cmdchan, player_host_node)
                root_platform:set_player(player_name)
                root_platform.mount_point = "/"
                root_platform.origin_point = result
                root_platform:set_node(player_graph:add_platform(root_platform, nil, player_host_node))
                local point = vector.round(player:get_pos())
                root_platform.root_point = point
                root_platform:spawn(point, player, math.random(0, 255))
                minetest.show_formspec(player_name, "", "")
            end)
        end
    else
        minetest.show_formspec(player_name, "", "")
    end
end

