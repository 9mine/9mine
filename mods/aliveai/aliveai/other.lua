--show status / command / ai status


minetest.register_chatcommand("aliveai", {
	params = "",
	description = "aliveai terminal",
	privs = {aliveai=true},
	func = function(name, param)
		local user=minetest.get_player_by_name(name)
		minetest.registered_items["aliveai:terminal"].on_use(1,user,{type=""})
	end
})


minetest.register_privilege("aliveai_buildings_spawning", {
	description = "Can use aliveai buildings_spawning",
	give_to_singleplayer= false,
})

minetest.register_privilege("aliveai", {
	description = "Can use aliveai terminal",
	give_to_singleplayer= false,
})

minetest.register_privilege("aliveai_invisibility", {
	description = "Have collected all book pages",
	give_to_singleplayer= false,
})

minetest.register_tool("aliveai:terminal", {
	description = "Terminal",
	range=15,
	inventory_image = "aliveai_terminal.png",
	on_use=function(itemstack, user, pointed_thing)
		if not user or type(user)~="userdata" then return end
		local name=user:get_player_name()
		if minetest.check_player_privs(name, {aliveai=true})==false then
			if type(itemstack)=="userdata" then
				itemstack:replace(nil)
			end
			minetest.chat_send_player(name,"You are unallowed to use this tool")
			return itemstack
		end

		if not aliveai.terminal_users[name] then
			aliveai.terminal_users[name]={botname=""}
		end
		if pointed_thing.type=="object" then
			if aliveai.is_bot(pointed_thing.ref) then
				aliveai.terminal_users[name].bot=pointed_thing.ref
				aliveai.terminal_users[name].botname=pointed_thing.ref:get_luaentity().botname
				pointed_thing.ref:get_luaentity().terminal_user=name
			end
		end
		aliveai.show_terminal(user)
	end,
	on_place=function(itemstack, user, pointed_thing)
		aliveai.terminal_users[user:get_player_name()]=nil
	end
})

minetest.register_on_leaveplayer(function(player)
	if aliveai.terminal_users[player:get_player_name()] then
		aliveai.terminal_users[player:get_player_name()]=nil
	end
end)

aliveai.show_terminal=function(user,a)
	if not user or type(user)~="userdata" then return end
	local name=user:get_player_name()
	if a and not aliveai.terminal_users[name].live_status then
		return
	end

	if aliveai.gethp(aliveai.terminal_users[name].taget)<0 then
		aliveai.terminal_users[name].taget=nil
	end
	if aliveai.gethp(aliveai.terminal_users[name].bot)<0 then
		aliveai.terminal_users[name].bot=nil
		aliveai.terminal_users[name].botname=""
	else
		aliveai.terminal_users[name].status=1
	end

	local bots=""
	local bots_n=1
	local obs_text=""
	local botname=aliveai.terminal_users[name].botname or ""
	local privs=""
	local privsns=""
	local cmds=""
	local n=0
	local self
	local botn=0
	local coma=""
	local gui="size[10,10]"

	for i, bot in pairs(aliveai.active) do
		if bot:get_luaentity() then
			botn=botn+1
			bots=bots .. coma .. bot:get_luaentity().botname
			if bots_n==1 and bot:get_luaentity().botname==botname then
				bots_n=botn
				self=bot:get_luaentity()
			elseif not self then
				self=bot:get_luaentity()
			end
			coma=","
		end
	end

	aliveai.terminal_users[name].obs={}
	aliveai.terminal_users[name].bot=nil
	if self then
		coma=""
		self.terminal_user=name
		aliveai.terminal_users[name].botname=self.botname
		aliveai.terminal_users[name].bot=self.object
		for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(),50)) do
			if ob and aliveai.visiable(self,ob) and not aliveai.same_bot(self,ob) and not (ob:get_luaentity() and ob:get_luaentity().type==nil) then
				local na=""
				if ob:is_player() then
					na=ob:get_player_name()
				elseif aliveai.is_bot(ob) then
					na=ob:get_luaentity().botname
				elseif ob:get_luaentity() then
					na=ob:get_luaentity().name
				end
				table.insert(aliveai.terminal_users[name].obs,{ob=ob,name=na})	 -- .." " .. aliveai.team(ob)
				obs_text=obs_text .. coma ..na					 --.. na .." " .. aliveai.team(ob) ..
				coma=","
				if not aliveai.terminal_users[name].target then
					aliveai.terminal_users[name].target=ob
				end
			end
		end

		local sa=self.delay_average.time
		gui=gui .."label[5,1;Bot\n" .. (sa*100) .. "%]"
		if sa>1 then sa=1 elseif sa<0 then sa=0 end
		gui=gui .."box[5," ..(3-(2*sa)) .. ";0.5," .. (2*sa) .. ";#" .. aliveai.terminal_status_color(sa) .."]"
		.."label[4,3.5;HP: " .. self.hp  .. "]"
		if aliveai.terminal_users[name].bot_showstatus then
			local bsta=aliveai.terminal_users[name].bot_showstatus
			gui=gui .."label[4,3;Bot status: " ..  minetest.colorize("#" .. bsta.color, bsta.msg) .. "]"
		end

	end
	local events="Remove,Die,Dying,Relive,Say,setTeam,Sleep,useTool,Search Help,Creative,Superbuild,Fly,gotoBed,Walk,Run,Look At,Build,exit Mine,Farming,setHome,StayAt Home,rndGoal,NodeHandler,Light,Fight,Escape,Folow,Come,Walk To,rndWalk,stop rndWalk"
	local event=""
	local x=-0.2
	local y=2
	for i, v in pairs(events.split(events,",")) do
		event=event .."button[" .. x .. "," .. y .. ";1.5,1;event;".. v .."]"
		x=x+1.3
		if x>3 then
			x=-0.2
			y=y+0.7
		end
	end

	gui=gui
	.."dropdown[-0.2,0;3.7,1;bot;" .. bots.. ";" .. bots_n .."]"
	.."dropdown[-0.2,0.7;3.7,1;target;" .. obs_text.. ";1]"
	.."field[0,1.6;2,1;text;;]"
	.."button[1.4,1.3;2,1;teleport;Teleport to]"
	.. event
	.."button[4,0;1.7,1;status;Live status " .. (aliveai.terminal_users[name].live_status or 0) .."]"
	.."label[4,-0.3;Active bots: " .. aliveai.active_num .. "]"
	.."button[5.5,0;1.5,1;clearlimit;Clear limit]"
	.."button[6.8,0;1.2,1;clearall;Clear all]"
	.."button[7.8,0;1.2,1;botsstatus;Status]"
	.."button[8.8,0;1.2,1;freeze;Freeze " .. aliveai.systemfreeze .."]"

	if self then
		local selfnam=self.object:get_luaentity().name .."_spawner"
		if minetest.registered_items[selfnam] then
			gui=gui .. "item_image_button[3.2,-0.2;1,1;".. selfnam ..";imgbut;]"
		end
	end
	if aliveai.terminal_users[name].target and aliveai.terminal_users[name].target:get_luaentity() then
		local ternam=aliveai.terminal_users[name].target:get_luaentity().name .."_spawner"
		if minetest.registered_items[ternam] then
			gui=gui .. "item_image_button[3.2,0.6;1,1;".. ternam .. ";imgbut;]"
		end
	end

--system status
	local delay=math.floor((aliveai.bots_delay2/aliveai.max_delay)*100)/100
	gui=gui .."box[4," ..(3-(delay*2)) .. ";0.5," .. (delay*2) .. ";#" .. aliveai.terminal_status_color(delay) .."]"
	.."label[4,1;System\n" .. (math.floor(delay*100)) .."%]"

	minetest.after(0.1, function(gui,name)
		if aliveai.terminal_users[name] and aliveai.terminal_users[name].status then
			return minetest.show_formspec(name, "aliveai.terminal",gui)
		end
	end, gui,name)
	minetest.after(1, function(name,user)
		if user and aliveai.terminal_users[name] and aliveai.terminal_users[name].live_status and not aliveai.terminal_users[name].bot and aliveai.terminal_users[name].status then
			aliveai.show_terminal(user)
		end
	end, name,user)
end

aliveai.terminal_status_color=function(st)
	local c="00ff00"
	if st>2 then
		c="000000"
	elseif st>1.5 then
		c="ff00ff"
	elseif st>0.9 then
		c="ff0000"
	elseif st>0.66 then
		c="ff6d00"
	elseif st>0.33 then
		c="ffff00"
	end
	return c
end

minetest.register_on_player_receive_fields(function(user, form, pressed)
	if form=="aliveai.terminal" then
		local name=user:get_player_name()

		if not aliveai.terminal_users[name] then
			return
		elseif pressed.quit then
			aliveai.terminal_users[name].status=nil
			return
		end

		if aliveai.gethp(aliveai.terminal_users[name].taget)<0 then
			aliveai.terminal_users[name].taget=nil
		end
		if aliveai.gethp(aliveai.terminal_users[name].bot)<0 then
			aliveai.terminal_users[name].bot=nil
			aliveai.terminal_users[name].botname=""
		end

		if pressed.event then
			local e=pressed.event
			local self=aliveai.terminal_users[name].bot


			if not (self and self:get_luaentity()) then
				aliveai.show_terminal(user)
				return
			end
			self=self:get_luaentity()

			local ob=aliveai.terminal_users[name].target

			if e=="Remove" then
				self.object:remove()
			elseif e=="Die" then
				if self.type=="npc" then
					aliveai.dying(self,2)
				else
					aliveai.die(self)
				end
			elseif e=="Dying" then
				aliveai.dying(self,1)
			elseif e=="Relive" then
				self.dying={step=0,try=self.hp_max*2}
				self.dead=nil
			elseif e=="Sleep" then
				aliveai.sleep(self,2)
			elseif e=="Say" then
				if pressed.text=="" and ob then
					aliveai.rnd_talk_to(self,ob)
				else
					aliveai.say(self,pressed.text)
				end
			elseif e=="setTeam" and pressed.text~="" then
				self.team=pressed.text
			elseif e=="gotoBed" then
				local n=minetest.find_node_near(self.object:get_pos(), self.distance,aliveai.beds)
				if n then
					n.y=n.y+1
					for ob, ob in ipairs(minetest.get_objects_inside_radius(n, 1)) do
						if (aliveai.is_bot(ob) and ob:get_luaentity().sleeping) or ob:is_player() then return end
					end
					local p=aliveai.creatpath(self,self.object:get_pos(),n)
					if p then
						self.path=p
						self.bedpath=n
					end
				end
			elseif e=="Walk" then
				aliveai.walk(self)
			elseif e=="Run" then
				aliveai.walk(self,2)
			elseif e=="Look At" and ob then
				aliveai.lookat(self,ob)
			elseif e=="Fight" and ob then
				if self.temper<5 then
					self.temper=self.temper+1
				end
				self.fight=ob
				aliveai.known(self,ob,"fight")
				aliveai.lookat(self,ob)
			elseif e=="Escape" and ob then
				if self.temper>-5 then
					self.temper=self.temper-0.3
				end
				self.fly=ob
				aliveai.known(self,ob,"fly")
				aliveai.lookat(self,ob)
			elseif e=="Folow" and ob then
				self.folow=ob
			elseif e=="Come" and ob then
				self.come=ob
				self.zeal=10
				aliveai.come(self)
			elseif e=="Walk To" and ob then
				self.folow=ob
				aliveai.lookat(self,ob)
				aliveai.walk(self)
			elseif e=="rndWalk" and ob then
				aliveai.rndwalk(self)
			elseif e=="stop rndWalk" and ob then
				aliveai.rndwalk(self,false)
			elseif e=="Search Help" then
				aliveai.searchhelp(self)
			elseif e=="useTool" then
				aliveai.use(self)
			elseif e=="Creative" then
				if self.creative==0 then
					self.creative=1
				else
					self.creative=0
				end
			elseif e=="Superbuild" then
				if self.superbuild==0 then
					self.superbuild=1
				else
					self.superbuild=0
				end
			elseif e=="Fly" then
				if self.floating==0 then
					aliveai.floating(self,1)
				else
					aliveai.floating(self)
				end
			elseif e=="Build" then
				aliveai.task_build(self)
			elseif e=="exit Mine" then
				aliveai.exit_mine(self)
			elseif e=="Farming" then
				self.home=aliveai.roundpos(self.object:get_pos())
				self.need=nil
				aliveai.task_farming(self)
			elseif e=="setHome" then
				self.home=aliveai.roundpos(self.object:get_pos())
			elseif e=="StayAt Home" then
				aliveai.task_stay_at_home(self)
			elseif e=="rndGoal" then
				aliveai.rndgoal(self)
			elseif e=="NodeHandler" then
				aliveai.node_handler(self)
			elseif e=="Light" then
				aliveai.light(self)
			end
		elseif pressed.teleport then
			if aliveai.terminal_users[name].bot then
				user:set_pos(aliveai.terminal_users[name].bot:get_pos())
			end
		elseif pressed.status then
			if aliveai.terminal_users[name].live_status then
				aliveai.terminal_users[name].live_status=nil
				aliveai.show_terminal(user)
			else
				aliveai.terminal_users[name].live_status=1
			end
		elseif pressed.botsstatus then
			if aliveai.status==true then
				aliveai.status=false
			else
				aliveai.status=true
			end
		elseif pressed.clearlimit then
			if aliveai.terminal_users[name].bot then
				aliveai.max(aliveai.terminal_users[name].bot:get_luaentity())
				aliveai.show_terminal(user)
			end
		elseif pressed.clearall then
			for i,ob in pairs(aliveai.active) do
				if ob then
					ob:remove()
				end
				aliveai.active={}
				aliveai.active_num=0
				aliveai.show_terminal(user)
			end
		elseif pressed.freeze then
			if aliveai.systemfreeze==0 then
				aliveai.systemfreeze=1
				for i,ob in pairs(aliveai.active) do
					if ob:get_luaentity() and ob:get_luaentity().floating==0 then
						ob:set_acceleration({x=0,y=-aliveai.gravity,z =0})
						ob:set_velocity({x=0,y=-5,z =0})
					end
				end
			else
				aliveai.systemfreeze=0
			end
			aliveai.show_terminal(user)
		elseif pressed.bot then
			aliveai.terminal_users[name].botname=pressed.bot
			local bot=aliveai.get_bot_by_name(pressed.bot)
			if aliveai.gethp(bot)>0 then
				bot:get_luaentity().terminal_user=name
				aliveai.terminal_users[name].bot=bot
			end
			aliveai.show_terminal(user)
		elseif pressed.target then
			if aliveai.terminal_users[name].obs then
				for i, v in pairs(aliveai.terminal_users[name].obs) do
					if v.name==pressed.target then
						aliveai.terminal_users[name].target=v.ob
						aliveai.show_terminal(user)
						return
					end
				end
			end
		end
	end
end)



aliveai.generate_house=function(self,v)
	local gen=true
	if self.x and self.y and self.z and not self.aliveai then
		gen=false
	else
		aliveai.showstatus(self,"generate house")
	end
		

--materials
		local build_able=aliveai.random(1,aliveai.get_everything_to_build_chance)==1
		local window=aliveai.windows[aliveai.random(1,#aliveai.windows)]
		local furn_len=#aliveai.furnishings
		local door
		local floor
		local wall
		local pos

-- random materials or from near stuff
		if gen then
			pos=self.object:get_pos()
		else
			pos=self
			self.distance=15
		end
		pos.y=pos.y-1

		local np=minetest.find_node_near(pos, self.distance,aliveai.basics)
		if np then
			local name=minetest.get_node(np).name
			wall=name
			floor=name
		else
			wall=aliveai.basics[math.random(1,#aliveai.basics)]
			floor=aliveai.basics[math.random(1,#aliveai.basics)]
		end
		if aliveai.wood[wall] then
			wall=aliveai.wood[wall]
		end
		if aliveai.wood[floor] then
			floor=aliveai.wood[floor]
		end

		if aliveai.doors_material[floor] and aliveai.doors_material[wall] then
			local r={aliveai.doors_material[floor],aliveai.doors_material[wall]}
			door=r[math.random(1,2)]
		elseif aliveai.doors_material[floor] then
			door=floor
		elseif aliveai.doors_material[wall] then
			door=wall
		else
			local d={}
			for i, v in pairs(aliveai.doors_material) do
				table.insert(d,v)
			end
			door=d[math.random(1,#d)]
			if not door then door="air" end
		end
--check failure 1
	if not (floor and wall) then
		aliveai.showstatus(self,"failed to generate build instructions (step 1)")
		print(self.botname,"Failed to generate build instructions (step 1)")
		return
	end
--generate
	if (v and v==1) or math.random(1,5)>1 then
		aliveai.generate_house_v1(self,build_able,window,furn_len,door,floor,wall,pos,gen)
	else	--if v and v==2 then
		aliveai.generate_house_v2(self,build_able,window,furn_len,door,floor,wall,pos,gen)
	end
--check failure 2
	if not (self.build_x and self.build_y and self.build_z) or  self.house==nil or self.house=="" then
		aliveai.showstatus(self,"Error: failed to generate build instructions (step 2)")
		print(self.botname,"Failed to generate build instructions (step 2)")
		aliveai.kill(self)
		return nil
	end
	return self
end

aliveai.generate_house_v2=function(self,build_able,window,furn_len,door,floor,wall,pos,gen)
-- base
		local rx=math.random(10,25) 
		local ry=math.random(4,5) 
		local rz=math.random(10,25)
		local walls=true
		local dir=1

		if math.floor(rx/2)==rx/2 then rx=rx+1 end
		if math.floor(rz/2)==rz/2 then rz=rz+1 end

		local rxc=rx/2+0.5
		local rzc=rz/2+0.5

		if rx<rz then dir=2 end
-- walls
		if rx<14 or rz<14 then walls=false end
-- stairs
		local stairs={y=1,x=rxc,z=rzc,floor=0,rex=rxc,rez=rzc,step=0}
		local rd1={[1]=-1,[2]=1}
		rd1=rd1[math.random(1,2)]
		if dir==1 then
			stairs.x=stairs.x+rd1
			stairs.rex=stairs.x
		else
			stairs.z=stairs.z+rd1
			stairs.rez=stairs.z
		end
-- doors
		local doors={
			x1=math.floor(rzc*0.5),
			x2=math.floor(rzc*1.5),
			z1=math.floor(rxc*0.5),
			z2=math.floor(rxc*1.5),
		}

		local last=""
		local node=""
		local nodes=""
		local count=0
		local need={}
		local floors=math.random(0,4)
		local y=0

		for f=0,floors,1 do
			if f>0 then
				y=1
				if not gen then self.y=self.y+ry end
			else
				y=0
			end
		for y=y,ry,1 do
		for x=0,rx,1 do
		for z=0,rz,1 do
			node="air"
			if y>1 and ((ry==3 and y<=ry) or (ry>3 and y<ry))				-- windows
			and (((x==0 or x==rx)
			and (z>1 and z<rz-1 and (z<rzc-1 or z>rzc+1)) and (z>=rzc+4 or z<=rzc-4))
			or ((z==0 or z==rz)
			and (x>1 and x<rx-1 and (x<rxc-1 or x>rxc+1)) and (x>=rxc+4 or x<=rxc-4))) then
				node=window
			elseif floors>0 and f<floors and y==stairs.y and x==stairs.x and z==stairs.z then	--stairs
				node=wall
				if dir==1 then
					stairs.z=stairs.z+1
				else
					stairs.x=stairs.x+1
				end
				if y==ry-1 and stairs.floor~=floor then
					stairs.x=stairs.rex
					stairs.z=stairs.rez
					stairs.floor=stairs.floor+1
					stairs.y=stairs.y+1
					stairs.step=0
				elseif y==ry and stairs.step==ry-1 then
					stairs.x=stairs.rex
					stairs.z=stairs.rez
					stairs.y=1
					stairs.step=0
				elseif y==ry and stairs.step<ry-1 then
					node="air"
					stairs.step=stairs.step+1
				elseif y<ry then
					stairs.y=stairs.y+1
				end
			elseif (y==1 or y==2) and (					-- door outside
			(dir==1 and (z==0 or z==rz) and x==rxc) or
			(dir==2 and (x==0 or x==rx) and z==rzc)) then
				if y==1 and f==0 then
					node=door
				elseif y==2 and f==0 then
					node="air"
				else
					node=window
				end
			elseif walls and (y==1 or y==2) and not (x==0 or z==0 or x==rx or z==rz) and ( -- room doors
			(dir==1 and (z==doors.x1 or z==doors.x2) and (x==rxc-2 or x==rxc+2)) or
			(dir==2 and (x==doors.z1 or x==doors.z2) and (z==rzc-2 or z==rzc+2))) then
				if y==1 then node=door end
			elseif (y==0 or y==ry) and x>0 and x<rx and z>0 and z<rz then					-- floors
				node=floor
			elseif (x==0 or z==0 or x==rx or x==rx or z==rz)		-- walls outside
			or (walls and dir==1 and (x==rxc-2 or x==rxc+2))		-- walls inside x
			or (walls and dir==2 and (z==rzc-2 or z==rzc+2))		-- walls inside z
			or (walls and dir==1 and z==rzc and (x<rxc-2 or x>rxc+2))	-- walls inside xc
			or (walls and dir==2 and x==rxc and (z<rzc-2 or z>rzc+2)) then	-- walls inside zc
				node=wall
			elseif y==1 						-- furnishings
			and ((dir==1 and (x<rxc-2 or x>rxc+2) and ((z==1 or z==rzc+1 or z==rzc-1 or z==rz-1) or (x==1 or x==rx-1)))
			or (dir==2 and (z<rzc-2 or z>rzc+2) and ((x==1 or x==rxc+1 or x==rxc-1 or x==rx-1) or (z==1 or z==rz-1)))) then
				local furn_rnd=aliveai.random(1,furn_len*4)
				if furn_rnd<=furn_len then 
					node=aliveai.furnishings[furn_rnd]
				else
					node="air"
				end
			end




			if not gen then
				if node~="" then
					local rpn={x=self.x+x,y=self.y+y,z=self.z+z}
					local def=minetest.registered_nodes[node]
					minetest.set_node(rpn,{name=node})
					if def.on_construct then
						def.on_construct(rpn)
					end
				end
				nodes=""
			end
			if last=="" then last=node end
			if node~="air" then
				if not need[node] then need[node]=0 end
				need[node]=need[node]+1	
			end
			if node~=last then
				nodes=nodes ..last .." " .. count .. "!"
				if build_able and gen then aliveai.invadd(self,last,count,true) end
				count=0
			end
			last=node
			count=count+1
			if y==ry and x==rx and z==rz and last~="a" then
				nodes=nodes ..last .." " .. count .. "!"
				if build_able and gen then aliveai.invadd(self,last,count,true) end
				count=0
			end
		end
		end
		end
		end

		local t=""
		for n, v in pairs(need) do
			t=t .. n.." " ..v .."!"
		end
		nodes=t.."+" .. nodes
	self.house=nodes
	self.build_x=rx
	self.build_y=ry*(floors+1)
	self.build_z=rz
end

aliveai.generate_house_v1=function(self,build_able,window,furn_len,door,floor,wall,pos,gen)
-- basic
		local rx=math.random(5,10) 
		local ry=math.random(3,5) 
		local rz=math.random(5,10)
		local rnd={}
-- door hole
		local doorrnd=math.random(1,2)
		local doorholex,doorholez,doorpx,doorpz,doorp
		if doorrnd==1 then
			rnd[1]=0
			rnd[2]=rx
			doorholez=aliveai.random(1,rz-1)
			doorholex=rnd[math.random(1,2)]
			if doorholex==0 then doorp=1 else doorp=-1 end -- used with furn
		else
			rnd[1]=0
			rnd[2]=rz
			doorholex=aliveai.random(1,rx-1)
			doorholez=rnd[math.random(1,2)]
			if doorholez==0 then doorp=1 else doorp=-1 end -- used with furn
		end
-- stair
		local stairrnd=math.random(1,4)
		if doorrnd==2 and doorholez==0 then
			stairrnd=2
		elseif doorrnd==2 and doorholez==rz then
			stairrnd=1
		end
		rnd[1]=1
		rnd[2]=rz-1
		local stair=2
		local stair2x=2
		local stairy=1
		local stair2z=rnd[stairrnd]
		local stairz=rnd[stairrnd]
-- windows
		local wy=math.random(1,3)
		local wx1=math.random(1,7)
		local wx1s=aliveai.random(1,rx-1)
		local wx2=math.random(1,7)
		local wx2s=aliveai.random(1,rx-1)
		local wz1=math.random(1,7)
		local wz1s=aliveai.random(1,rz-1)
		local wz2=math.random(1,7)
		local wz2s=aliveai.random(1,rz-1)

		local last=""
		local node=""
		local nodes=""
		local count=0
		local need={}
		for y=0,ry,1 do
			for x=0,rx,1 do
				for z=0,rz,1 do
					if ry>3 and x<=y and x==stair2x and z==stair2z and y==ry then			-- hole stair
						node="air"
						stair2x=stair2x+1
					elseif (y==1 or y==2) and z==doorholez and x==doorholex then			-- door hole
						node="air"
						if y==1 then node=door end						-- door
					elseif z==0  and y>1 and wy>1 and y<=wy and y<ry and x>=wx1s and x<=rx-1 then	-- window 1
						node=window
					elseif z==rz  and y>1 and wy>1 and y<=wy and y<ry and x>=wx2s and x<=rx-1 then	-- window 2
						node=window
					elseif x==0  and y>1 and wy>1 and y<=wy and y<ry and z>=wz1s and z<=rz-1 then	-- window 3
						node=window
					elseif x==0  and y>1 and wy>1 and y<=wy and y<ry and z>=wz2s and z<=rz-1 then	-- window 4
						node=window
					elseif x==0 or x==rx or z==0 or z==rz or y==ry then				-- walls
						node=wall
					elseif ry>3 and x==stair and z==stairz and y==stairy then				-- stair
						node=wall
						stair=stair+1
						stairy=stairy+1
					elseif y==0 then								-- floor
						node=floor
					elseif y==1 and (z==1 or z==rz-1 or x==1 or x==rx-1)				 -- furnishings
					and not ((x==doorholex+doorp and z==doorholez) or (z==doorholez+doorp and x==doorholex)) then -- no furnishings front of door holes 
						local furn_rnd=aliveai.random(1,furn_len*4)
						if furn_rnd<=furn_len then 
							node=aliveai.furnishings[furn_rnd]
						else
							node="air"
						end
					else
						node="air"
					end
					if not node then node="" end
					if not gen then
						if node~="" then
							local rpn={x=self.x+x,y=self.y+y,z=self.z+z}
							local def=minetest.registered_nodes[node]
							minetest.set_node(rpn,{name=node})
							if def.on_construct then
								def.on_construct(rpn)
							end
						end
						nodes=""
					end
					if last=="" then last=node end
					if node~="air" then
						if not need[node] then need[node]=0 end
						need[node]=need[node]+1	
					end
					if node~=last then
						nodes=nodes ..last .." " .. count .. "!"
						if build_able and gen then aliveai.invadd(self,last,count,true) end
						count=0
					end
					last=node
					count=count+1
					if y==ry and x==rx and z==rz and last~="a" then
						nodes=nodes ..last .." " .. count .. "!"
						if build_able and gen then aliveai.invadd(self,last,count,true) end
						count=0
					end
				end
			end
		end
		local t=""
		for n, v in pairs(need) do
			t=t .. n.." " ..v .."!"
		end
		nodes=t.."+" .. nodes
	self.house=nodes
	self.build_x=rx
	self.build_y=ry
	self.build_z=rz
end




aliveai.crafttoneed=function(self,a,group_only,neednum)-- needed craft stuff to search or groups
-- search group
	if self.crafting~=1 then return end
	if string.find(a,"group:",1)~=nil then
		local g=a.split(a,":")
		for i, v in pairs(minetest.registered_items) do
 			if minetest.get_item_group(i,g[2])>0 then
				return i
			end
		end
		for i, v in pairs(minetest.registered_nodes) do
 			if minetest.get_item_group(i,g[2])>0 then
				return i
			end
		end
	end
	if group_only then return a end
--  search mineable, it need help to find uncraftable/ find generated stuff.
	if minetest.registered_nodes[a] and minetest.registered_nodes[a].is_ground_content then
		neednum=neednum or 1
		aliveai.newneed(self,a,neednum,a,"node")
		return nil
	end
--search dropable
	local b=a
	if a=="default:steel_ingot"			then a="default:iron_lump" end
	if a=="default:copper_ingot"			then a="default:copper_lump" end
	if a=="default:gold_ingot"			then a="default:gold_lump" end
	if a=="default:mese_crystal_fragement"	then a="default:mese_crystal" end
	for i, v in pairs(minetest.registered_nodes) do
 		if v.drop and type(v.drop)=="string" and v.drop==a and v.is_ground_content then
			aliveai.newneed(self,b,neednum,i,"node")
			return nil
		end
	end
	return a
end

aliveai.showpath=function(pos,i,table)
	if aliveai.status==false or pos==nil or not (table or (pos.x and pos.y and pos.z)) then return end
	local a={"path1","path2","path3"}
	if a[i] and table then
		for _, s in pairs(pos) do
			minetest.add_entity(s, "aliveai:" ..a[i])
		end
		return
	end

	pos={x=aliveai.nan(pos.x),y=aliveai.nan(pos.y),z=aliveai.nan(pos.z)}

	if a[i] and pos and pos.x then minetest.add_entity(pos, "aliveai:" ..a[i]) end
	return
end

aliveai.showstatus=function(self,t,c)
	if self.terminal_user then
		if aliveai.terminal_users[self.terminal_user] and aliveai.terminal_users[self.terminal_user].botname==self.botname then
			if aliveai.terminal_users[self.terminal_user].status then
				local color={"ff0000","0000ff","00ff00","ffff00"}
				aliveai.terminal_users[self.terminal_user].bot_showstatus={color=color[c or 2],msg=t}
			end
		else
			self.terminal_user=nil
		end
	end
	if not aliveai.status then return self end
	local color={"ff0000","0000ff","00ff00","ffff00"}
	c=c or 2
	t=t or ""
	if color[c] and t then
		self.object:set_properties({nametag=t,nametag_color="#" .. color[c]})
		print(self.botname ..": " .. t)
		self.delstatus=math.random(0,50) 
		local del=self.delstatus
		minetest.after(2, function(self,del)
			if self and self.object then
				if self.delstatus==del then
					if self.namecolor=="" then
						self.object:set_properties({nametag="",nametag_color=""})
					else
						self.object:set_properties({nametag=self.botname,nametag_color="#" .. self.namecolor})
					end
				end
			end
		end, self,del)
	end
	return self
end

aliveai.form=function(name,text)
	if not text then
		local gui=""
		.."size[3.5,0.2]"
		.."field[0,0;3,1;size;;]"
		.."button_exit[2.5,-0.3;1.3,1;set;set]"
		minetest.after((0.1), function(gui)
			return minetest.show_formspec(name, "aliveai.buildxy",gui)
		end, gui)
	else
		local gui=""
		.."size[5,7]"
		.."tooltip[text;Copy the data (CTRL+A, CTRL+C)\nDo not change the code, its exactly calculated]"
		.."textarea[0.2,0.2;5,8;text;;" .. text .."]"
		minetest.after((0.1), function(gui)
			return minetest.show_formspec(name, "aliveai.buildxyX",gui)
		end, gui)
	end
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="aliveai.buildxy" and pressed.set then
		local name=player:get_player_name()
		local t=pressed.size
		local t1=t.split(t," ")
		if not (t1 and t1[2] and t1[3]) then
			minetest.chat_send_player(name, "set area size: <x> <y> <z>")
			return false
		end
		local x=tonumber(t1[1])
		local y=tonumber(t1[2])
		local z=tonumber(t1[3])
		if not (x and y and z) then
			minetest.chat_send_player(name, "set area size: <x> <y> <z>")
			return false
		end
		aliveai.buildingtool={x=x,y=y,z=z}
		minetest.chat_send_player(name, "area size set, now place the tool")
		return true
	end
	if form=="aliveai.spawnerform" then
		local pos=aliveai.spawneruser[player:get_player_name()]
		local meta=minetest.get_meta(pos)
		if pressed.quit then
			if pressed.n then
				local n=tonumber(pressed.n)
				if n==nil then n=1 end
				meta:set_int("n",n)
			end
			if pressed.team then
				meta:set_string("team",pressed.team)
			end
			if pressed.color then
				meta:set_string("color",pressed.color)
			end
			if pressed.time then
				local t=tonumber(pressed.time)
				if t==nil or t<2 then t=2 end
				if t>999 then t=999 end
				meta:set_int("t",t)
			end

			if aliveai.mesecons and meta:get_int("mese")==3 then
				minetest.get_node_timer(pos):stop()
			else
				minetest.get_node_timer(pos):start(meta:get_int("t"))
			end
			aliveai.spawneruser[player:get_player_name()]=nil
		else
		if pressed.bot then
			meta:set_string("bot",pressed.bot)
			meta:set_string("infotext", "Spawner by " ..meta:get_string("owner") .. " (".. pressed.bot ..")")
		end
		if pressed.mese then
			local n=1
			if pressed.mese=="send_on_spawn" then n=2
			elseif pressed.mese=="spawn_on_send" then n=3
			elseif pressed.mese=="send_on_reach_number" then n=4
			elseif pressed.mese=="send_on_reach_no_spawn" then n=5
			end
			meta:set_string("mese",n)
		end
			aliveai.spawnerform(player,pos)
		end
	end
end)

aliveai.spawnerform=function(player,pos)
	local meta=minetest.get_meta(pos)
	local n=meta:get_int("n")
	local bot=meta:get_string("bot")
	local time=meta:get_string("t")
	local team=meta:get_string("team")
	local color=meta:get_string("color")

	if not aliveai.spawneruser then aliveai.spawneruser={} end
	aliveai.spawneruser[player:get_player_name()]=pos

	local gui=""
	local nn=1
	local nn_n=0
	local list="random_npc"
	local c=""

	local but="item_image_button[2.7,0.5;1,1;;show;]"
		if bot=="" then
			bot=""
			n=1
		elseif bot=="random_npc" then
			nn_n=1
		end
	for i, v in pairs(aliveai.registered_bots) do
		nn=nn+1
		list=list .. "," .. v.bot
		if v.bot==bot then
			nn_n=nn
			but="item_image_button[2.7,0.5;1,1;".. v.item ..";imgbut;]"
		end
	end

	gui=""
	.."size[3.5,2.5]"
	.."tooltip[n;Spawn when there are less bots then...]"
	.."field[0,0;1.5,1;n;;" .. n .."]"
	.."tooltip[time;Timer]"
	.."field[1.5,0;1.5,1;time;;" .. time .."]"
	.."dropdown[-0.2,0.5;3,1;bot;" .. list.. ";" .. nn_n .."]"
	.. but
	.."button_exit[2.5,-0.3;1.3,1;set;Set]"
	.."tooltip[team;Team: set team name, or leave empty for default teams]"
	.."field[0,1.5;1.5,1;team;;" .. team .."]"
	.."tooltip[color;Nametag color (e.g c50032) (RedGreenBlue (RRGGBB)]"
	.."field[1.5,1.5;1.5,1;color;;" .. color .."]"
	if aliveai.mesecons then
		local mese=meta:get_int("mese")
		gui=gui .."dropdown[-0.2,2;4,1;mese;Mesecons...,send_on_spawn,spawn_on_send,send_on_reach_number,send_on_reach_no_spawn;" .. mese .."]"
	end
	minetest.after((0.1), function(gui)
		return minetest.show_formspec(player:get_player_name(), "aliveai.spawnerform",gui)
	end, gui)
end

minetest.register_node("aliveai:spawner", {
	description = "aliveai spawner",
	tiles = {"default_steel_block.png"},
	groups = {cracky = 2},
	drawtype="nodebox",
	paramtype="light",
	walkable=false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
		}
	},
	can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			return true
		end
	end,
	mesecons = {receptor = {state = "off"}},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name=placer:get_player_name() or ""
		meta:set_string("owner",name)
		meta:set_string("team",aliveai.default_team)
		meta:set_string("color","ffffff")
		meta:set_string("infotext", "Spawner by " .. name)
		local meta=minetest.get_meta(pos)
		meta:set_int("n",1)
		meta:set_string("bot",1)
		meta:set_int("mese",1)
		meta:set_int("reach",0)
		meta:set_int("t",120)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local n=meta:get_int("n")
		local bot=meta:get_string("bot")
		local mese=meta:get_int("mese")
		local team=meta:get_string("team")
		local color=meta:get_string("color")
		if bot=="random_npc" then
			local a=true
			local y=0
			for i, v in pairs(aliveai.registered_bots) do
			if v.type=="npc" and (a or math.random(1,4)==1) then
					bot=v.bot
					y=v.spawn_y
					a=false
				end
			end
			pos.y=pos.y+y
		end
		if not aliveai.registered_bots[bot] then minetest.get_node_timer(pos):stop() return false end
		if n>aliveai.active_num then
			meta:set_int("reach",0) 
			if aliveai.mesecons and mese==5 then return true end
			local b=minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z}, bot)
			b:set_yaw(math.random(0,6.28))
			if team~="" then b:get_luaentity().team=meta:get_string("team") end
			b:set_properties({nametag=b:get_luaentity().botname,nametag_color="#" ..  color})
			b:get_luaentity().namecolor=color
			if aliveai.mesecons and mese==2 then mesecon.receptor_on(pos) end
		elseif aliveai.mesecons and mese==4 and meta:get_int("reach")==0 then
			meta:set_int("reach",1)
			mesecon.receptor_on(pos)
		end
		if aliveai.mesecons then
			minetest.after(1.5, function(pos)
				mesecon.receptor_off(pos)
			end, pos)
		end
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		if meta:get_string("owner")==name or minetest.check_player_privs(name, {protection_bypass=true}) then
			aliveai.spawnerform(player,pos)
		end
	end,
	mesecons = {
		receptor = {state = "off"},
		effector = {
		action_on = function (pos, node)
			local meta=minetest.get_meta(pos)
			local mese=meta:get_int("mese")
			local bot=meta:get_string("bot")
			local n=meta:get_int("n")
			local team=meta:get_string("team")
			local color=meta:get_string("color")
			if bot=="random_npc" then
				local a=true
				local y=0
				for i, v in pairs(aliveai.registered_bots) do
				if v.type=="npc" and (a or math.random(1,4)==1) then
						bot=v.bot
						y=v.spawn_y
						a=false
					end
				end
				pos.y=pos.y+y
			end
			if aliveai.registered_bots[bot] and n>aliveai.active_num and mese==3 then
				local b=minetest.add_entity({x=pos.x,y=pos.y+1,z=pos.z}, bot)
				b:set_yaw(math.random(0,6.28))
				if team~="" then b:get_luaentity().team=meta:get_string("team") end
				b:set_properties({nametag=b:get_luaentity().botname,nametag_color="#" ..  color})
				b:get_luaentity().namecolor=color
			end
			return false
		end,
	}}
})


minetest.register_craftitem("aliveai:hypnotics", {
	description = "Slept a bot",
	inventory_image = "aliveai_slept.png",
})


minetest.register_craftitem("aliveai:relive", {
	description = "Relive, give to a laying bot or punch",
	inventory_image = "aliveai_relive.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		damage_groups = {fleshy=10},
	},
})

minetest.register_craftitem("aliveai:team_gift", {
	description = "Gift to team (punch a teammember to be changed to their team)",
	inventory_image = "aliveai_team_gift.png",
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="object" then
			local t=aliveai.team(pointed_thing.ref)
			aliveai.team(user,t)
			if aliveai.is_bot(pointed_thing.ref) then
				local name=user:get_player_name()
				local self=pointed_thing.ref:get_luaentity()
				if aliveai.getknown(self,user)=="fight" then
					self.temper=0
					self.fight=nil
					aliveai.known(self,user,"")
				end
			end
			itemstack:take_item()
			return itemstack
		end
	end,
})

minetest.register_tool("aliveai:cudgel", {
	description = "Wooden cudgel",
	inventory_image = "default_stick.png^[colorize:#513204ff",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.3}, uses=105, maxlevel=0},
			cracky = {times={[3]=20}, uses=2, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	groups = {flammable = 2,stick=1},
	sound = {breaks = "default_tool_breaks"},
})

minetest.register_node("aliveai:bed", {
	description = "Bed",
	stack_max=1,
	tiles = {"aliveai_bed.png","default_wood.png","default_wood.png^aliveai_bed_side.png"},
	groups = { choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	drawtype="nodebox",
	paramtype="light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
		}
	},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1)
		meta:set_int("n",20)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		if meta:get_int("placed")==1 then
			meta:set_int("n",0)
			return
		end
		local n=meta:get_int("n")
		meta:set_int("n",n-1)
		local name=minetest.get_node(pos).name
		if aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(1)})
		elseif aliveai.def({x=pos.x-1,y=pos.y,z=pos.z},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(-1)})
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(0,1)})
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(0,-1)})
		else
			minetest.set_node(pos, {name = "air"})
			minetest.add_item(pos, name)
		end
		if n<1 then
			meta:set_int("n",0)
			return
		end
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if beds and beds.on_rightclick then beds.on_rightclick(pos, player) end
	end,
	after_place_node = function(pos, placer)
		local p=minetest.get_node(pos).param2
		if p==1 and aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"walkable") then
			return 0
		elseif p==3 and aliveai.def({x=pos.x-1,y=pos.y,z=pos.z},"walkable") then
			return 0
		elseif p==0 and aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"walkable") then
			return 0
		elseif p==2 and aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"walkable") then
			return 0
		end
		minetest.get_meta(pos):set_int("placed",1)
	end,
})

minetest.register_node("aliveai:bed_blue", {
	description = "Blue bed",
	stack_max=1,
	tiles = {"aliveai_bed_blue.png","default_wood.png","default_wood.png^aliveai_bed_side_blue.png"},
	groups = { choppy = 2, oddly_breakable_by_hand = 1, flammable = 1},
	drawtype="nodebox",
	paramtype="light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
		}
	},
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1)
		meta:set_int("n",20)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		if meta:get_int("placed")==1 then
			meta:set_int("n",0)
			return
		end
		local n=meta:get_int("n")
		meta:set_int("n",n-1)
		local name=minetest.get_node(pos).name
		if aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(1)})
		elseif aliveai.def({x=pos.x-1,y=pos.y,z=pos.z},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(-1)})
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(0,1)})
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"buildable_to") then
			minetest.swap_node(pos, {name = name, param2=aliveai.xz_to_param2yaw(0,-1)})
		else
			minetest.set_node(pos, {name = "air"})
			minetest.add_item(pos, name)
		end
		if n<1 then
			meta:set_int("n",0)
			return
		end
		return true
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if beds and beds.on_rightclick then beds.on_rightclick(pos, player) end
	end,
	after_place_node = function(pos, placer)
		local p=minetest.get_node(pos).param2
		if p==1 and aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"walkable") then
			return 0
		elseif p==3 and aliveai.def({x=pos.x-1,y=pos.y,z=pos.z},"walkable") then
			return 0
		elseif p==0 and aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"walkable") then
			return 0
		elseif p==2 and aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"walkable") then
			return 0
		end
		minetest.get_meta(pos):set_int("placed",1)
	end,
})

minetest.register_node("aliveai:chair",{
	description = "Chair",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 1},
	drawtype="nodebox",
	paramtype="light",
	paramtype2 = "facedir",
	tiles = {"default_wood.png"},
	paramtype = "light",
	selection_box={
		type="fixed",
		fixed={-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125}
	},
	collision_box={
		type="fixed",
		fixed={
			{-0.3125, -0.5, -0.3125, 0.3125, -0.0625, 0.3125},
			{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125}
		}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
			{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
			{0.1875, -0.5, -0.3125, 0.3125, -0.0625, -0.1875},
			{-0.3125, -0.5, -0.3125, -0.1875, -0.0625, -0.1875},
			{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.3125},
			{-0.1875, 0.3125, 0.1875, 0.1875, 0.4375, 0.3125},
			{-0.3125, 0.125, 0.1875, 0.3125, 0.1875, 0.3125},
			{0.23, -0.4375, -0.3125, 0.29, -0.375, 0.3125},
			{-0.29, -0.4375, -0.3125, -0.23, -0.375, 0.3125},
			{-0.29, -0.4375, -0.0315, 0.29, -0.375, 0.031},
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local v=player:get_player_velocity()
		if v.x~=0 or v.y~=0 or v.z~=0 then return end
		player:set_pos({x=pos.x,y=pos.y,z=pos.z})
		local name=player:get_player_name()
		local nname=minetest.get_node(pos).name
		if default.player_attached[name] then
			player:set_physics_override(1, 1, 1)
			minetest.after(0.3, function(player,name)
				player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				default.player_attached[name]=false
				default.player_set_animation(player, "stand",30)
			end,player,name)
		else
			player:set_physics_override(0, 0, 0)
			minetest.after(0.3, function(player,name)
				player:set_eye_offset({x=0,y=-7,z=2}, {x=0,y=0,z=0})
				default.player_attached[name]=true
				default.player_set_animation(player, "sit",30)
			end,player,name)
			minetest.after(0.3, function(player,name)
				player:set_eye_offset({x=0,y=-7,z=2}, {x=0,y=0,z=0})
				default.player_attached[name]=true
				default.player_set_animation(player, "sit",30)
			end,player,name)
		end
	end,
	can_dig = function(pos, player)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1)) do
			return false
		end
		return true
	end,
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		minetest.get_node_timer(pos):start(1)
		meta:set_int("n",20)
		meta:set_int("y",0)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		if meta:get_int("placed")==1 then
			meta:set_int("n",0)
			return
		end
		local n=meta:get_int("n")
		meta:set_int("n",n-1)
		if aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"buildable_to") then
			local p,d=aliveai.xz_to_param2yaw(-1)
			minetest.swap_node(pos, {name = "aliveai:chair", param2=p})
			meta:set_int("y",d)
		elseif aliveai.def({x=pos.x-1,y=pos.y,z=pos.z},"buildable_to") then
			local p,d=aliveai.xz_to_param2yaw(1)
			minetest.swap_node(pos, {name = "aliveai:chair", param2=p})
			meta:set_int("y",d)
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"buildable_to") then
			local p,d=aliveai.xz_to_param2yaw(0,-1)
			minetest.swap_node(pos, {name = "aliveai:chair", param2=p})
			meta:set_int("y",d)
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"buildable_to") then
			local p,d=aliveai.xz_to_param2yaw(0,1)
			minetest.swap_node(pos, {name = "aliveai:chair", param2=p})
			meta:set_int("y",d)
		end
		if n<1 then
			meta:set_int("n",0)
			return
		end
		return true
	end,
	on_blast=function(pos)
		for _, player in ipairs(minetest.get_objects_inside_radius(pos,1)) do
			if player:is_player() then
			local name=player:get_player_name()
			player:set_physics_override(1, 1, 1)
			minetest.after(0.3, function(player,name)
				player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
				default.player_attached[name]=false
				default.player_set_animation(player, "stand",30)
			end,player,name)
			end
		end
	end,
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_int("placed",1)
	end
})

aliveai.open_door=function(self,pos)
	if (self.openddoor and aliveai.samepos(self.openddoor,aliveai.roundpos(pos)) )or not pos or aliveai.group(pos,"aliveai_door")==0 then return end
	local p=minetest.get_node(pos).param2
	local bot=self.object:get_pos()
	if ((p==0 or p==2) and (bot.x<pos.x or bot.x>pos.x))
	or ((p==1 or p==3) and (bot.z<pos.z or bot.z>pos.z)) 
	or aliveai.samepos(aliveai.roundpos(bot),aliveai.roundpos({x=pos.x,y=pos.y+1,z=pos.z})) then	
		minetest.registered_nodes[minetest.get_node(pos).name].on_rightclick(pos)
		self.openddoor=aliveai.roundpos(pos)
		minetest.after(1.5, function(self)
			if self and self.object and aliveai.def(self.openddoor,"walkable") then
				minetest.registered_nodes[minetest.get_node(self.openddoor).name].on_rightclick(self.openddoor)
				self.openddoor=nil
			end
		end,self)
		return self
	end
end


aliveai.make_door=function(def)
minetest.register_node("aliveai:door_" .. def.name,{
	description = def.description,
	groups = {choppy = 2, oddly_breakable_by_hand = 2,aliveai_door=1},
	drawtype="nodebox",
	paramtype="light",
	paramtype2 = "facedir",
	tiles = {def.texture},
	paramtype = "light",
	selection_box={
		type="fixed",
		fixed={-0.5, -0.5, 0.375, 0.5, 1.5, 0.5}
	},
	collision_box={
		type="fixed",
		fixed={-0.5, -0.5, 0.375, 0.5, 1.5, 0.5}
	},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.375, 0.5, -0.4, 0.5},
			{-0.5, 1.4, 0.375, 0.5, 1.5, 0.5},
			{0.375, -0.4, 0.375, 0.5, 1.4, 0.5},
			{-0.5, -0.5, 0.375, -0.4, 1.4, 0.5},
			{-0.5, -0.5, 0.4, 0.5, 1.4, 0.475},
		}
	},
	on_rightclick = function(pos)
		local pp=minetest.get_node(pos).param2
		local n=minetest.get_node(pos).name
		local meta=minetest.get_meta(pos)
		if meta:get_int("locked")==1 then return end
		local p=meta:get_int("p")
		if pp==2 and p==2 then
			minetest.swap_node(pos, {name=n, param2=3})
			minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==3 and p==2 then
			minetest.swap_node(pos, {name=n, param2=2})
			minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==0 and p==0 then
			minetest.swap_node(pos, {name=n, param2=1})
			minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==1 and p==0 then
			minetest.swap_node(pos, {name=n, param2=0})
			minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})	
		elseif pp==3 and p==3 then
			minetest.swap_node(pos, {name=n, param2=0})
			minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==0 and p==3 then
			minetest.swap_node(pos, {name=n, param2=3})
			minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==1 and p==1 then
			minetest.swap_node(pos, {name=n, param2=2})
			minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
		elseif pp==2 and p==1 then
			minetest.swap_node(pos, {name=n, param2=1})
			minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
		else
			meta:set_int("autoopen",1)
			minetest.get_node_timer(pos):start(0.2)
		end
	end,
	on_construct=function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_int("p",minetest.get_node(pos).param2)
		minetest.get_node_timer(pos):start(1)
		meta:set_int("n",1)
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local n=meta:get_int("n")
		meta:set_int("n",n-1)
		local na=minetest.get_node(pos).name
		local rd={x={0,2},z={1,3}}
		local x=rd.x[math.random(1,2)]
		local z=rd.z[math.random(1,2)]
		if aliveai.def({x=pos.x+1,y=pos.y,z=pos.z},"walkable") or aliveai.def({x=pos.x-1,y=pos.y,z=pos.z,"walkable"}) then
			meta:set_int("p",rd.x[math.random(1,2)])
			minetest.swap_node(pos, {name = na, param2=x})
			n=0
		elseif aliveai.def({x=pos.x,y=pos.y,z=pos.z+1},"walkable") or aliveai.def({x=pos.x,y=pos.y,z=pos.z-1},"walkable") then
			meta:set_int("p",rd.z[math.random(1,2)])
			minetest.swap_node(pos, {name = na, param2=z})
			n=0
		end
		if n<1 then
			if meta:get_int("autoopen")==1 then
				minetest.registered_nodes[minetest.get_node(pos).name].on_rightclick(pos)
			end
			return
		end
		return true
	end,
	after_place_node = function(pos, placer)
		minetest.get_node_timer(pos):stop()
	end,
	mesecons = {
		receptor = {state = "off"},
		effector = {
		action_on = function (pos, node)
			minetest.get_meta(pos):set_int("locked",1)
		end,
		action_off = function (pos, node)
			minetest.get_meta(pos):set_int("locked",0)
		end,
	}}
})
	minetest.register_craft({
		output = "aliveai:door_" .. def.name,
		recipe = def.craft
	})
	table.insert(aliveai.doors,"aliveai:door_" .. def.name)
	aliveai.doors_material[def.material]="aliveai:door_" .. def.name
end


local paths={
{0.2,"bubble.png^[colorize:#0000ffff"},
{0.2,"bubble.png^[colorize:#ffff00ff"},
{0.5,"bubble.png^[colorize:#00ff00ff"}}

for i=1,3,1 do
minetest.register_entity("aliveai:path" .. i,{
	hp_max = 1,
	physical = false,
	weight = 0,
	collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	visual = "sprite",
	visual_size = {x=paths[i][1], y=paths[i][1]},
	textures = {paths[i][2]}, 
	colors = {}, 
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	is_falling=0,
	on_step = function(self, dtime)
		if aliveai.systemfreeze==1 then return end
		self.timer=self.timer+dtime
		if self.timer<0.1 then return self end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>2 then
			self.object:remove()
			return self
		end
	end,
	timer=0,
	timer2=0,
	type="",
})
end
paths=nil

minetest.register_node("aliveai:protector", {
	description = "aliveai protector",
	tiles = {"aliveai_protectortest.png"},
	groups = {cracky = 3,oddly_breakable_by_hand = 3},
	drawtype="nodebox",
	paramtype="light",
	walkable=false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1, -0.5, -0.1, 0.1, -0.1, 0.1},
		}
	},
	can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local name=player:get_player_name() or ""
		local owner=meta:get_string("owner")
		return owner=="" or owner==name or minetest.check_player_privs(name, {protection_bypass=true})
	end,
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local name=placer:get_player_name() or ""
		meta:set_string("owner",name)
		minetest.get_node_timer(pos):start(0.5)
		aliveai.protect(pos,{range=15})
		minetest.add_entity(pos, "aliveai:protectortest"):set_properties({visual_size = {x=30,y=30}})
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		minetest.add_entity(pos, "aliveai:protectortest"):set_properties({visual_size = {x=30,y=30}})
	end,
	after_destruct = function(pos, oldnode)
		aliveai.unprotect(pos,{range=15})
	end,
	on_timer = function (pos, elapsed)
		local meta=minetest.get_meta(pos)
		local t=meta:get_int("time")
		local t=t+1
		if t>=20 then
			t=0
			aliveai.protect(pos,{range=15})
		end
		meta:set_int("time",t)
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 15)) do
			if aliveai.is_bot(ob) then
				local pos2=ob:get_pos()
				local d=math.max(1,vector.distance(pos,pos2))
				local r=(8/d)*2
				ob:set_velocity({x=(pos2.x-pos.x)*r, y=(pos2.y-pos.y+0.1)*r, z=(pos2.z-pos.z)*r})
			end
		end
		return true
	end,
})

minetest.register_node("aliveai:protecttortestbox", {
	wield_scale = {x=.7, y=.7, z=.7},
	tiles = {"aliveai_protectortest.png"},
	paramtype = "light",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5, 0.5},
			{-0.5, 0.5, -0.5, 0.5, 0.5, 0.5}, 
			{-0.5, -0.5, -0.5, -0.5, 0.5, 0.5},
			{0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.5, -0.5},
		}
	}


})

minetest.register_entity("aliveai:protectortest",{
	hp_max = 1,
	physical=false,
	pointable=false,
	visual = "wielditem",
	visual_size = {x=1,y=1},
	textures ={"aliveai:protecttortestbox"},
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<5 then return self end
		self.object:remove()
	end,
	time=0,
})

