minetest.register_entity("cdmod:graph_edge",  {
    initial_properties = {
    physical = true, 
    pointable = true, 
    visual = "cube", collide_with_objects = true,
    visual_size = {x = 0.5, y = 0.5 },
    textures = {"cdmod_connection.png", "cdmod_connection.png", "cdmod_connection.png",
    "cdmod_connection.png", "cdmod_connection.png", "cdmod_connection.png"}, 
    is_visible = true, nametag_color = "black",
    infotext = "", static_save = true, shaded = true,
    node_box = {type="fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}},
    selection_box = {type = "fixed", fixed = {{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}}}
}})


