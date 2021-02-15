-- add / change settings in here too

aliveai.team_fight=true			--attacking members from other teams
aliveai.grant_invisiable=true			-- grant invisible to people that have collected all book pages


aliveai.set_bones=true			--set bones on death

aliveai.constant_node_testing=false		-- constantly checks if bots can use nodes / vehicles, usefull for test vehilces

aliveai.check_spawn_space=true		-- e.g.g check if the bot spawns in air, and not in the ground
aliveai.enable_build=true			-- makes bots can build
aliveai.status=false				-- show bot status/dev mode (using more cpy)  /aliveai status=true /aliveai status=false
aliveai.tools=0				-- hide bot tools
aliveai.get_everything_to_build_chance=50	-- get everything bots need to build chance
aliveai.get_random_stuff_chance=50		-- get random stuff on spawn (npc only)

aliveai.max_delay=100			-- max bot delay/lag
aliveai.max_new_bots=10			-- max spawning new bots, will be called old if they has been inactive
aliveai.lifetimer=60				-- remove unbehavior none nps

aliveai.default_team="Sam"

furnishings=				{"default:torch","default:chest","default:furnace","default:chest_locked","default:sign_wall_wood","default:sign_wall_steel","vessels:steel_bottle","vessels:drinking_glass","vessels:glass_bottle","aliveai:bed","aliveai:bed_blue","aliveai:chair"}
aliveai.windows=				{"default:glass","default:glass"}
aliveai.ladders=				{"default:ladder_wood","default:ladder_steel"}
aliveai.beds=				{"aliveai:bed","aliveai:bed_blue","beds:bed","beds:fancy_bed"}
aliveai.tools_handler["default"]={			-- see extras.lua for use
		try_to_craft=true,
		use=false,
		tools={"pick_wood","pick_stone","steel_steel","pick_mese","pick_diamond","sword_steel","sword_mese","sword_diamond"},
}
aliveai.tools_handler["aliveai"]={
			try_to_craft=true,
			use=false,
			tools={"cudgel"},
}
aliveai.nodes_handler={			-- dig, mesecon_on, mesecon_off, punch, function
	["default:apple"]="dig",["aliveai_ants:antbase"]="dig",["tnt:tnt"]="dig",["tnt:tnt_burning"]="dig",["fire:basic_flame"]="dig",
}

minetest.register_craft({			-- right click to see
	output = "aliveai:book",
	recipe = {
		{"","default:steel_ingot",""},
		{"default:paper","default:paper","default:paper"},
		{"","default:steel_ingot",""},
	}
})
--[[
Was meant to marge books content, but still returns one old by no reason

minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name()=="aliveai:book" then
		local b={}
		local c
		for i, it in pairs(old_craft_grid) do
			if it:get_name()=="aliveai:book" then
				table.insert(b,it)
				c=1
			end
		end
		if c then
			local bo={}
			local bots={}
			local num=0
			local selected=""
			for i, it in ipairs(b) do
				local meta=minetest.deserialize(it:to_table().metadata) or {bots={},selected="",pages=1,selected_num=0}
				for ii, iit in ipairs(meta.bots) do
					bots[iit]=1
				end
			end
			for i, it in pairs(bots) do
				num=num+1
				table.insert(bo,i)
				if selected=="" then
					selected=i
				end
			end
			local item=itemstack:to_table()
			item.metadata=minetest.serialize({bots=bo,selected=selected,pages=num,selected_num=1})
			local a=ItemStack(item)
			itemstack:replace(item)
		return a
		end
	end
	return itemstack
end)
--]]


minetest.register_craft({			-- right click to see
	output = "aliveai:protector",
	recipe = {
		{"default:steel_ingot"},
		{"default:bronzeblock"},
		{"default:steel_ingot"},
	}
})

minetest.register_craft({			--punch bot from another team to become their member
	output = "aliveai:team_gift",
	recipe = {
		{"","default:bronze_ingot",""},
		{"default:mese_crystal","default:diamond","default:steel_ingot"},
		{"","default:gold_ingot",""},
	}
})

minetest.register_craft({			--give to a laying bot
	output = "aliveai:relive 6",
	recipe = {
		{"default:apple","default:iron_lump","farming:bread"},
		{"vessels:glass_bottle","vessels:glass_bottle","vessels:glass_bottle"},
		{"vessels:glass_bottle","vessels:glass_bottle","vessels:glass_bottle"},
	}
})

minetest.register_craft({			--give to a laying bot
	output = "aliveai:hypnotics 6",
	recipe = {
		{"default:apple","default:tin_lump","farming:bread"},
		{"vessels:glass_bottle","vessels:glass_bottle","vessels:glass_bottle"},
		{"vessels:glass_bottle","vessels:glass_bottle","vessels:glass_bottle"},
	}
})





minetest.register_craft({			--punch bot from another team to become their member
	output = "aliveai:cudgel",
	recipe = {
		{"","default:stick"},
		{"","default:stick"},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "aliveai:cudgel",
	burntime = 4,
})


minetest.register_craft({
	output = "aliveai:bed",
	recipe = {
		{"wool:red","wool:red","wool:red"},
		{"group:wood","group:wood","group:wood"},
	}
})

minetest.register_craft({
	output = "aliveai:bed_blue",
	recipe = {
		{"wool:blue","wool:blue","wool:blue"},
		{"group:wood","group:wood","group:wood"},
	}
})

minetest.register_craft({
	output = "aliveai:chair",
	recipe = {{"group:stick","",""},
		{"group:wood","",""},
		{"group:stick","",""},
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "aliveai:bed",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "aliveai:bed_blue",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "aliveai:chair",
	burntime = 5,
})

minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_aliens:ozer_sword",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_aliens:alien_nrifle",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_aliens:alien_rifle",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_aliens:alien_homing_rifle",
	burntime = 10,
})
minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_aliens:vexcazer",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "aliveai_threats:mind_manipulator",
	burntime = 10,
})




aliveai.make_door({
	name="wood",
	description = "Wooden door",
	texture="default_wood.png",
	material="default:wood",
	craft={
		{"default:wood","",""},
		{"default:wood","",""},
		{"default:wood","",""}
	}
})
aliveai.make_door({
	name="acacia",
	description = "Wooden acacia door",
	texture="default_acacia_wood.png",
	material="default:acacia_wood",
	craft={
		{"default:acacia_wood","",""},
		{"default:acacia_wood","",""},
		{"default:acacia_wood","",""}
	}
})
aliveai.make_door({
	name="jungle",
	description = "Wooden jungle door",
	texture="default_junglewood.png",
	material="default:junglewood",
	craft={
		{"default:junglewood","",""},
		{"default:junglewood","",""},
		{"default:junglewood","",""}
	}
})
aliveai.make_door({
	name="aspen",
	description = "Wooden aspen door",
	texture="default_aspen_wood.png",
	material="default:aspen_wood",
	craft={
		{"default:aspen_wood","",""},
		{"default:aspen_wood","",""},
		{"default:aspen_wood","",""}
	}
})
aliveai.make_door({
	name="pine",
	description = "Wooden pine door",
	texture="default_pine_wood.png",
	material="default:pine_wood",
	craft={
		{"default:pine_wood","",""},
		{"default:pine_wood","",""},
		{"default:pine_wood","",""}
	}
})
aliveai.make_door({
	name="glass",
	description = "Glass door",
	texture="default_glass.png",
	material="default:glass",
	craft={
		{"default:glass","",""},
		{"default:glass","",""},
		{"default:glass","",""}
	}
})
aliveai.make_door({
	name="ice",
	description = "Ice door",
	texture="default_ice.png",
	material="default:ice",
	craft={
		{"default:ice","",""},
		{"default:ice","",""},
		{"default:ice","",""}
	}
})
aliveai.make_door({
	name="steel",
	description = "Steel door",
	texture="default_steel_block.png",
	material="default:steelblock",
	craft={
		{"default:steelblock","",""},
		{"default:steelblock","",""},
		{"default:steelblock","",""}
	}
})


if minetest.get_modpath("kpgmobs") then
	aliveai.nodes_handler["default:grass_1"]={func=aliveai.drive_vehicle,item="kpgmobs:horseh1",pos={x=0,y=20,z=0}}
	aliveai.nodes_handler["default:grass_2"]={func=aliveai.drive_vehicle,item="kpgmobs:horsearah1",pos={x=0,y=20,z=0}}
	aliveai.nodes_handler["default:grass_3"]={func=aliveai.drive_vehicle,item="kpgmobs:horsepegh1",pos={x=0,y=20,z=0}}
end
