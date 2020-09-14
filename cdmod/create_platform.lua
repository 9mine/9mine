create_platform = function(posx, posy, posz, size, orientation, content,
                           host_info, parent_center)
    local new_center = nil
    if orientation == "v" then
        new_center = {
            x = (posx + (posx + size)) / 2,
            y = (posy + (posy + size)) / 2,
            z = posz
        }

    else
        new_center = {
            x = (posx + (posx + size)) / 2,
            y = posy,
            z = (posz + (posz + size)) / 2
        }
    end
    local corner = {x = posx, y = posy, z = posz, s = size, o = orientation}
    local empty_nodes = {}
    local corner = minetest.serialize(corner)
    local first_dimension, second_dimension = 0
    if orientation == "h" then
        first_dimension = posx
        second_dimension = posz
    else
        first_dimension = posx
        second_dimension = posy
    end
    local first_end = first_dimension + size
    local second_end = second_dimension + size

    for first = first_dimension, first_end do
        for second = second_dimension, second_end do
            table.insert(empty_nodes, {x = first, y = second})
            if orientation == "h" then
                minetest.set_node({x = first, y = posy, z = second},
                                  {name = "cdmod:platform"})
                local node =
                    minetest.get_meta({x = first, y = posy, z = second})
                node:set_string("corner", corner)
            else
                minetest.set_node({x = first, y = second, z = posz},
                                  {name = "cdmod:platform"})
                local node =
                    minetest.get_meta({x = first, y = second, z = posz})
                node:set_string("corner", corner)
            end
        end
    end

    local shuffled = {}
    for i, v in ipairs(empty_nodes) do
        local pos = math.random(1, #shuffled + 1)
        table.insert(shuffled, pos, v)
    end

    local node = minetest.get_meta({x = posx, y = posy, z = posz})
    if content ~= nil then
        local full_slots = {}
        for n, file in pairs(content) do
            local k, v = next(shuffled)
            local entity = nil
            if file.type == 128 then
                if orientation == "h" then
                    entity = minetest.add_entity(
                                 {
                            x = v.x,
                            y = math.random(posy + 3, posy + 11),
                            z = v.y
                        }, "cdmod:directory")
                    if file.name == "pod" then
                        entity:set_properties(
                            {
                                visual = "cube",
                                textures = {
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png",
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png",
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png"
                                }
                            })
                    end
                    if string.match(file.path, "/pod/%a*[^/]*$") ~= nil then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_k8s_pod.png"}
                            })
                    end

                    if file.name == "deployments" then
                        entity:set_properties(
                            {
                                visual = "cube",
                                textures = {
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png"
                                }

                            })
                    end

                    if string.match(file.path, "/deployments/%a*[^/]*$") ~= nil then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_k8s_deploy.png"}
                            })
                    end

                else
                    entity = minetest.add_entity(
                                 {
                            x = v.x,
                            y = v.y,
                            z = math.random(posz + 3, posz + 11)
                        }, "cdmod:directory")

                    if file.name == "pod" then
                        entity:set_properties(
                            {
                                visual = "cube",
                                textures = {
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png",
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png",
                                    "cdmod_k8s_pod.png", "cdmod_k8s_pod.png"
                                }

                            })
                    end

                    if string.match(file.path, "/pod/%a*[^/]*$") ~= nil then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_k8s_pod.png"}
                            })
                    end

                    if file.name == "deployments" then
                        entity:set_properties(
                            {
                                visual = "cube",
                                textures = {
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png",
                                    "cdmod_k8s_deploy.png"
                                }

                            })
                    end

                    if string.match(file.path, "/deployments/%a*[^/]*$") ~= nil then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_k8s_deploy.png"}
                            })
                    end

                end

                table.insert(full_slots, {x = v.x, y = v.y})
            else
                if orientation == "h" then
                    entity = minetest.add_entity(
                                 {
                            x = v.x,
                            y = math.random(posy + 3, posy + 11),
                            z = v.y
                        }, "cdmod:file")

                    if file.name == "yaml" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_yaml.png"}})
                    end

                    if file.name == "json" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_json.png"}})
                    end
                    if file.name == "logs" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_logs.png"}})
                    end
                    if file.name == "describe" then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_describe.png"}
                            })
                    end

                else
                    entity = minetest.add_entity(
                                 {
                            x = v.x,
                            y = v.y,
                            z = math.random(posz + 3, posz + 11)
                        }, "cdmod:file")

                    if file.name == "yaml" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_yaml.png"}})
                    end
                    if file.name == "json" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_json.png"}})
                    end
                    if file.name == "logs" then
                        entity:set_properties(
                            {visual = "sprite", textures = {"cdmod_logs.png"}})
                    end
                    if file.name == "describe" then
                        entity:set_properties(
                            {
                                visual = "sprite",
                                textures = {"cdmod_describe.png"}
                            })
                    end
                end
                table.insert(full_slots, {x = v.x, y = v.y})
            end
            entity:set_nametag_attributes({color = "black", text = file.name})
            entity:set_armor_groups({immortal = 0})
            if orientation == "h" then
                entity:set_acceleration({x = 0, y = -6, z = 0})
            else
                entity:set_acceleration({x = 0, y = 0, z = -6})
            end
            entity:get_luaentity().path = file.path
            table.remove(shuffled, k)
        end
        local full = minetest.serialize(full_slots)
        node:set_string("full", full)
    end
    local empty = minetest.serialize(shuffled)
    node:set_string("empty", empty)
    node:set_string("host", minetest.serialize(host_info))
    node:set_string("content", minetest.serialize(content))
    node:set_string("new_center", minetest.serialize(new_center))
    if parent_center ~= nil then connect(parent_center, new_center) end
    return minetest.deserialize(corner)
end

delete_platform = function(posx, posy, posz, size, orientation)
    local node_meta = minetest.get_meta({x = posx, y = posy, z = posz})
    local content_string = node_meta:get_string("content")
    local content = minetest.deserialize(content_string)
    local host_info_string = node_meta:get_string("host")
    local host_info = minetest.deserialize(host_info_string)
    local full_string = node_meta:get_string("full")
    local full = minetest.deserialize(full_string)
    if full ~= nil then
        for k, v in pairs(full) do
            local objects = nil
            if orientation == "h" then
                objects = minetest.get_objects_inside_radius(
                              {x = v.x, y = posy, z = v.y}, 2)
            else
                objects = minetest.get_objects_inside_radius(
                              {x = v.x, y = v.y, z = posz}, 2)
            end
            while next(objects) ~= nil do
                local k, v = next(objects)
                v:remove()
                table.remove(objects, k)
            end
        end
    end

    local corner = {x = posx, y = posy, z = posz, s = size, o = orientation}
    local empty_nodes = {}
    local corner = minetest.serialize(corner)
    local first_dimension, second_dimension = 0
    local new_orientation = nil
    if orientation == "h" then
        new_orientation = "v"
        first_dimension = posx
        second_dimension = posz
    else
        new_orientation = "h"
        first_dimension = posx
        second_dimension = posy
    end

    local first_end = first_dimension + size
    local second_end = second_dimension + size

    for first = first_dimension, first_end do
        for second = second_dimension, second_end do
            table.insert(empty_nodes, {x = first, y = second})
            if orientation == "h" then
                minetest.set_node({x = first, y = posy, z = second},
                                  {name = "air"})
                local node =
                    minetest.get_meta({x = first, y = posy, z = second})
                node:set_string("corner", nil)
            else
                minetest.set_node({x = first, y = second, z = posz},
                                  {name = "air"})
                local node =
                    minetest.get_meta({x = first, y = second, z = posz})
                node:set_string("corner", nil)
            end
        end
    end

    local node = minetest.get_meta({x = posx, y = posy, z = posz})
    node:set_string("empty", nil)
    node:set_string("content", nil)
    node:set_string("full", nil)

    create_platform(posx, posy, posz, size, new_orientation, content, host_info)
end

wipe_platform = function(posx, posy, posz, size, orientation)
    local node_meta = minetest.get_meta({x = posx, y = posy, z = posz})
    local content_string = node_meta:get_string("content")
    local content = minetest.deserialize(content_string)
    local host_info_string = node_meta:get_string("host")
    local host_info = minetest.deserialize(host_info_string)
    local full_string = node_meta:get_string("full")
    local full = minetest.deserialize(full_string)
    if full ~= nil then
        for k, v in pairs(full) do
            local objects = nil
            if orientation == "h" then
                objects = minetest.get_objects_inside_radius(
                              {x = v.x, y = posy, z = v.y}, 2)
            else
                objects = minetest.get_objects_inside_radius(
                              {x = v.x, y = v.y, z = posz}, 2)
            end
            while next(objects) ~= nil do
                local k, v = next(objects)
                v:remove()
                table.remove(objects, k)
            end
        end
    end

    local corner = {x = posx, y = posy, z = posz, s = size, o = orientation}
    local empty_nodes = {}
    local corner = minetest.serialize(corner)
    local first_dimension, second_dimension = 0
    local new_orientation = nil
    if orientation == "h" then
        new_orientation = "v"
        first_dimension = posx
        second_dimension = posz
    else
        new_orientation = "h"
        first_dimension = posx
        second_dimension = posy
    end

    local first_end = first_dimension + size
    local second_end = second_dimension + size

    for first = first_dimension, first_end do
        for second = second_dimension, second_end do
            table.insert(empty_nodes, {x = first, y = second})
            if orientation == "h" then
                minetest.set_node({x = first, y = posy, z = second},
                                  {name = "air"})
                local node =
                    minetest.get_meta({x = first, y = posy, z = second})
                node:set_string("corner", nil)
            else
                minetest.set_node({x = first, y = second, z = posz},
                                  {name = "air"})
                local node =
                    minetest.get_meta({x = first, y = second, z = posz})
                node:set_string("corner", nil)
            end
        end
    end

    local node = minetest.get_meta({x = posx, y = posy, z = posz})
    node:set_string("empty", nil)
    node:set_string("content", nil)
    node:set_string("full", nil)
end

