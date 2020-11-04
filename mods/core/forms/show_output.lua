show_output = function(player_name, output)
    minetest.show_formspec(player_name, "core:output", table.concat(
        {"formspec_version[3]", "size[13,13,false]",
         "textarea[0.5,0.5;12.0,12.0;;;" .. minetest.formspec_escape(output) .. "]",
         "button_exit[10,11.8;2.5,0.7;close;close]"
        }, ""))
end
