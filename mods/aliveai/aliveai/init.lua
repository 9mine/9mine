aliveai={
	version=26.1,
--========================options==============================
	grant_invisiable=true,
	spawning=true,					--spawning by self
	character_model="aliveai_character.b3d",		--character model
	character_preview_model="aliveai_preview_character.obj",	--character model
	set_bones=true,			
	default_team="Sam",
	gravity=10,
	check_spawn_space=true,
	enable_build=true,
	status=false,				--show bot status
	systemfreeze=0,				--freeze the system
	tools=0,					--hide bot tools
	max_path_delay_time=1,			--max delay each second, if a path using more will all other be stopped until next secund
	get_everything_to_build_chance=50,
	get_random_stuff_chance=50,		-- get random stuff on spawn
	team_fight=true,
	max_delay=100,				-- max run / bot delay
	lifetimer=60,				--remove unbehavior none nps's
	max_new_bots=10,
	max_chat_distance=200,
--========================not options==============================
	loaded_objects=0,
	delaytime=os.clock(),
	buildings_spawners={},
	terminal_users={},
	bones=minetest.get_modpath("bones"),
	creative=minetest.settings:get("creative_mode"),
	bots_delay=0,
	bots_delay2=0,
	max_path_s=0,
	last_spoken_to="",

	msg={},					--messages to bots
	registered_bots={},			--registered_bots
	active={},				--active bots
	active_num=0,				--active bots count
	smartshop=minetest.get_modpath("smartshop")~=nil,
	mesecons=minetest.get_modpath("mesecons")~=nil,
	loaddata={},			--functions
	savedata={},			--functions
	team_player={},
	farming={},
	storage=minetest.get_mod_storage(),
	save=function(key,newdata)
		aliveai.storage:set_string(key,minetest.serialize(newdata))
	end,
	load=function(key)
		return minetest.deserialize(aliveai.storage:get_string(key)) or {}
	end,
--========================options==============================
	 -- new food databas, checks what players eats, then save it
	food=			{["default:apple"]=2,["farming:bread"]=5,["mobs:meat"]=8,["mobs:meat_raw"]=3,["mobs:chicken_raw"]=2,["mobs:chicken_cooked"]=6,["mobs:chicken_egg_fried"]=2,["mobs:chicken_raw"]=2},
	furnishings=		{"default:torch","default:chest","default:furnace","default:chest_locked","default:sign_wall_wood","default:sign_wall_steel","vessels:steel_bottle","vessels:drinking_glass","vessels:glass_bottle","aliveai:bed","aliveai:bed_blue","aliveai:chair"},
	basics=			{"default:desert_stone","default:sandstonebrick","default:sandstone","default:snowblock","default:ice","default:stone","default:leaves","default:wood","default:acacia_tree","default:jungletree","default:pine_tree","default:aspen_tree"},
	wood=			{["default:tree"]="default:wood",["default:acacia_tree"]="default:acacia_wood",["default:jungletree"]="default:junglewood",["default:pine_tree"]="default:pine_wood",["default:aspen_tree"]="default:aspen_wood"},
	windows=		{"default:glass","default:glass"},
	ladders=			{"default:ladder_wood","default:ladder_steel"},
	beds=			{"aliveai:bed","aliveai:bed_blue","beds:bed","beds:fancy_bed"},
	doors=			{}, -- used by aliveai.make_door({name="steel",description = "Steel door",texture="",material="default:steelblock",craft={})}
	doors_material=		{},
	tools_handler={		-- see extras.lua for use
		["default"]={
			try_to_craft=true,
			use=false,
			tools={"pick_wood","pick_stone","steel_steel","pick_mese","pick_diamond","sword_steel","sword_mese","sword_diamond"},
		},
		["aliveai"]={
			try_to_craft=true,
			use=false,
			tools={"cudgel","relive"},
		}
	},
	nodes_handler={ --dig, mesecon_on, mesecon_off, punch, function
		["default:apple"]="dig",["aliveai_ants:antbase"]="dig",["tnt:tnt"]="dig",["tnt:tnt_burning"]="dig",["fire:basic_flame"]="dig",
	},
}

local aliveai_v1=string.gsub(minetest.get_version().string,"-","%")
local aliveai_v2=aliveai_v1.split(aliveai_v1,".")
--aliveai.minetest_version={tonumber(aliveai_v2[1]),(tonumber(aliveai_v2[2])*0.1),(tonumber(aliveai_v2[3]))*0.01}
aliveai.minetest_version=3



minetest.after(5, function()
	aliveai.team_load()
end)

aliveai.max_path_timer=0
aliveai.max_path_delay=0

aliveai.ticks_pers=os.clock()
aliveai.game_paused=true

minetest.register_globalstep(function(dtime)
	if os.clock()-aliveai.ticks_pers>1 or aliveai.systemfreeze==1 then
		aliveai.game_paused=true
	else
		aliveai.game_paused=false
	end
	aliveai.ticks_pers=os.clock()-aliveai.ticks_pers
	aliveai.max_path_timer=aliveai.max_path_timer+dtime
	if aliveai.max_path_timer>1 then
		aliveai.ticks_pers=0
		aliveai.max_path_s=0
		aliveai.max_path_timer=0
		aliveai.max_path_delay=0
		aliveai.bots_delay2=aliveai.bots_delay
		aliveai.bots_delay=0
	end
	aliveai.ticks_pers=os.clock()
end)

dofile(minetest.get_modpath("aliveai") .. "/base.lua")
dofile(minetest.get_modpath("aliveai") .. "/mapgen.lua")
dofile(minetest.get_modpath("aliveai") .. "/event.lua")
dofile(minetest.get_modpath("aliveai") .. "/other.lua")
dofile(minetest.get_modpath("aliveai") .. "/items.lua")
dofile(minetest.get_modpath("aliveai") .. "/tasks.lua")
dofile(minetest.get_modpath("aliveai") .. "/chat.lua")
dofile(minetest.get_modpath("aliveai") .. "/bot.lua")
dofile(minetest.get_modpath("aliveai") .. "/extras.lua")
dofile(minetest.get_modpath("aliveai") .. "/handlers.lua")

dofile(minetest.get_modpath("aliveai") .. "/settings.lua")

aliveai.delaytime=(os.clock()-aliveai.delaytime)

print("[aliveai] api Loaded")
