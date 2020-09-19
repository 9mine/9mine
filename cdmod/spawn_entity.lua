spawn_entity = function(p, ip, name, color)
    if name == "cdmod:host" then
        local entity = minetest.add_entity(p, "cdmod:host")
        entity:set_nametag_attributes({color = "black", text = ip})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = ip
        return entity
    end
    if name == "cdmod:packet" then
        -- [colorize:<color>:<ratio>
        print("Color in entity adding " .. color)
        local packet =  minetest.add_entity(p, "cdmod:packet")
        packet:set_properties({
                textures = {
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200), 
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200),
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200),
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200),
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200),
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200),
                    "cdmod_packet.png^[colorize:"..color..":" .. math.random(50, 200)
                }
            })
         return packet 
    end

end