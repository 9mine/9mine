aliveai.main=function(self, dtime)
	if aliveai.systemfreeze==1 then
		if self.floating==0 then
			self.object:set_acceleration({x=0,y=0,z =0})
		end
		self.object:set_velocity({x=0,y=0,z=0})
		return self
	end

	if aliveai.bots_delay2>aliveai.max_delay then
		if self.old==0 or (self.old==1 and aliveai.bots_delay2>aliveai.max_delay*1.2) then aliveai.max(self) end
		return self
	end

	if aliveai.botdelay(self,1) then return self end
	aliveai.bot(self, dtime)
	aliveai.botdelay(self)
end

aliveai.bot=function(self, dtime)
	aliveai.bots_delay=aliveai.bots_delay+dtime
	self.timer=self.timer+dtime
	self.timerfalling=self.timerfalling+dtime
	if self.timerfalling>0.2 then aliveai.falling(self) end
	if self.timer<=self.time then return self end
	self.timer=0

--betweens

	if aliveai.dying(self) then return self end
	if not aliveai.dmgbynode(self) then return self end
	if self.step(self,dtime) or self.controlled==1 then return self end
	if aliveai.sleep(self) then return self end
	aliveai.jumping(self)-- if need to jump
	if aliveai.fight(self) then return self end
	if aliveai.fly(self) then return self end

	if aliveai.come(self) then return self end
	if aliveai.folowing(self) then return self end
	aliveai.searchobjects(self)
	if aliveai.need_helper(self) then return self end	-- give stuff
	if aliveai.light(self) then return self end
	if aliveai.node_handler(self) then return self end
	if aliveai.timer(self) then return self end		-- remove monsters
	if aliveai.rndgoal(self) then return self end
	
	aliveai.msghandler(self)
	

	aliveai.pickup(self)-- if can pick up items

	if aliveai.lookaround(self) then return self end

--betweens helpers
	if self.isrnd and self.pickupgoto then return self end
--events
	if self.mine then
		aliveai.mine(self)
		return self
	end
	if self.findspace then
		aliveai.findspace(self)
		return self
	end
	if self.build then
		aliveai.build(self)
		return self
	end
--tasks
	if self.task=="build" then
		aliveai.task_build(self)
		return self
	end
--task create


	if self.task1(self) then return self end
	if self.task2(self) then return self end
	if self.task3(self) then return self end
	if self.task4(self) then return self end
	if self.task5(self) then return self end

	if self.task=="" then
		aliveai.rndwalk(self)
	end
	return self
end


aliveai.do_nothing=function(self)
	return
end

aliveai.create_bot=function(def)
  minetest.log("CREATE BOXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
	if not def then def={} end
	def.name=def.name or "bot"
	def.mod_name=minetest.get_current_modname()
  def.mod_name = "9pzone"
	def.spawn_y=def.spawn_y or 1
	if aliveai.smartshop and def.on_step==nil then def.on_step=aliveai.use_smartshop end
	if not def.click then def.click=aliveai.give_to_bot end

	def.texture=def.texture or "character.png"

	if def.type and def.dropbones~=1 then
		def.dropbones=0
	end

	local itemtexture=def.texture
	if type(def.texture)=="table" and type(def.texture[1])=="string" then itemtexture=def.texture[1] end

	if aliveai.armor_3d and not def.visual and not def.texture[2] then


		def.basey =  def.basey or -0.3

		def.collisionbox = def.collisionbox or {-0.35,0,-0.35,0.35,1.8,0.35}



		if def.type and def.type~="npc" then
			def.usearmor=0
		else
			def.texture={def.texture,"aliveai_air.png","aliveai_air.png",def.texture,}
			def.mesh=aliveai.armor_3d
			def.animation={}
			def.animation["stand"]={x=0, y=79,speed=30,loop=0}
			def.animation["lay"]={x=162,y=166,speed=30,loop=0}
			def.animation["walk"]={x=168, y=187, speed=30,loop=0}
			def.animation["mine"]={x=189, y=198, speed=30,loop=0}
			def.animation["walk_mine"]={x=200, y=219, speed=30,loop=0}
			def.animation["sit"]={x=81, y=160, speed=30,loop=0}
		end
	elseif type(def.texture)~="table" then
		def.texture={def.texture}
	end

	if def.animation and (def.visual==nil or def.visual=="mesh") then
		for i, v in pairs(def.animation) do
			if i=="attack" or i=="fight" then i="mine" end
			def.animation[i].x=def.animation[i].x or 0
			def.animation[i].y=def.animation[i].y or 0
			def.animation[i].speed=def.animation[i].speed or 0
			def.animation[i].loop=def.animation[i].loop or 0
		end
	end

	aliveai.registered_bots[def.mod_name ..":" .. def.name]={
		dmg=def.dmg or 1,
		hp=def.hp or 20,
		team=def.team or "Sam",
		description=def.description or "No description able",
		name=def.name,
		mod_name=def.mod_name,
		bot=def.mod_name ..":" .. def.name,
		type=def.type or "npc",
		item=def.mod_name ..":" .. def.name .. "_spawner",
		textures=def.texture,
		spawn_y=def.spawn_y,
		team=def.team or aliveai.default_team,
		start_with_items=def.start_with_items or "",
		floating=def.floating or 0,
		attacking=def.attacking or 0,
		light=def.light or 1,
		mindamage=def.mindamage or 0,
	}

if not def.no_spawnitem and (not def.visual or def.visual=="mesh") then
	if def.texture~=nil and type(def.texture)=="string" then def.texture={def.texture} end
  --minetest.log("XXXXXX register_node, def:mod_name = " .. def.mod_name .. ", def.name = " .. def.name)
  def.mod_name = "9pzone" 
	minetest.register_node(def.mod_name ..":" .. def.name .."_spawner", {
		description = def.name .." spawner",
		wield_scale={x=0.2,y=0.2,z=0.2},
		tiles=def.texture,
		drawtype="mesh",
		mesh=def.mesh or aliveai.character_preview_model,
		paramtype="light",
		visual_scale=0.1,
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				local pos=aliveai.roundpos(pointed_thing.above)
				pos.y=pos.y+0.5 + def.spawn_y
				minetest.add_entity(pos, def.mod_name ..":" .. def.name):set_yaw(math.random(0,6.28))
				itemstack:take_item()
				minetest.check_for_falling(pos)
			end
			return itemstack
		end,
	})
elseif not def.no_spawnitem then
	minetest.register_craftitem(def.mod_name ..":" .. def.name .."_spawner", {
		description = def.name .." spawner",
		inventory_image = itemtexture or "character.png",
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				local pos=aliveai.roundpos(pointed_thing.above)
				pos.y=pos.y+0.5 + def.spawn_y
				minetest.add_entity(pos, def.mod_name ..":" .. def.name):set_yaw(math.random(0,6.28))
				itemstack:take_item()
			end
			return itemstack
		end,
	})
elseif def.no_spawnitem then
	if not minetest.registered_items[def.no_spawnitem] then
		def.no_spawnitem="aliveai:ai_fake_item_spawner"
	end
	aliveai.registered_bots[def.mod_name ..":" .. def.name].item=def.no_spawnitem
end

--minetest.log("registrer entity " .. def.mod_name .. ":" .. def.name)
minetest.log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")

if not def.no_entity then

def.drop_dead_body=def.drop_dead_body or 1
if def.texture~=nil and type(def.texture)=="string" then def.texture={def.texture} end

minetest.register_entity(def.mod_name ..":" .. def.name,{
	hp_max = def.hp or 20,
	physical = true,
	weight = 5,
	collisionbox = def.collisionbox or {-0.35,-1.0,-0.35,0.35,0.8,0.35}, -- new box {-0.35,0,-0.35,0.35,1.8,0.35}
	visual = def.visual or "mesh",
	visual_size = def.visual_size or {x=1,y=1},
	mesh = def.mesh or aliveai.character_model,
	textures = def.texture,
	colors = {},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
on_rightclick=function(self, clicker,name)
		self.click(self,clicker)
	end,
on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local pos=self.object:get_pos()
		if self.destroy or minetest.get_node({x=pos.x,y=pos.y-2,z=pos.z}).name=="ignore" then
			self.object:remove()
			aliveai.max(self,true)
			return self
		end
		tool_capabilities.damage_groups.fleshy=tool_capabilities.damage_groups.fleshy or 1
		local mindmg=tool_capabilities.damage_groups.fleshy>=self.mindamage
		local dmg=0
		
		if tool_capabilities and tool_capabilities.damage_groups and tool_capabilities.damage_groups.fleshy then
			if not self.hp then self.hp=0 end
			if mindmg==true then
				self.hp=self.hp-tool_capabilities.damage_groups.fleshy
				self.object:set_hp(self.hp)
				dmg=tool_capabilities.damage_groups.fleshy
				self.mood=self.mood-2
			end
		end


		if dir~=nil and mindmg==true then
			local v={x = dir.x*3,y = self.object:get_velocity().y,z = dir.z*3}
			self.object:set_velocity(v)
			local r=math.random(1,99)
			self.sleeping=nil
			self.onpunch_r=r
			minetest.after(1, function(self,v,r)
					if self and self.object and self.hp>0 and self.onpunch_r==r and aliveai.samepos(aliveai.roundpos(self.object:get_velocity()),aliveai.roundpos(v)) then
						self.object:set_velocity({x = 0,y = self.object:get_velocity().y,z = 0})
					end
			end, self,v,r)
		end

		if mindmg==true then
			aliveai.showhp(self)
		end
-- death

		if self.dying then
			if self.hp<=0 then
				aliveai.dying(self,2)
			else
				return self
			end
		end

		if self.object:get_hp()<=0 and not (self.dead or self.dying) then
			local pos=self.object:get_pos()
			if self.drop_dead_body==1 then
				aliveai.showstatus(self,"drop dead body")
				aliveai.stand(self)
				aliveai.dying(self,1)
			end
			self.death(self,puncher,pos)
			aliveai.invdropall(self)
			aliveai.max(self,true)
			return self
		end

		self.punched(self,puncher,dmg)

		if aliveai.armor and self.armor then aliveai.armor(self,{dmg=true}) end

		if self.path then
			aliveai.exitpath(self)
		end
		minetest.after(2, function(self)
			aliveai.eat(self)
		end,self)
		if not aliveai.same_bot(self,puncher) then
			local known=aliveai.getknown(self,puncher)
			if known=="member" then
				aliveai.known(self,puncher,"")
				if math.random(1,3)==1 then aliveai.say(self,"I dont like you anymore") end
				return self
			elseif self.escape==1 and known=="fly" or self.fighting~=1 then
				if self.temper>-5 then
					self.temper=self.temper-0.3
				end
				if math.random(1,3)==1 then aliveai.sayrnd(self,"ahh") end
				self.fly=puncher
				aliveai.known(self,puncher,"fly")
			elseif self.fighting==1 then
				if self.temper<5 then
					self.temper=self.temper+1
				end
				self.fight=puncher
				aliveai.known(self,puncher,"fight")
				if math.random(1,3)==1 then aliveai.sayrnd(self,"ouch") end
			end
				aliveai.lookat(self,puncher:get_pos())
			return self
		end

		if math.random(1,3)==1 then aliveai.sayrnd(self,"ouch") end
		return self
	end,
on_activate=function(self, staticdata)
		if staticdata=="destroy_on_load" then self.object:remove() return end

		self.self_definitions(self)

		if staticdata~="" then
			local r=aliveai.convertdata(staticdata)
			if not r.old then
				 r=minetest.deserialize(staticdata)
			end

			self.inv={}
			self.ignore_item={}
			self.ignore_nodes={ "9pzone:chat" }
			self.known={}
			self.old=r.old
			self.mood=r.mood
			self.team=r.team
			self.namecolor=r.namecolor
			self.known=r.known
			self.inv=r.inv
			self.ignore_item=r.ignore_item
			self.ignore_nodes=r.ignore_ingnore_nodes
			self.task=r.task
			self.taskstep=r.taskstep
			self.botname=r.botname
			self.start_with_items=""
			self.dmg=r.dmg
			self.floating=r.floating
			self.sleeping=r.sleeping
			self.attention_nodes=r.attention_nodes
			if r.savetool then self.tools=r.tools self.savetool=1 self.tool_near=1 end
			if r.home then self.home=r.home end
			if r.resources then self.resources=r.resources end

			for i, v in pairs(r) do
--local name=i

--				if string.find(name,"storge")==1 then
--name=string.gsub(name,"storge", "save__")
--end

				if string.find(i,"save__")==1 then
					self[i]=v
				end
			end

			if r.hp then self.object:set_hp(r.hp) end

			if r.dying then
				self.dying=r.dying
				minetest.after(0.1, function(self)
					aliveai.anim(self,"lay")
				end, self)
			end

			for i, s in pairs(aliveai.loaddata) do
				s(self,r)
			end

			aliveai.showstatus(self,"loaded")
		end
		if self.attention_nodes==nil then self.attention_nodes={} end
		if self.inv==nil then self.inv={} end
		if self.ignore_item==nil  then self.ignore_item={} end

		self.move={x=0,y=0,z=0,speed=1}
		aliveai.anim(self,"stand")

		aliveai.floating(self,self.floating)

		if self.botname=="" then self.botname=aliveai.genname() end
		if self.namecolor~="" then self.object:set_properties({nametag=self.botname,nametag_color="#" .. self.namecolor}) end
		if self.start_with_items~="" and type(self.start_with_items)=="table" then
			for i, s in pairs(self.start_with_items) do
				aliveai.invadd(self,i,s,true)
			end
			self.start_with_items=""
		end

		self.delay_average={time=0}

		aliveai.max(self)

		if self.old~=1 then
			if not self.object:get_pos() then
				self.object:remove()
				return
			end
			self.spawn(self)
			aliveai.showstatus(self,"new bot spawned")
			if self.type=="npc" and math.random(1, aliveai.get_random_stuff_chance)==1 then
				local itmnum=0
				for i, v in pairs(minetest.registered_items) do
					if math.random(1,20)==1 then
						if minetest.get_all_craft_recipes(i) and i~="air" then
							self.inv[i]=1
							itmnum=itmnum+1
							if itmnum>9 then break end
						end
					end
				end
			end
		else
			self.on_load(self)
			aliveai.showstatus(self,"bot loaded")
		end
		self.lastitem_name="wooden planks"
		self.talking_to="you"
		self.lastitem_count=1
		self.hp=self.object:get_hp()

		if aliveai.creative=="true" then
			self.creative=1
			self.superbuild=1
		end

		return self
	end,
get_staticdata = function(self)
		aliveai.max(self)
		if (self.isfalling and self.kill_deep_falling==1) or self.dead then
			return "destroy_on_load"
		end
		local r={inv=self.inv,old=1,hp=self.object:get_hp(),
			task=self.task,
			taskstep=self.taskstep,
			ignore_item=self.ignore_item,
			known=self.known,
			ignore_nodes=self.ignore_ingnore_nodes,
			botname=self.botname,
			dmg=self.dmg,
			mood=self.mood,
			team=self.team,
			namecolor=self.namecolor,
			floating=self.floating,
			attention_nodes=self.attention_nodes,
			}
		if self.sleeping then r.sleeping=self.sleeping end
		if self.home then r.home=self.home end
		if self.resources then r.resources=self.resources end
		if self.savetool then r.tools=self.tools r.savetool=1 end
		if self.start_with_items then r.start_with_items="" end
		if self.dying then r.dying=self.dying end

		for i, v in pairs(self) do
			if string.find(i,"storge")==1 or string.find(i,"save__")==1 then
				r[i]=v
			end
		end

		for i, s in pairs(aliveai.savedata) do
			local rr=s(self,r)
			if rr then
				for i1, s2 in pairs(rr) do
					r[i1]=s2
				end
			end
		end

		return minetest.serialize(r)
	end,
on_step=aliveai.main,
	botname=def.botname or "",
	namecolor= def.name_color or "ffffff",
	timerfalling= 0,
	aliveai= true,
	old= 0,
	temper= 0,
	mood=10,
	rnd= 0,
	isrnd= false,
	done="",
	taskstep= 0,
	task= "",
	pathn= 1,
	anim= "",
	timer= 0,
	time= 1,
	otime= 1,
	timer3= 0,
	delaytimer=0,
	delaytimer2=0,
--define
	arm= def.arm or 5,
	dmg= def.dmg or 1,
	dropbones= def.dropbones or 1,
	superbuild= def.superbuild or 0,
	house=def.house or "",
	creative=def.creative or "",
	leader=def.leader or 0,
	team= def.team or aliveai.default_team,
	visual= def.visual or "mesh",
	basey= def.basey or 0.7, -- new -0.3
	damage_by_blocks= def.damage_by_blocks or 1,
	kill_deep_falling= def.kill_deep_falling or 1,
	crafting= def.crafting or 1,
	avoidy= def.avoid_height or 6,
	drop_dead_body=def.drop_dead_body or 1,
	type= def.type or "npc",
	distance= def.distance or 15,
	tools= def.tools or "",
	tool_index=def.tool_index or 1,
	tool_reuse=def.tool_reuse or 0,
	tool_chance= def.tool_chance or 5,
	tool_see= def.tool_see or 1,
	tool_near= def.tool_near or 0,
	escape= def.escape or 1,
	fighting= def.fighting or 1,
	attack_players= def.attack_players or 0,
	attack_chance= def.attack_chance or 10,
	smartfight= def.smartfight or 1,
	usearmor=def.usearmor or 1,
	building= def.building or 1,
	pickuping= def.pickuping or 1,
	attacking= def.attacking or 0,
	coming= def.coming or 1,
	work_helper= def.work_helper or 0,
	coming_players= def.coming_players or 1,
	talking= def.talking or 1,
	stealing= def.stealing or 0,
	steal_chance= def.steal_chance or 0,
	start_with_items= def.start_with_items or "",
	light= def.light or 1,
	hugwalk= def.hugwalk or 0,
	lowestlight= def.lowest_light or 10,
	lightdamage=def.hurts_by_light or 1,
	annoyed_by_staring= def.annoyed_by_staring or 1,
	drowning= def.drowning or 1,
	mindamage=def.mindamage or 0,
--animation
	animation=def.animation or {
		stand={x=1,y=39,speed=30},
		walk={x=41,y=61,speed=30},
		mine={x=65,y=75,speed=30},
		hugwalk={x=80,y=99,speed=30},
		lay={x=113,y=123,speed=0},
		sit={x=101,y=111,speed=0},
	},
--functions


	on_chat= def.on_chat or aliveai.do_nothing,
	on_spoken_to= def.on_spoken_to or aliveai.on_spoken_to,
	on_fighting= def.on_fighting or aliveai.do_nothing,
	on_escaping= def.on_escaping or aliveai.do_nothing,
	on_punching= def.on_punching or aliveai.do_nothing,
	on_punch_hit= def.on_punch_hit or aliveai.do_nothing,
	on_detect_enemy= def.on_detect_enemy or aliveai.do_nothing,
	on_detecting_enemy= def.on_detecting_enemy or aliveai.do_nothing,
	death= def.death or aliveai.do_nothing,
	spawn= def.spawn or aliveai.do_nothing,
	on_load= def.on_load or aliveai.do_nothing,
	on_random_walk= def.on_random_walk or aliveai.do_nothing,
	click= def.click or aliveai.do_nothing,
	punched= def.on_punched or aliveai.do_nothing,
	on_meet= def.on_meet or aliveai.do_nothing,
	step= def.on_step or aliveai.do_nothing,
	on_dig= def.on_dig or aliveai.do_nothing,
	on_blow=def.on_blow or aliveai.do_nothing,
--tasks
	task1= def.task1 or aliveai.task_build,
	task2= def.task2 or aliveai.task_stay_at_home,
	task3= def.task3 or aliveai.task_farming,
	task4= def.task4 or aliveai.do_nothing,
	task5= def.task5 or aliveai.do_nothing,

	floating= def.floating or 0,

	self_definitions = function(self)
		if def.self and type(def.self)=="table" then
			for i, s in pairs(def.self) do
				if not self[i] then
					self[i]=s
				end
			end
		end
	end,
})
end

if not aliveai.spawning or def.no_spawning then
	aliveai.loaded(def.mod_name ..":" .. def.name)
	return
end

def.spawn_in= def.spawn_in or "air"
def.spawn_chance= def.spawn_chance or 1000
def.check_spawn_space= def.check_spawn_space or 1

if def.light==nil then def.light=1 end
if def.lowest_light==nil then def.lowest_light=10 end
 
minetest.register_abm({
	nodenames = def.spawn_on or {"group:spreading_dirt_type","group:sand","default:snow"},
	interval = def.spawn_interval or 30,
	chance = def.spawn_chance,
	action = function(pos)
		if aliveai.systemfreeze==1 then
			return
		end
		local pos1={x=pos.x,y=pos.y+1,z=pos.z}
		local pos2={x=pos.x,y=pos.y+2,z=pos.z}
		local l = minetest.get_node_light(pos1) or 0
		if l==nil then return true end
		if aliveai.random(1,def.spawn_chance)==1
		and (def.light==0 
		or (def.light>0 and l>=def.lowest_light) 
		or (def.light<0 and l<=def.lowest_light)) then
			if aliveai.check_spawn_space==false or def.check_spawn_space==0 or ((minetest.get_node(pos1).name==def.spawn_in and minetest.get_node(pos2).name==def.spawn_in) or minetest.get_item_group(minetest.get_node(pos1).name,def.spawn_in)>0) then
				aliveai.newbot=true
				pos1.y=pos1.y+def.spawn_y
				local m = minetest.add_entity(pos1, def.mod_name ..":" .. def.name)
				if m then
					m:set_yaw(math.random(0,6.28))
				end
			end
		end
	end,
})
aliveai.loaded(def.mod_name ..":" .. def.name)
end


aliveai.loaded=function(name)
	aliveai.loaded_objects=aliveai.loaded_objects+1
	print("[aliveai] loaded " .. aliveai.loaded_objects .. ": " .. name)
end


minetest.register_craftitem("aliveai:npcspawner", {
	description=minetest.colorize("black", "Random npc spawner") .. minetest.get_background_escape_sequence("pink"),
	--description = "Random npc spawner",
	inventory_image ="aliveai_rnd.png",
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				local pos=aliveai.roundpos(pointed_thing.above)
				local list={}
				local ii=1
				for i, v in pairs(aliveai.registered_bots) do
					if v.type=="npc" then
						list[ii]={y=v.spawn_y,name=v.bot}
						ii=ii+1
					end
				end
				local bot=list[aliveai.random(1,ii)]
				if not bot then return end
				pos.y=pos.y+bot.y
				minetest.add_entity(pos, aliveai.registered_bots[bot.name].bot):set_yaw(math.random(0,6.28))
				itemstack:take_item()
			end
			return itemstack
		end,
	})

minetest.register_craftitem("aliveai:teampawner", {
	--description = "Random npc team " .. aliveai.default_team .." spawner",
	description=minetest.colorize("white", "Random team " .. aliveai.default_team .." spawner") .. minetest.get_background_escape_sequence("purple"),
	inventory_image ="aliveai_rnd.png",
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				local pos=aliveai.roundpos(pointed_thing.above)
				local list={}
				local ii=1
				for i, v in pairs(aliveai.registered_bots) do
					if v.type=="npc" and v.team==aliveai.default_team then
						list[ii]={y=v.spawn_y,name=v.bot}
						ii=ii+1
					end
				end
				local bot=list[aliveai.random(1,ii)]
				if not bot then return end
				pos.y=pos.y+bot.y
				minetest.add_entity(pos, aliveai.registered_bots[bot.name].bot):set_yaw(math.random(0,6.28))
				itemstack:take_item()
			end
			return itemstack
		end,
	})

minetest.register_craftitem("aliveai:ai_fake_item_spawner", {
	description = "Fake spawner (bugfix item)",
	inventory_image = "aliveai_rnd.png",
	groups={not_in_creative_inventory=1},
	on_place = function(itemstack, user, pointed_thing)
		return itemstack
	end
})




aliveai.convertdata=function(str,spl)
	if type(str)=="string" then
		local s1=str.split(str,"?")
		local r={}
		for _, s in ipairs(s1) do
			local s2=s.split(s,"=")
			if s2[2]~=nil and string.find(s2[2],"*")~=nil then	-- tables
				local d1=s2[2].split(s2[2],"*")
				local inner={}
				for nn, ss in pairs(d1) do
					local d2=ss.split(ss," ")
					if d2 and d2[1] then
						if tonumber(d2[1])~=nil then d2[1]=tonumber(d2[1]) end -- table name n to n

						if tonumber(d2[2])~=nil then
							inner[d2[1]]=tonumber(d2[2])
						else
							inner[d2[1]]=d2[2]
						end
					end
				end
				r[s2[1]]=inner
			elseif s2[2]~=nil and string.find(s2[2],",")~=nil then	-- pos
				r[s2[1]]=aliveai.strpos(s2[2],true)
			else						-- else	
				local tnr=tonumber(s2[2])
				if tnr~=nil then s2[2]=tnr end
				r[s2[1]]=s2[2]
			end
		end
		return r
	elseif type(str)=="table" then

		print("WARNING: the function convertdata will be replaced, use minetest.deserialize and minetest.serialize instead")


		if 1 then return "" end

		local r=""
		for n, s in pairs(str) do
		r=r .. n .."="
			if s and type(s)=="table" and s.x and s.y and s.z then		-- pos
				r=r .. aliveai.strpos(s,false)
			elseif s and type(s)=="table" then				-- table
				for n1, s1 in pairs(s) do
					if n1==nil or type(n1)=="table" or type(s1)=="table" then
						n1=""
						s1=""
						print("Converting variable failure: tables in tables not allowed")
					end
					r=r .. n1 .. " " .. s1 .."*"
				end
			else							-- else
				r=r .. s
			end
			r=r .. "?"
		end
		return r
	end
	return ""
end
