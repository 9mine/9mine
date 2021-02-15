aliveai.is_invisiable=function(ob)
	if ob:is_player() and minetest.check_player_privs(ob:get_player_name(), {aliveai_invisibility=true}) and ob:get_player_control().sneak then
		return true
	end
	return false
end

aliveai.newpos=function(pos,a)
	if not pos then
		return
	elseif pos.object then
		pos=pos.object:get_pos()
	elseif pos:get_pos() then
		pos=pos:get_pos()
	end
	if a and type(a)~="table" then
		return pos
	elseif a then
		return {x=pos.x+(a.x or 0),y=pos.y+(a.y or 0),z=pos.z+(a.z or 0)}
	end
	return {
	x=pos.x,
	z=pos.z,
	y=pos.y,
	xx=function(p,n) return {x=p.x+(n or 0),y=p.y,z=p.z} end,
	yy=function(p,n) return {x=p.x,y=p.y+(n or 0),z=p.z} end,
	zz=function(p,n) return {x=p.x,y=p.y,z=p.z+(n or 0)} end,
	}
end

minetest.register_on_item_eat=function(hp_change, replace_with_item, itemstack, user, pointed_thing)
	if not itemstack then
		return
	end
	local a=itemstack:get_name()
	if not aliveai.food[a] and hp_change>0 and minetest.get_item_group(a,"aliveai_eatable")==0 then
		aliveai.food[a]=hp_change
		aliveai.save("food",aliveai.food)
		local def=minetest.registered_items[a]
		def.groups=def.groups or {}
		def.groups.aliveai_eatable=hp_change
		minetest.override_item(a, def)
	end
	
end

minetest.after(0, function()
	local f=aliveai.load("food")
	if f then
		aliveai.food=f
		for i, v in pairs(aliveai.food) do
			local def=minetest.registered_items[i]
			if def then
				def.groups=def.groups or {}
				def.groups.aliveai_eatable=v
				minetest.override_item(i, def)
			end
		end
	else
		aliveai.save("food",aliveai.food)
	end

	aliveai.respawn_player_point=aliveai.strpos(minetest.settings:get("static_spawnpoint"),1)
	if not aliveai.respawn_player_point or aliveai.respawn_player_point=="" then
		aliveai.respawn_player_point=nil
		minetest.register_on_leaveplayer(function(player)
			if not aliveai.replayerpos then return end
			aliveai.replayerpos[player:get_player_name()]=nil
		end)
		minetest.register_on_respawnplayer(function(player)
			if not aliveai.replayerpos then aliveai.replayerpos={} end
			minetest.after(0, function(player)
			aliveai.replayerpos[player:get_player_name()]=player:get_pos()
			end, player)
		end)
		minetest.register_on_joinplayer(function(player)
			if not aliveai.replayerpos then aliveai.replayerpos={} end
			aliveai.replayerpos[player:get_player_name()]=player:get_pos()
		end)
	end

end)

aliveai.respawn_player=function(ob)
	if ob:is_player() then
		local n=ob:get_player_name()
		if beds and beds.spawn and beds.spawn[n] then
			ob:set_pos(beds.spawn[n])
			ob:set_hp(20)
		elseif aliveai.respawn_player_point then
			ob:set_pos(aliveai.respawn_player_point)
			ob:set_hp(20)
		elseif aliveai.replayerpos and aliveai.replayerpos[n] then
			ob:set_pos(aliveai.replayerpos[n])
			ob:set_hp(20)
		else
			ob:set_pos({x=0,y=-100,z=0})
			ob:set_hp(0)
		end
	elseif ob:get_luaentity() then
		ob:remove()
	end
end

aliveai.protected=function(pos,name)
	if not (pos and pos.x) then return true end
	name=name or ""
	if type(name)=="string" then
	elseif type(name)=="table" and name.aliveai then
		name=name.botname or ""
	else
		return true
	end
	local m=minetest.get_meta(pos):get_string("aliveai_protected")
	return m~=""  and m~=name
end

aliveai.protect=function(pos,a)
	a.name=a.name or "?"
	a.range=a.range or 15
	for i, p in pairs(aliveai.get_nodes(pos,a.range,1,{})) do
		local m=minetest.get_meta(p)
		m:set_string("aliveai_protected",a.name)
	end
end

aliveai.unprotect=function(pos,a)
	a.name=a.name or ""
	a.range=a.range or 15
	for i, p in pairs(aliveai.get_nodes(pos,a.range,1,{})) do
		local m=minetest.get_meta(p)
		m:set_string("aliveai_protected","")
	end
end

aliveai.nan=function(a)
	return (a == math.huge or a == -math.huge or a ~= a) == false and a or 0
end

aliveai.group=function(pos,g)
	if not (pos and g) then return 0 end
	return minetest.get_item_group(minetest.get_node(pos).name,g)
end

aliveai.param2_to_xzyaw=function(a)
	if a and a.x and a.y and a.z then
		a=minetest.get_node(a).param2
	elseif tonumber(a)==nil then
		return 0
	end
	if a==3 then
		return {x=1,y=0,z=0}, 4.71
	elseif a==1 then
		return {x=-1,y=0,z=0}, 1.57
	elseif a==2 then
		return {x=0,y=0,z=1}, 0
	else -- a==0
		return {x=0,y=0,z=-1}, 3.14
	end
end

aliveai.xz_to_param2yaw=function(x,z)
	if x and x==-1 then
		return 3, 1.57
	elseif x and x==1 then
		return 1, 4.71
	elseif z and z==-1 then
		return 2, 3.14
	else -- z==1
		return 0, 0
	end
end

aliveai.def=function(pos,n)
	if not (pos and pos.x and pos.y and pos.z and n and minetest.registered_nodes[minetest.get_node(pos).name]) then return nil end
	return minetest.registered_nodes[minetest.get_node(pos).name][n]
end

aliveai.defnode=function(name,n)
	if minetest.registered_nodes[name] and minetest.registered_nodes[name][n] then
		return minetest.registered_nodes[name][n]
	end
end

aliveai.floating=function(self,f)
	if f and f==true then
		f=1
	 end
	if f==1 then
		local v=self.object:get_velocity()
		local y=0
		if v.y<0 then y=v.y/10 end
		self.floating=1
		self.object:set_acceleration({x=0,y=0,z =0})
		self.object:set_velocity({x=v.x,y=y,z=v.z})
		self.path=nil
	else
		self.floating=0
		self.object:set_acceleration({x=0,y=-aliveai.gravity,z =0})
		self.object:set_velocity({x=0,y=-5,z =0})
	end
	return self
end

aliveai.die=function(self)
	self.hp=0
	self.object:set_hp(0)
	aliveai.punch(self,self.object,self.hp_max)
	return self
end


aliveai.kill=function(self)
	self.destroy=1
	self.hp=0
	self.object:set_hp(0)
	self.on_step=nil
	aliveai.punch(self,self.object,9000)
	return self
end

aliveai.team_load=function()
	local t=aliveai.load("team_player")
	if not t then return end
	for i, v in pairs(t) do
		aliveai.team_player[i]=v 
	end
end

aliveai.team=function(ob,change_team)
	if type(ob)~="userdata" then return "" end
	if change_team and type(change_team)~="string" then return "" end
	if ob:is_player() then
		local name=ob:get_player_name()
		if change_team then
			aliveai.team_player[name]=change_team
			aliveai.save("team_player",aliveai.team_player)
			minetest.chat_send_player(name, "You are now a member of team " .. change_team)
			return
		end
		local t=aliveai.team_player[name]
		if not t then t=aliveai.default_team end
		return t
	end

	local en=ob:get_luaentity()

	if en and change_team then
		en.team=change_team
	elseif aliveai.is_bot(ob) then
		return en.team
	elseif en and en.team then
		return en.team
	elseif en and en.type then
		return en.type
	elseif en and not en.type then
		return ""
	end
	return
end

aliveai.add_mine=function(self,nodes,num,need)
	num=num or 1
	if not self.mine then
		self.mine={target={},status="search"}
		self.ignoremineitem=""
		self.ignoreminetime=0
		self.ignoreminechange=0
		self.ignoreminetimer=200
		self.taskstep=0
		aliveai.rndwalk(self,false)
	end
	local search1
	if type(need)=="string" then
		search1=need
	end
	for i, v in pairs(nodes) do
		local search2
		if minetest.registered_nodes[v] then search2=v end
		if search1 then
			search2=search1
		elseif need and need[i] then
			search2=need[i]
		end
		aliveai.newneed(self,search2,num,v)
	end
	
end

aliveai.exit_mine=function(self)
	self.mine=nil
	self.need=nil
	self.ignoremineitem=nil
	self.ignoreminetime=nil
	self.ignoreminechange=nil
	self.ignoreminetimer=nil
	self.taskstep=0
	aliveai.rndwalk(self)
	self.done=""
end

aliveai.random=function(a,b)
	if type(b)~="number" or type(a)~="number" then
		a=0
		b=1
	end
	if a>=b then b=a+0.1 end
	return math.random(a,b)
end

aliveai.is_bot=function(ob)
	return (ob and ob:get_luaentity() and ob:get_luaentity().botname and ob:get_luaentity().aliveai)
end

aliveai.get_bot_name=function(ob)
	if not (ob and ob:get_luaentity() and ob:get_luaentity().aliveai) then return "" end
	return ob:get_luaentity().botname
end

aliveai.same_bot=function(self,ob)
	if not (ob and ob:get_luaentity() and ob:get_luaentity().aliveai) then return false end
	return ob:get_luaentity().botname==self.botname
end

aliveai.get_bot_by_name=function(name)
	for i,v in pairs(aliveai.active) do
		if v:get_luaentity() and v:get_luaentity().botname==name then
			return v
		end
	end
	return nil
end

aliveai.lookaround=function(self)
	if not self.isrnd then return end
	if self.attention_path then
		aliveai.path(self)
		if self.done=="path" or (math.random(1,5)==1 and aliveai.distance(self,self.attention_path)<self.arm and aliveai.visiable(self,self.attention_path)) then
			aliveai.exitpath(self)
			if self.attention_pathkind==3 then
				aliveai.lookat(self,self.attention_path)
				aliveai.dig(self,self.attention_path)
			end
			self.attention_pathkind=nil
			self.attention_path=nil
		end
		return self
	end
	if math.random(1,10)==1 then
		aliveai.showstatus(self,"look around",1)
		aliveai.stand(self)
		local nodes=aliveai.get_nodes(self,5,2)
		for _, nodepos in ipairs(nodes) do
			if nodepos and aliveai.visiable(self,nodepos) and aliveai.viewfield(self,nodepos) then
				local n=minetest.get_node(nodepos).name
				if self.attention_nodes[n] then
					if self.attention_nodes[n]==1 and math.random(1,5)==1 then
						aliveai.lookat(self,nodepos)
					elseif self.attention_nodes[n]>1 and (self.attention_nodes[n]==3 or math.random(1,3)==1) then
						local upos={x=nodepos.x,y=nodepos.y+1,z=nodepos.z}
						local pa=aliveai.neartarget(self,aliveai.roundpos(self.object:get_pos()))
						if pa then
							local p=aliveai.creatpath(self,pa,upos)
							if p then
								self.path=p
								self.attention_path=nodepos
								self.attention_pathkind=self.attention_nodes[n]
								return self
							end
						end
					elseif self.attention_nodes[n]==-1 and math.random(1,1)==1 then
						self.object:set_yaw(math.random(0,6.28))
						aliveai.walk(self)
					elseif math.random(1,20)==1 then
						aliveai.lookat(self,nodepos)
					end
					if self.attention_nodes[n]~=0 and math.random(1,100)==1 then
						self.attention_nodes[n]=0
					end
				else
					local r=math.random(0,10)
					self.attention_nodes[n]=0
					if r==10 then
						self.attention_nodes[n]=3
						aliveai.lookat(self,nodepos)
					elseif r==9 then
						self.attention_nodes[n]=2
						aliveai.lookat(self,nodepos)
					elseif r==8 then
						self.attention_nodes[n]=1
						aliveai.lookat(self,nodepos)
					elseif r==7 then
						self.attention_nodes[n]=-1
					elseif r<5 then
						aliveai.lookat(self,nodepos)
					end
				end
			end
		end
	end
end

aliveai.get_nodes=function(self,radio,dencity,filter)
	if not self then return end
	radio=radio or 25
	dencity=dencity or 5
	filter=filter or {"default:dirt","default:stone","air"}
	local pos
	local rpos={}
	local filter2={}
	if not self.object and self.x and self.y and self.z then
		pos=self
	else
		pos=self.object:get_pos()
	end
	pos=aliveai.roundpos(pos)
	for _, nod in ipairs(filter) do
		table.insert(filter2,minetest.get_content_id(nod))
	end
	local pos1 = vector.subtract(pos, 1)
	local pos2 = vector.add(pos, radio)
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	for z = -radio, radio do
	for y = -radio, radio do
	for x = -radio, radio do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local v = area:index(p.x,p.y,p.z)
		if math.random(1,dencity)==1 then
			local nf=true
			for _, nod in ipairs(filter2) do
				if not data[v] or data[v]==nod then
					nf=false
					break
				end
			end
			if nf==true then
				table.insert(rpos,p)
			end
		end
	end
	end
	end
	return rpos
end

aliveai.random_pos=function(self,Min,Max)
	if not self then return end
	Min=Min or 10
	Max=Max or 25
	local pos

	local rnd_pos
	local rnd_d=0
	
	if not self.object and self.x and self.y and self.z then
		pos=self
	else
		pos=self.object:get_pos()
	end
	pos=aliveai.roundpos(pos)

	local air=minetest.get_content_id("air")
	local pos1 = vector.subtract(pos, Min)
	local pos2 = vector.add(pos, Max)
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	for z = -Max, Max do
	for y = -Max, Max do
	for x = -Max, Max do
		local v = area:index(pos.x+x,pos.y+y,pos.z+z)
		local p={x=pos.x+x,y=pos.y+y-1,z=pos.z+z}
		local n=minetest.registered_nodes[minetest.get_node(p).name]
		if data[v]==air and n and n.walkable and math.random(1,10)==1 then
			local a=true
			for i=1,3,1 do
				local p2={x=pos.x+x,y=pos.y+y+i,z=pos.z+z}
				local n=minetest.registered_nodes[minetest.get_node(p2).name]
				if not n or n.walkable then a=false end
			end
			local d=aliveai.distance(pos,p)
			if a and d>rnd_d and d<=Max then
				p.y=p.y+2
				rnd_pos=p
				rnd_d=d
			end
		end
	end
	end
	end
	return rnd_pos,rnd_d
end

aliveai.gethp=function(ob,even_dead)
	if not (ob and ob:get_pos()) then
		return 0
	elseif ob:is_player() then
		return ob:get_hp()
	end
	local en = ob:get_luaentity()
	return en and ((even_dead and en.aliveai and en.dead and en.hp) or (en.aliveai and en.dead and 0) or en.hp or en.health) or ob:get_hp() or 0
end

aliveai.showtext=function(self,text,color)
	self.delstatus=math.random(0,1000) 
	local del=self.delstatus
	color=color or "ff0000"
	self.object:set_properties({nametag=text,nametag_color="#" ..  color})
	minetest.after(1.5, function(self,del)
		if self and self.object and self.delstatus==del then
			if self.namecolor~="" then
				self.object:set_properties({nametag=self.botname,nametag_color="#" .. self.namecolor})
			else
				self.object:set_properties({nametag="",nametag_color=""})
			end
		end
	end, self,del)
	return self
end

aliveai.showhp=function(self,p)
	local color="ff0000"
	if p then color="00ff00" end
	aliveai.showtext(self,self.object:get_hp() .." / " .. self.hp_max,color)
	return self
end

aliveai.get_dir=function(self,pos2)
	local pos1
	if self.x and self.y and self.z then
		pos1=self
	elseif self.object then
		pos1=self.object:get_pos()
	else
		return {x=0,y=0,z=0}
	end
	if pos2 and not (pos2.x and pos2.y and pos2.z) then
		pos2=pos2:get_pos()
	end
	if not (pos2 and pos2.x) then
		return {x=0,y=0,z=0}
	end
	local d=math.floor(aliveai.distance(pos1,pos2)+0.5)
	return {x=(pos1.x-pos2.x)/-d,y=(pos1.y-pos2.y)/-d,z=(pos1.z-pos2.z)/-d}
end

aliveai.timer=function(self)
	if self.type=="npc" then return end
	if not self.lifetimer or self.fly or self.come or self.fight then self.lifetimer=aliveai.lifetimer end
	self.lifetimer=self.lifetimer-1
	if self.lifetimer>0 then return end
	for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
		local en=ob:get_luaentity() 
		if ob:is_player() or (en and en.type and en.type~="" and ((en.type~=self.type) or en.team and en.team~=self.team)) then
			self.lifetimer=nil
			return
		end
	end
	aliveai.showstatus(self," - removed")
	self.object:remove()
	return self
end



aliveai.creatpath=function(self,pos1,pos2,d,notadvanced)

	if aliveai.botdelay(self,1) then return nil end


	if aliveai.max_path_delay>aliveai.max_path_delay_time then
		print("Pathfinding delay:" .. aliveai.max_path_delay)
		return nil
	elseif aliveai.max_path_s>10 then
		return
	end
	pos1=aliveai.roundpos(pos1)
	pos2=aliveai.roundpos(pos2)
	d=d or self.distance

	if self.floating==1 then
		if aliveai.visiable(pos1,pos2) then
			local d2=aliveai.distance(pos1,pos2)
			local dir={x=(pos1.x-pos2.x)/-d2,y=(pos1.y-pos2.y)/-d2,z=(pos1.z-pos2.z)/-d2}
			local p={}
			for i=1,d2,1 do
				table.insert(p,aliveai.roundpos({x=pos1.x+(dir.x*i),y=pos1.y+(dir.y*i),z=pos1.z+(dir.z*i)}))
			end
			aliveai.showpath(p,1,true)
			return p
		end
		return nil
	end

	local path_delay=os.clock({sec=0})
	local p=minetest.find_path(pos1,pos2, self.distance, 2, self.avoidy,"Dijkstra")
	if aliveai.pathdelays(self,path_delay) then return nil end

if aliveai.botdelay(self,1) then return nil end

	if not notadvanced then
		p=p or aliveai.createpathbyladder(self,pos1,pos2,d)
		p=p or aliveai.createpathbytower(self,pos1,pos2)
		p=p or aliveai.createpathbybridge(self,pos1,pos2)
	end
if aliveai.botdelay(self,1) then return nil end

	aliveai.showpath(p,1,true)
	if aliveai.pathdelays(self,path_delay) then return nil end
	return p
end

aliveai.pathdelays=function(self,delay)
	aliveai.max_path_s=aliveai.max_path_s+1
	delay=os.clock({sec=0})-delay
	aliveai.max_path_delay=aliveai.max_path_delay+delay
	if delay>2 or (self.max_path_delay and self.max_path_delay>2) then
		if self.max_path_delay and self.max_path_delay>2 then delay=self.max_path_delay end
		self.on_step=nil
		self.object:set_hp(0)
		self.hp=0
		aliveai.kill(self)
		print("delay: " .. delay .. " destroyed " ..  self.botname)
		return self
	else
		if not self.max_path_delay or self.max_path_delay<0 then
			self.max_path_delay=0
		end
		self.max_path_delay=(self.max_path_delay+delay) - 0.1
		if delay>1 then return self end
	end
end

aliveai.createpathbybridge=function(self,pos1,pos2)
	local path
	if aliveai.visiable(pos1,pos2) then
		aliveai.showstatus(self,"bridge path")
		local n=0
		path={}
		local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
		v=aliveai.roundpos(v)
		local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
		local d=math.floor(math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x) + (pos1.y-pos2.y)*(pos1.y-pos2.y)+(pos1.z-pos2.z)*(pos1.z-pos2.z)))

		local arm=math.floor(self.arm)
		local snb=0
		local sb=(arm-1)*d

		v.y=v.y-1
		v.x = (v.x  / amount)*-1
		v.y = (v.y  / amount)*-1
		v.z = (v.z  / amount)*-1
		for i=0,d,1 do
			local p={x=pos1.x+(v.x*i),y=pos1.y+v.y-1,z=pos1.z+(v.z*i)}
			local node=minetest.get_node(p)
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].walkable==false then
				p=aliveai.roundpos(p)
				table.insert(path,p)
				aliveai.showpath(p,1)
				n=n+1
				for ii=1,arm,1 do
					local dp={x=p.x,y=p.y-ii,z=p.z}
					local node2=minetest.registered_nodes[minetest.get_node(dp).name]
					if node2 and node2.damage_per_second>0 then
						ii=arm
					elseif node2 and node2.walkable then
						snb=snb+1
						if snb>=sb then return nil end
						ii=arm
					end
				end
			end
		end
		for i, v in pairs(aliveai.basics) do
			if aliveai.invhave(self,i,n) then
				self.path_bridge=i
				break
			end
		end
		if not self.path_bridge then
			local nn=0
			for i, v in pairs(self.inv) do
				if minetest.registered_nodes[i] and minetest.registered_nodes[i].walkable then
					nn=nn+v
					if nn>=n then
						self.path_bridge=""
						break
					end
				end
			end
		end
		if not self.path_bridge then return nil end
	end
	return path
end


aliveai.createpathbytower=function(self,pos1,pos2)
	local d=self.distance
	local tp
	local new_path
	local n=0
	local tmp=aliveai.neartarget(self,pos2,-1,-d)
	aliveai.showstatus(self,"tower path")
	if tmp and aliveai.visiable(self,tmp) then
		tp={}
		table.insert(tp,tmp)
		local tmp2=aliveai.neartarget(self,pos2,-1,2,1)
		if tmp2 then
			table.insert(tp,tmp2)
		end
		table.insert(tp,pos2)
	elseif tmp then
		local tp1=minetest.find_path(pos1,tmp, d, 2, self.avoidy,"Dijkstra")
		if tp1 then
			tp=tp1
			table.insert(tp,pos2)
		end
	else
		local tp1=minetest.find_path(pos1,pos2, d, d-1, self.avoidy,"Dijkstra")
		if tp1 then
			tp=tp1
			table.insert(tp,pos2)
		end
	end
	if tp then
		local p
		local po
		new_path={}
		for i, p in pairs(tp) do
			if po and po.y<p.y then
				for i=1, p.y-po.y-1,1 do
					n=n+1
					local po2={x=po.x,y=po.y+i,z=po.z}
					table.insert(new_path, po2)
					aliveai.showpath(po2,2)
				end
			else
				table.insert(new_path, p)
				aliveai.showpath(p,1)
			end
			po={x=p.x,y=p.y,z=p.z}
		end

		for i, v in pairs(aliveai.basics) do
			if aliveai.invhave(self,i,n) then
				self.path_tower=i
				break
			end
		end
		if not self.path_tower then
			local nn=0
			for i, v in pairs(self.inv) do
				if minetest.registered_nodes[i] and minetest.registered_nodes[i].walkable then
					nn=nn+v
					if nn>=n then
						self.path_tower=""
						break
					end
				end
			end
		end
	end
	return new_path
end


aliveai.createpathbyladder=function(self,pos1,pos2,d)
	if pos2.y<pos1.y or pos2.y-pos1.y<self.arm then return nil end
	d=d or self.distance
	local np=minetest.find_node_near(pos2, d,aliveai.ladders)
	if np then np=aliveai.neartarget(self,np,1,0) end
	if np then
		aliveai.showstatus(self,"ladder path")
		aliveai.showpath(np,3)
		local np2=minetest.find_node_near(pos1, d,aliveai.ladders)
		if np2 and aliveai.visiable(self,np2) then
			aliveai.showpath(np2,2)
			local np3=minetest.find_path(pos1,np2, d, 2, self.avoidy,"Dijkstra")
				aliveai.showpath(np3,1,true)
			if np3 then
				local y1=math.floor(pos1.y+0.5)
				for i=y1,np.y,1 do
					local pos3={x=np2.x,y=i,z=np2.z}
					aliveai.showpath(pos3,1)
					table.insert(np3, pos3)
				end
				table.insert(np3, np)
				return np3
			end
		end
	end
	return nil
end



aliveai.buildpath=function(self,need)
	if self.house=="" then
		aliveai.generate_house(self)
	elseif string.find(self.house,"+++")~=nil then
		local house1=self.house.split(self.house,"+++")
		self.house=house1[2]
		local v=house1[1].split(house1[1]," ")
		local vx=tonumber(v[1])
		local vy=tonumber(v[2])
		local vz=tonumber(v[3])
		if vx and vy and vz then
			self.build_x=vx
			self.build_y=vy
			self.build_z=vz
		else
			print("aliveai: buildpath failed missing vector(s)")
			self.need=nil
			self.build_x=1
			self.build_y=1
			self.build_z=1
			self.house=""
			self.task="."
			return self
		end
	end
	local building=self.house
	local bas=building.split(building,"+")
	if not bas or not bas[2] then
		print("aliveai: buildpath failed (no +)")
		return nil
	end
	if need then
		local need0={}
		local need1=bas[1].split(bas[1],"!")
		for _, s1 in ipairs(need1) do
			local s2=s1.split(s1," ")
			if s2[1]==nil or s2[2]==nil  then
				print("aliveai: need failed (node or number)")
				return nil
			end
			aliveai.newneed(self,s2[1],tonumber(s2[2]))
		end
		return self
	end
	local build={node={},x=self.build_x,y=self.build_y,z=self.build_z}
	build.node={}
	local path={}
	local n=1
	local d1=bas[2].split(bas[2],"!")
	for _, s1 in ipairs(d1) do
		local s2=s1.split(s1," ")
		if s2[1]==nil or s2[2]==nil  then
			print("aliveai: buildpath failed (node or number)")
			return nil
		end
		local s2n=tonumber(s2[2])
		for s3=1,s2n,1 do
			build.node[n]=s2[1]
			n=n+1
		end
	end
	local dx=(build.x/2)*-1
	local dz=(build.z/2)*-1
	n=0
	local nn=0
	local pos=self.object:get_pos()

	
	if self.build_pos and self.build_pos~="" then
		pos=self.build_pos
	end

	aliveai.showstatus(self,"create (house) build path")
	for y=0,build.y,1 do
		for x=0,build.x,1 do
			for z=0,build.z,1 do
				nn=nn+1
				if build.node[nn]~="air" and build.node[nn]~=nil then
					local p={x=pos.x+x+dx,y=pos.y+y,z=pos.z+z+dz}
					if not minetest.get_node(p) or minetest.is_protected(p,"") then
						return nil
					end
					n=n+1
					path[n]={}
					path[n].pos=aliveai.roundpos(p)
					path[n].node=build.node[nn]
					aliveai.showpath(p,2)
				end
			end
		end
	end
	return path
end

aliveai.lookforfreespace=function(pos,xzstartdis,xzdis,xz,y)
	for i=xzstartdis,xzdis,1 do
		local p1={x=pos.x+i,y=pos.y,z=pos.z}
		local p2={x=pos.x-i,y=pos.y,z=pos.z}
		local p3={x=pos.x,y=pos.y,z=pos.z+i}
		local p4={x=pos.x,y=pos.y,z=pos.z-i}
		aliveai.showpath({p1,p2,p3,p4},2,true)
		if minetest.get_node(p1) and minetest.get_node(p1).name=="air" then
			if aliveai.checkarea(p1,"air",3,1) and aliveai.checkarea(p1,"air",xz,y) then
				return p1
			end
		end
		if minetest.get_node(p2) and minetest.get_node(p2).name=="air" then
			if aliveai.checkarea(p2,"air",3,1) and aliveai.checkarea(p2,"air",xz,y) then
				return p2
			end
		end
		if minetest.get_node(p3) and minetest.get_node(p3).name=="air" then
			if aliveai.checkarea(p3,"air",3,1) and aliveai.checkarea(p3,"air",xz,y) then
				return p3
			end
		end
		if minetest.get_node(p4) and minetest.get_node(p4).name=="air" then
			if aliveai.checkarea(p4,"air",3,1) and aliveai.checkarea(p4,"air",xz,y) then
				return p4
			end
		end
	end
		return nil
end

aliveai.checkarea=function(pos,node_name,pxz,py)
	if not pxz then return end
	local pxz2=(pxz/2)*-1
	local air= "air"==node_name
	for y=0,py,1 do
		for x=0,pxz,1 do
			for z=0,pxz,1 do
				local p={x=pos.x+x+pxz2,y=pos.y+y,z=pos.z+z+pxz2}
				local node=minetest.get_node(p)
				if not node or (air and minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].buildable_to==false and node.name~=node_name) or minetest.is_protected(p,"") then
					return false
				end
			end
		end
	end
	return true

end

aliveai.rndwalk=function(self,toogle)
	if toogle==nil then toogle=true end
	self.isrnd=toogle
	if toogle==false then
		self.falllook=nil
		return self
	end

	self.on_random_walk(self)
	local rnd=math.random(0,7)
--falllook
	if self.falllook then
		self.falllook.times=self.falllook.times-1
		if not self.falllook.ignore then
			local r=aliveai.random(1, self.falllook.n)
			if rnd<2 then
				self.object:set_yaw(aliveai.nan(self.falllook[r]))
				aliveai.stand(self)
			elseif rnd==2 then
				local pos=self.object:get_pos()
				local rndpos
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.distance)) do
					local en = ob:get_luaentity()
					if not (en and en.botname == self.botname) then
						rndpos=ob:get_pos()
						if math.random(1,3)==1 then break end
					end
				end
				if rndpos then
					aliveai.lookat(self,rndpos)
					aliveai.stand(self)
				end
			else
				self.object:set_yaw(aliveai.nan(self.falllook[r]))
				aliveai.walk(self)
			end
			if self.falllook.times<=0 then
				self.falllook=nil
				aliveai.falling(self)
			end
			return self
		end
		if self.falllook.times<=0 then self.falllook=nil end
	end
-- normal rnd

	if math.random(1,200)==1 then aliveai.sayrnd(self,"mine") end

	if rnd==0 then
		aliveai.lookat(self,math.random(0,6.28),true)
		aliveai.stand(self)
	elseif rnd==1 then
		aliveai.stand(self)
	elseif rnd==2 then
		local pos=self.object:get_pos()
		if self.staring then
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.arm)) do
				if math.random(1,2)==1 and ob and ob:get_pos() and aliveai.visiable(self,ob:get_pos()) and ((aliveai.get_bot_name(ob)==self.staring.name) or (ob:is_player() and self.staring.name==ob:get_player_name())) then
					if self.staring.step>2 then
						self.temper=1
						self.fight=ob
						aliveai.sayrnd(self,"come here")
						self.on_detect_enemy(self,self.fight)
						self.staring=nil
						return self
					end
					self.staring.step=self.staring.step+1
					aliveai.lookat(self,ob:get_pos(),true)
					aliveai.sayrnd(self,"what are you staring at?")
					return self
				end
			end
		elseif math.random(1,4)==1 and (self.annoyed_by_staring==1 or self.stealing==1) then
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.arm)) do
				if ob and ob:get_pos() and aliveai.visiable(self,ob:get_pos()) then
					if self.stealing==1 and aliveai.random(1,self.steal_chance)==1 then
						aliveai.steal(self,ob)
						return self
					end
					if self.annoyed_by_staring==1 and self.mood<0 and math.random(1,2)==1 and not aliveai.same_bot(self,ob) then
						self.staring={}
						if ob:is_player() then
							self.staring.name=ob:get_player_name()
						elseif aliveai.is_bot(ob) then
							self.staring.name=ob:get_luaentity().botname
						else
							self.staring.name=ob:get_luaentity().name
						end
						self.staring.step=1
						aliveai.lookat(self,ob:get_pos(),true)
						return self
					end
				end
			end		
		end
		self.staring=nil
		local rndpos
		local obb
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.distance)) do
			if ob and ob:get_pos() and aliveai.viewfield(self,ob) then
				rndpos=ob:get_pos()
				obb=ob
				if math.random(1,3)==1 then break end
			end
		end
		if rndpos then
			if obb:is_player() then
				local n=minetest.registered_nodes[minetest.get_node({x=rndpos.x,y=rndpos.y-1,z=rndpos.z}).name]
				if n and not (n.walkable or n.climbable or n.liquid_viscosity>0) and aliveai.team(obb)==self.team then
					aliveai.sayrnd(self,"its flying!","",true)
				end
			end
			aliveai.lookat(self,rndpos)
			aliveai.stand(self)
		end
	elseif rnd<4 then
		aliveai.lookat(self,math.random(0,6.28),true,true)
	elseif self.talking==1 and rnd==5 and math.random(1,20)==1 then
		aliveai.stand(self)
		local rndpos
		local obb
		local d=99
		for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance/2)) do
			if ob and ob:get_pos() and aliveai.visiable(self,ob) then
				if d>aliveai.distance(self,ob:get_pos()) and not aliveai.same_bot(self,ob) then
					rndpos=ob:get_pos()
					obb=ob
				end
				if math.random(1,3)==1 then break end
			end
		end
		if not obb then return end
		aliveai.lookat(self,rndpos)
		aliveai.rnd_talk_to(self,obb)
	elseif rnd==6 and not self.folow then
		local ob2
		for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
			if aliveai.visiable(self,ob:get_pos()) and aliveai.viewfield(self,ob) and aliveai.get_bot_name(ob)~=self.botname then
			ob2=ob
			if math.random(1,2)==1 then

				self.folow=ob
				return self
				end
			end
		end
		self.folow=ob2
	end
end

aliveai.punchdmg=function(ob,hp)
	if not ob or type(ob)~="userdata" then return end
	hp=hp or 1
	ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=hp}})
end

aliveai.punch=function(self,ob,hp)
	if not ob or type(ob)~="userdata" then return end
	hp=hp or 1
	if ob:get_luaentity() and ob:get_luaentity().itemstring then ob:remove() return end

	ob:punch(self.object,1,{full_punch_interval=1,damage_groups={fleshy=hp}})

	if self.object:get_hp()<=0 then
		return nil
	end
	return self	
end


aliveai.dmgbynode=function(self)
	if self.damage_by_blocks~=1 then return self end
	local pos=aliveai.newpos(self)
	local d1=aliveai.def(pos:yy(0),"damage_per_second")
	local d2=aliveai.def(pos:yy(-1),"damage_per_second")
	if d1 and d1>0 then
		aliveai.punchdmg(self.object,d1)
		if not (self.dying or self.dead or self.sleeping) then 
			self.object:set_yaw(math.random(0,6.28))
			aliveai.walk(self,2)
			aliveai.showstatus(self,"hurts by node",1)
		end
	elseif d2 and d2>0 then
		aliveai.punchdmg(self.object,d2)
		if not (self.dying or self.dead or self.sleeping) then
			self.object:set_yaw(math.random(0,6.28))
			aliveai.walk(self,2)
			aliveai.showstatus(self,"hurts by node",1)
		end
	end
	return self
end


aliveai.falling=function(self)
	self.timerfalling=0

	if self.floating==1 then
		local a=self.object:get_acceleration()
		local v=self.object:get_velocity()
		if v.y~=0 and v.y<-0.02 or v.y>0.02 then
			v.y=v.y*0.79
		else
			v.y=0
		end
		self.object:set_acceleration({x=0,y=0,z=0})
		self.object:set_velocity({x=v.x,y=v.y,z=v.z})
		return self
	end

	if aliveai.bots_delay2>aliveai.max_delay then return self end
	if self.isrnd and self.path and self.in_liquid==nil then aliveai.path(self) return self end
	if self.isrnd and self.done=="path" then self.timerfalling=0.2 self.done="" end

	self.object:set_acceleration({x=0,y=-aliveai.gravity,z =0})
	local pos=self.object:get_pos()
	local node2=minetest.get_node(pos)
	pos.y=pos.y-1
	local node=minetest.get_node(pos)
-- if unknown
	local test2=minetest.registered_nodes[node2.name]
	local test=minetest.registered_nodes[node.name]
	if not (test and test2) then return nil end
--water
	if test2.liquid_viscosity>0 then
		self.in_liquid=true
		local s=1
		if self.dying or self.dead or self.sleeping then s=-1 end
		self.object:set_acceleration({x =0, y =0.1*s, z =0})
		if self.object:get_velocity().y<-0.1 then
			local y=self.object:get_velocity().y
			self.object:set_velocity({x = self.move.x, y =y/2, z =self.move.z})
			return self
		end
		self.object:set_velocity({x = self.move.x, y =1*s - (test2.liquid_viscosity*0.1), z =self.move.z})
		if test.drowning and not self.drown then
			self.drown=true
			self.air=0
		elseif self.air and self.air>=20 then
			aliveai.punchdmg(self.object,1)
		elseif self.air then
			self.air=self.air+0.1
		end
		return self
-- ladder
	elseif test.climbable then
		self.in_liquid=true
		if not self.air then
			self.air=0
		elseif self.air>=20 then
			aliveai.punchdmg(self.object,1)
		elseif self.air>=5 then
			self.object:set_yaw(math.random(0,6.28))
			aliveai.walk(self)
			self.object:set_acceleration({x =0, y =-0.2, z =0})
			self.object:set_velocity({x = self.move.x, y =-2, z =self.move.z})
			return self
		end
		if self.climb==pos.y then self.air=self.air+0.1 end
		self.climb=pos.y
		self.object:set_acceleration({x =0, y =0.1, z =0})
		if self.object:get_velocity().y<-0.1 then
			local y=self.object:get_velocity().y
			self.object:set_velocity({x = self.move.x, y =y/2, z =self.move.z})
			return self
		end
		self.object:set_velocity({x = self.move.x, y =1, z =self.move.z})
		aliveai.stand(self)
		return self
-- no water or ledder
	elseif self.in_liquid then
		node=minetest.get_node({x=pos.x,y=pos.y-0.2,z=pos.z})
		local n=minetest.registered_nodes[node.name]
		self.air=nil
		self.climb=nil
		if n.liquid_viscosity>0 or n.climbable then
			self.object:set_acceleration({x=0,y=0,z =0})
			self.object:set_velocity({x = self.move.x, y =0, z =self.move.z})
			return self
		end
		self.in_liquid=nil
		self.object:set_acceleration({x=0,y=-10,z =0})
	elseif test2.drowning>0 and self.drowning then
		if not self.air then
			self.drown=true
			self.air=0
		elseif self.air>=20 then
			aliveai.punchdmg(self.object,1)
		end
		self.air=self.air+(test.drowning*0.1)
		return self
	elseif self.drown then
		self.in_liquid=nil
		self.air=nil
		self.drown=nil
-- falling
	elseif self.object:get_velocity().y~=0 then
		if not self.fallingfrom or self.fallingfrom<pos.y then self.fallingfrom=pos.y end
	end
--and hit the ground
	if self.fallingfrom then
		if self.object:get_velocity().y==0 then
			local from=math.floor(self.fallingfrom+0.5)
			local hit=math.floor(pos.y+0.5)
			self.isfalling=nil
			local d=from-hit
			self.fallingfrom=nil
			if d>=self.avoidy then
				aliveai.punchdmg(self.object,d)
			end
		else
			if not self.isfalling then
				local from=math.floor(self.fallingfrom+0.5)
				local hit=math.floor(pos.y+0.5)
				local d=from-hit
				if d>=self.avoidy then
					self.isfalling=1
					aliveai.sayrnd(self,"AHHH","",true)
				end
			end
		end
	elseif not self.told_flying and self.object:get_attach() and self.object:get_velocity().y==0 then
		local n=minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-2,z=pos.z}).name]
		if n and not (n.walkable or test.climbable or test2.liquid_viscosity>0 or n.liquid_viscosity>0) then
			aliveai.sayrnd(self,"Hey, im flying!","",true)
			self.told_flying=1
		end
	elseif self.told_flying and not self.object:get_attach() then
		self.told_flying=nil
	end

-- return if not moving
	if self.move.x+self.move.z==0 then return self end
--disable rnd directions
	if not self.path then
		local j={}
		local dmg=false
		for i=1,self.avoidy*-1,-1 do
			local nnode=minetest.registered_nodes[minetest.get_node({x=pos.x+self.move.x,y=pos.y+i,z=pos.z+self.move.z}).name]
			if not nnode then return end
			if nnode.damage_per_second>0 then dmg=true break end
			if i<0 then j[2+(i*-1)]=nnode.walkable end
			if nnode.walkable then break end
		end

		if self.fight and aliveai.distance(self,self.fight)<=self.arm*1.5 then
			j[self.avoidy+2]=nil
			dmg=nil
		end


		if j[self.avoidy+2]==false or dmg then
			self.falllook={ignore=false}
			local canuse={4.71,1.57,0,3.14}
			local f={{x=1,z=0},{x=-1,z=0},{x=0,z=1},{x=0,z=-1}}
			local use=1
			j={}
			for i=1,4,1 do
				for i2=1,self.avoidy*-1,-1 do
					local nnode=minetest.registered_nodes[minetest.get_node({x=pos.x+f[i].x,y=pos.y+i2,z=pos.z+f[i].z}).name]
					if not nnode then return end
					if nnode.damage_per_second>0 then
						break
					end

					if nnode.walkable then
						self.falllook[use]=canuse[i]
						self.falllook.n=use
						use=use+1
						aliveai.showpath({x=pos.x+f[i].x,y=pos.y+i2+1,z=pos.z+f[i].z},2)
						break
					end
				end
			end
			if use==1 then
				self.falllook.ignore=true
				self.falllook.times=5
			else
				self.falllook.times=10
				local p=aliveai.creatpath(self,pos,aliveai.roundpos(pos))
				if p~=nil then
					self.path=p
					self.timerfalling=0.1
					aliveai.falling(self)
					return self
				end
			end
			self.falllook.times=10
			return self
		elseif j[4]==false and self.object:get_velocity().y==0 then
			self.object:set_velocity({x = self.move.x*2, y = 5.2, z =self.move.z*2})
		end
	end
	return self
end

aliveai.jump=function(self,v)
	if self.object:get_velocity().y==0 then
		v=v or {}
		v.y=v.y or 5.2
		v.x=v.x or self.move.x
		v.z=v.z or self.move.z
		self.object:set_velocity({x = self.move.x, y = v.y, z =self.move.z})
	end
end

aliveai.jumping=function(self)
	local pos=self.object:get_pos()
	if not pos then
		return
	end

	pos.y=pos.y-self.basey
	if minetest.get_node(pos)==nil then return end
	local test=minetest.registered_nodes[minetest.get_node(pos).name]
-- jump inside block
	if self.object:get_velocity().y==0 and test.walkable and test.drawtype~="nodebox" then
		aliveai.jump(self)
		aliveai.showstatus(self,"jump inside block")
		if self.light==-1 then return self end
		pos.y=pos.y+2
		local n1=minetest.registered_nodes[minetest.get_node(pos).name]
		if n1 and n1.walkable then
			aliveai.stuckinblock(self)
		end
		return self
	elseif test.walkable and test.drawtype=="nodeboax" and aliveai.group(pos,"aliveai_door") then
		aliveai.open_door(self,pos)
		return self
	elseif aliveai.group({x=pos.x+self.move.x,y=pos.y,z=pos.z+self.move.z},"aliveai_door")>0 then
		aliveai.open_door(self,{x=pos.x+self.move.x,y=pos.y,z=pos.z+self.move.z})
		return self
	end

	if self.move.x+self.move.z~=0 and self.object:get_velocity().y==0 then
		local x=self.move.x
		local z=self.move.z
		local j={}
		for i=-2,3,1 do
			local jnod=minetest.registered_nodes[minetest.get_node({x=pos.x+x,y=pos.y+i,z=pos.z+z}).name]
			if not jnod then return end
			j[i+3]=jnod.walkable
		end
-- jump x1
		if j[3] and j[4]==false and j[5]==false then
			aliveai.jump(self)
			minetest.after(0.5, function(self)
				if self and self.object and self.object:get_luaentity() and self.object:get_luaentity().name then
					self.object:set_velocity({x = self.move.x*2, y = self.object:get_velocity().y, z =self.move.z*2})

				end
			end, self)
			aliveai.showstatus(self,"jump")
			return self
--jump x2
		elseif j[4] and j[5]==false and j[6]==false then
			aliveai.jump(self,{y=7})
			minetest.after(0.5, function(self)
				if self and self.object and self.object:get_luaentity() and self.object:get_luaentity().name then
					self.object:set_velocity({x = self.move.x*2, y = self.object:get_velocity().y, z =self.move.z*2})
				end
			end, self)
			aliveai.showstatus(self,"jump x2")
			return self
--wall or door
		elseif not self.path and j[4] and j[6] then
			aliveai.showstatus(self,"wall")
			aliveai.stand(self)
		end
	end
	return self
end

aliveai.neartarget=function(self,p,starty,endy,stepy)
	aliveai.showstatus(self,"check neartarget")
	local a={
	{x=p.x-1,z=p.z},
	{x=p.x+1,z=p.z},
	{x=p.x,z=p.z+1},
	{x=p.x,z=p.z-1},
	{x=p.x+1,z=p.z+1},
	{x=p.x-1,z=p.z-1},
	{x=p.x-1,z=p.z+1},
	{x=p.x+1,z=p.z-1}}
	local n=8
	local o=aliveai.roundpos(self.object:get_pos())
	local last_p=nil
	local last_able=nil
	starty=starty or 1
	endy=endy or -4
	stepy=stepy or -1
	for y=starty,endy,stepy do
		for i=1,8,1 do
			last_p={x=a[i].x,y=p.y+y,z=a[i].z}
			if minetest.registered_nodes[minetest.get_node(last_p).name] and minetest.registered_nodes[minetest.get_node(last_p).name].walkable==false then
				local nod1=minetest.registered_nodes[minetest.get_node({x=a[i].x,y=p.y+y-1,z=a[i].z}).name]
				local nod2=minetest.registered_nodes[minetest.get_node({x=a[i].x,y=p.y+y+1,z=a[i].z}).name]
				if nod1 and nod1.walkable and
				nod2 and nod2.walkable==false then
					last_able={x=a[i].x,y=p.y+y,z=a[i].z}
					if o.y==last_able.y then
						aliveai.showpath(last_able,3)
						return last_able
					end
				end
			else
				n=n-1
			end
		end
		if n==0 and y<=0 then
			break	
		end
		n=8
	end
		if last_able~=nil then
			aliveai.showpath(last_able,3)
			return last_able
		end
		return nil
end

aliveai.findnode=function(self,node_name,ignores)
	aliveai.showstatus(self,"find node")
	local pos=self.object:get_pos()
	pos.y=pos.y-1
	local re={pos={},path={}}
	local np=minetest.find_node_near(pos, self.distance,{node_name})
	if ignores and np~=nil then -- ignore unable nodes
		for _, s in pairs(ignores) do
			if aliveai.samepos(np,s) then
				return ignores
			end
		end
	end
	if np~=nil and minetest.is_protected(np,"")==false then
	re.pos=np
		local np2=nil
		local near=aliveai.neartarget(self,np)
		if near~=nil then
			np2=near
		else
			np2=minetest.find_node_near(np, 2,{"air"})
		end
		if np2~=nil then
			local np3=np
			if minetest.registered_nodes[minetest.get_node({x=np2.x,y=np2.y-1,z=np2.z}).name].walkable==false
			or minetest.registered_nodes[minetest.get_node({x=np2.x,y=np2.y+1,z=np2.z}).name].walkable==false then
				np3=np2
				aliveai.showpath(np,3)
			end
			local pos1=aliveai.roundpos(pos)
			local p=aliveai.creatpath(self,pos1,np3)
			if p~=nil then
				re.path=p
				return re
			else
			if not ignores then ignores={} end -- ignore unable nodes
				table.insert(ignores, np)
				return ignores
			end
		end
	end
	return nil
end

aliveai.ignorenode=function(self,pos)
	if self.mine then
		if not self.mine.ignore then self.mine.ignore={} end -- ignore unable nodes
		table.insert(self.mine.ignore, pos)
		return self
	end
end

aliveai.samepos=function(pos1,pos2)
	return (pos1 and pos2 and pos1.x==pos2.x and pos1.y==pos2.y and pos1.z==pos2.z)
end

aliveai.roundpos=function(pos)
	if pos and pos.x and pos.y and pos.z then
		pos.x = math.floor(pos.x+0.5)
		pos.y = math.floor(pos.y+0.5)
		pos.z = math.floor(pos.z+0.5)
		return pos
	end
	return nil
end

aliveai.viewfield=function(self,ob)
	if not (self and self.object and ob) then return false end
	local pos1=self.object:get_pos()
	local pos2 = type(ob) == "userdata" and ob:get_pos() or ob
	return aliveai.distance(pos1,pos2)>aliveai.distance(aliveai.pointat(self,0.1),pos2)
end

aliveai.pointat=function(self,d)
	local pos=self.object:get_pos()
	local yaw=aliveai.nan(self.object:get_yaw())
	d=d or 1
	local x =math.sin(yaw) * -d
	local z =math.cos(yaw) * d
	return {x=pos.x+x,y=pos.y,z=pos.z+z}
end

aliveai.distance=function(pos1,pos2)
	if not (pos1 and pos1.x and pos2 and pos2.x) then
		return 0
	end
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1.object and pos1.object:get_pos() or pos1
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2.object and pos2.object:get_pos() or pos2
	if type(pos2) ~= "table" then
		return 0
	end
	return vector.distance(pos1,pos2)
end

aliveai.visiable=function(pos1,pos2)
	pos1 = type(pos1) == "userdata" and pos1:get_pos() or pos1.object and pos1.object:get_pos() or pos1
	pos2 = type(pos2) == "userdata" and pos2:get_pos() or pos2	

	if not (pos1 and pos1.x and pos2 and pos2.x) then
		return false
	end

	local v = {x = pos1.x - pos2.x, y = pos1.y - pos2.y-1, z = pos1.z - pos2.z}
	v.y=v.y-1
	local amount = (v.x ^ 2 + v.y ^ 2 + v.z ^ 2) ^ 0.5
	local d=vector.distance(pos1,pos2)
	v.x = (v.x  / amount)*-1
	v.y = (v.y  / amount)*-1
	v.z = (v.z  / amount)*-1
	for i=1,d,1 do
		local node = minetest.registered_nodes[minetest.get_node({x=pos1.x+(v.x*i),y=pos1.y+(v.y*i),z=pos1.z+(v.z*i)}).name]
		if node and node.walkable then
			return false
		end
	end
	return true
end

aliveai.walk=function(self,sp)
	local pos=self.object:get_pos()
	local yaw=aliveai.nan(self.object:get_yaw())
	sp=sp or 1
	local x =math.sin(yaw) * -1
	local z =math.cos(yaw) * 1
	local y=self.object:get_velocity().y
	local s=(self.move.speed+1)*sp
	self.move.x=x*sp
	self.move.z=z*sp
	if self.floating==1 and self.lookat then
		if pos.y<self.lookat.y-0.25 then
			y=s
		elseif pos.y>self.lookat.y+0.25 then
			y=-s
		end
		self.lookat=nil
	end
	self.object:set_velocity({
		x = x*s,
		y = y,
		z = z*s})
	if self.hugwalk==0 then
		aliveai.anim(self,"walk")
	else
		aliveai.anim(self,"hugwalk")
	end
	return self
end

aliveai.stand=function(self)
	if not self.move or not self.object or not self.object:get_velocity() then aliveai.kill(self) return end
	self.move.x=0
	self.move.z=0
	self.object:set_velocity({
		x = 0,
		y = self.object:get_velocity().y,
		z = 0})
	aliveai.anim(self,"stand")
	return self
end

aliveai.lookat=function(self,pos2)
	if type(pos2)=="table" then
		local pos1=self.object:get_pos()
		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local yaw = aliveai.nan(math.atan(vec.z/vec.x)-math.pi/2)
		if pos1.x >= pos2.x then yaw = yaw+math.pi end
		self.object:set_yaw(yaw)
		self.lookat=pos2
	elseif type(pos2)=="number" then
		self.object:set_yaw(pos2)
	end
	return self
end

aliveai.anim=function(self,type)
	if self.visual~="mesh" then return end
	if type==self.anim or self.anim==nil then return self end
	local a=self.animation[type]
	if not a then return self end
	self.object:set_animation({ x=a.x, y=a.y, },a.speed,a.loop)
	self.anim=type
	return self
end

aliveai.strpos=function(str,spl)
	if str==nil then return "" end
	if spl then
		local c=","
		if string.find(str," ") then c=" " end
		local s=str.split(str,c)
			if s[3]==nil then
				return nil
			else
				return {x=tonumber(s[1]),y=tonumber(s[2]),z=tonumber(s[3])}
			end
	else	if str.x and str.y and str.z then
			str=aliveai.roundpos(str)
			return str.x .."," .. str.y .."," .. str.z
		else
			return nil
		end
	end
end

aliveai.genname=function(self)
	local r=math.random(3,15)
	local s=""
	local rnd
	for i=1, r do
		rnd=math.random(1, 4)
		if rnd==1 then
			s=s .. string.char(math.random(97, 122))
		elseif rnd==2 then
			s=s .. string.char(math.random(48, 57))
		else
			s=s .. string.char(math.random(65, 90))
		end
	end
	return s
end

aliveai.max=function(self,update)
	local c=0
	for i,v in pairs(aliveai.active) do
		if aliveai.gethp(v,1)<0 then
			table.remove(aliveai.active,c)
		else
			c=c+1
		end
	end
	aliveai.active_num=c
	local new=aliveai.newbot
	aliveai.newbot=nil
	if new and aliveai.active_num>aliveai.max_new_bots then
		self.object:remove()
		return self
	end
	if update then
		return self
	elseif aliveai.bots_delay2>aliveai.max_delay and (self.old==0 or self.delay_average.time>1) then
		if self.old==0 then
			print("aliveai: removed","new","active bots: " ..aliveai.active_num)
		else
			print("aliveai: removed","delay: " ..self.delay_average.time,"active bots: " ..aliveai.active_num)
		end
		aliveai.bots_delay2= aliveai.bots_delay2*0.99

		aliveai.sayrnd(self,"LAAAAAAAAG!")

		self.object:remove()
		return self
	end
	if not aliveai.active[self.botname] then
		aliveai.active[self.botname]=self.object
	end
end

aliveai.botdelay=function(self,a)
	if self.delaytimeout then
		if os.clock()>self.delaytimeout then
			self.delaytimeout=nil
			a=1
		else
			return self
		end
	elseif not self.delay_average then
		self.delay_average={time=0}
	end

	local new=os.clock()-self.delaytimer

	if aliveai.game_paused then
		self.delay_average={time=0}
		self.delaytimer=os.clock()
		return
	elseif not a then
		self.delaytimer=os.clock()
		return
	else
		if not self.delay_steps_to then self.delay_steps_to=0 end
		self.delay_steps_to=self.delay_steps_to+1
		if self.delay_steps_to<10 then return end
		self.delay_steps_to=0

		local p=math.floor(new/aliveai.delaytime)/10

		if #self.delay_average>10 then
			table.remove(self.delay_average,1)
			local d=self.delay_average
			self.delay_average.time=aliveai.nan((d[1]+d[2]+d[3]+d[4]+d[5]+d[6]+d[7]+d[8]+d[9]+d[10])/10)
			
		else
			table.insert(self.delay_average,p)
		end

		if self.terminal_user then
			if aliveai.terminal_users[self.terminal_user] and aliveai.terminal_users[self.terminal_user].botname==self.botname then
				if aliveai.terminal_users[self.terminal_user].status then
					aliveai.show_terminal(minetest.get_player_by_name(self.terminal_user),1)
				end
			else
				self.terminal_user=nil
			end
		end
		if self.delay_average.time>1 then
			self.delaytimeout=os.clock()+(p-1)
			if self.type~="npc" or (self.type=="npc" and self.delay_average.time>1.5) then
				aliveai.max(self)
			end
			if aliveai.status==true then
				aliveai.showstatus(self,(self.delay_average.time*100) .."% delay",1)
			end
		elseif aliveai.status==true and self.delay_average.time>0.5 then
			aliveai.showstatus(self,(self.delay_average.time*100) .."% delay",4)
		end

		self.delaytimer=os.clock()
	end
end

