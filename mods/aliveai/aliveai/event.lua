aliveai.folowing=function(self)
	if self.folow then
		local p=self.folow:get_pos()
		if math.random(1,10)==1 or self.mood<0 or not (p and aliveai.visiable(self,p) and aliveai.distance(self,p)<self.distance) then
			self.folow=nil
			aliveai.stand(self)
			return
		elseif self.falllook then
			aliveai.lookat(self,p)
			aliveai.stand(self)
		elseif aliveai.distance(self.object:get_pos(),p)>3 then
			aliveai.lookat(self,p)
			aliveai.walk(self)
		elseif self.falllook then
			aliveai.lookat(self,p)
			aliveai.stand(self)
		end
		return self
	end

end

aliveai.sleep=function(self,set)
	if self.type~="npc" then return end

	if self.sleeptimer then
		if self.sleeptimer>0 and self.sleeping then
			self.sleeptimer=self.sleeptimer-1
			return self
		else
			self.sleeptimer=nil
		end
	end

	if set==2 then
		aliveai.exitpath(self)
		aliveai.stand(self)
		self.sleeping=1
		aliveai.anim(self,"lay")
		self.sleeptimer=60
		self.object:set_velocity({x=0,y=-3,z =0})
		aliveai.showstatus(self,"sleep")
		return self
	end

	if set==1 then
		local pos=aliveai.roundpos(self.object:get_pos())
		local pos2=aliveai.roundpos(self.object:get_pos())
		pos.y=pos.y-1
		local n = minetest.get_node(pos)

		if n.param2==1 then
			self.object:set_pos({x=pos2.x+0.5,y=pos2.y,z=pos2.z})
			self.object:set_yaw(math.pi*0.5)
		elseif n.param2==3 then
			self.object:set_pos({x=pos2.x-0.5,y=pos2.y,z=pos2.z})
			self.object:set_yaw(math.pi+1.5)
		elseif n.param2==0 then
			self.object:set_pos({x=pos2.x,y=pos2.y,z=pos2.z+0.5})
			self.object:set_yaw(math.pi*1)
		else
			self.object:set_pos({x=pos2.x,y=pos2.y,z=pos2.z-0.5})
			self.object:set_yaw(math.pi*0)
		end
		return
	end


	if not self.sleeping and math.random(1,10)~=1 then return end

	if self.bedpath and self.path then
		aliveai.path(self)
		if self.done=="path" or (math.random(1,5)==1 and aliveai.distance(self,self.bedpath)<self.arm)  then
			aliveai.exitpath(self)
			for ob, ob in ipairs(minetest.get_objects_inside_radius(self.bedpath, 1)) do
				if (aliveai.is_bot(ob) and ob:get_luaentity().sleeping) or ob:is_player() then
					self.bedpath=nil
					return
				end
			end
			self.sleeping=1
			self.object:set_pos(self.bedpath)
			self.bedpath=nil
			aliveai.anim(self,"lay")
			aliveai.sleep(self,1)
			self.sleeptimer=10
			aliveai.showstatus(self,"sleep")
			return self
		end
	end
	local t=minetest.get_timeofday()
	local sl=((self.light>0 and (t>=0.8 or t<0.2)) or (self.light<0 and (t<=0.8 and t>0.2)))
	if not self.sleeping and sl==true then
		local l=minetest.get_node_light(self.object:get_pos())
		if (self.light>0 and l>=self.lowestlight) or (self.light<0 and l<=self.lowestlight) then
			aliveai.showstatus(self,"check for beds")
			local pos=aliveai.roundpos(self.object:get_pos())
			for i, s in pairs(aliveai.beds) do
				local n=minetest.find_node_near(pos, self.distance,aliveai.beds)
				if n then
					n.y=n.y+1
					for ob, ob in ipairs(minetest.get_objects_inside_radius(n, 1)) do
						if (aliveai.is_bot(ob) and ob:get_luaentity().sleeping) or ob:is_player() then return end
					end
					local p=aliveai.creatpath(self,pos,n)
					if p then
						self.path=p
						self.bedpath=n
					end
				end
			end
		end
	elseif self.sleeping and sl==false then
		self.sleeping=nil
		aliveai.stand(self)
	elseif self.sleeping then
		self.sleeptimer=10
		aliveai.anim(self,"lay")
		return self
	end
end



aliveai.dying=function(self,set)
	if set and set==1 then
		if self.drop_dead_body==0 or self.hp_max>100 then return end
		aliveai.exitpath(self)
		aliveai.anim(self,"lay")
		self.talking_restore=self.talking
		self.talking=0
		self.object:set_acceleration({x=0,y=-10,z =0})
		self.object:set_velocity({x=0,y=-3,z =0})
		aliveai.invdropall(self)
		if self.hp<=self.hp_max*-1 then
			aliveai.dying(self,2)
			return self
		end

		self.dying={step=self.hp_max+self.hp,try=self.hp+self.hp_max/2}
		self.hp=self.hp_max/2
		self.object:set_hp(self.hp)
	elseif set and set==2 then
		if self.drop_dead_body==0 then
			if self.hp_max<101 then aliveai.punchdmg(self,self.hp_max) end
			return
		end
		minetest.after(0.1, function(self)
			if self.object:get_luaentity() then
				aliveai.exitpath(self)
				aliveai.anim(self,"lay")
			end
		end, self)
		self.namecolor=""
		self.object:set_properties({nametag=""})
		self.talking=0
		self.type=""
		self.hp=self.hp_max
		self.object:set_hp(self.hp)
		self.dying=nil
		self.dead=20
	elseif set and set==3 and (self.dying or self.dead) then
		self.dying={step=0,try=self.hp_max*2}
		self.dead=nil
	end

	if self.dying then
		self.object:set_velocity({x=0,y=self.object:get_velocity().y,z=0})
		if self.hp<=self.hp_max*-1 then
			aliveai.dying(self,2)
			return self
		end
		self.dying.try=self.dying.try+math.random(-1,1)
		self.dying.step=self.dying.step-1
		aliveai.showtext(self,(self.dying.try+self.hp) .."/".. self.hp_max,"ff5500")
		if self.dying.step<1 and self.dying.try+self.hp>=self.hp_max then
			local h=math.random(1,5)
			self.dying=nil
			self.hp=h
			self.object:set_hp(h)
			self.talking=self.talking_restor
			self.talking_restor=nil
			aliveai.stand(self)
			aliveai.showtext(self,"")
			return self
		elseif self.dying.step<1 and self.dying.try+self.hp<self.hp_max then
			aliveai.dying(self,2)
			return self
		end
		aliveai.dmgbynode(self)
		return self
	elseif self.dead then
		self.dead=self.dead-1
		if self.dead<0 then
			local pos=self.object:get_pos()
			pos.y=pos.y-1
			if minetest.get_item_group(minetest.get_node(pos).name, "igniter")>0 then
				minetest.add_particlespawner({
				amount = 10,
				time =0.2,
				minpos = {x=pos.x-1, y=pos.y, z=pos.z-1},
				maxpos = {x=pos.x+1, y=pos.y, z=pos.z+1},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=math.random(3,6), z=0},
				minacc = {x=0, y=2, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 3,
				maxsize = 8,
				texture = "default_item_smoke.png",
				collisiondetection = true,
			})
			end
			aliveai.spawnbones(self)
			self.destroy=1
			aliveai.kill(self)
			
		end
		return self
	end
end

aliveai.rndgoal=function(self)
	if not self.isrnd or self.build or math.random(1,50)~=1 then return end
	if self.rndgoal and self.path then
		aliveai.path(self)
		if self.done=="path" or (math.random(1,10)==1 and aliveai.distance(self,self.rndgoal)<self.arm) then
			self.done=""
			self.rndgoal=nil
			aliveai.showstatus(self,"random goal success")
		end
		return self
	end
	local p1=aliveai.random_pos(self)
	if p1 then
		local p2=aliveai.neartarget(self,p1)
		if p2 then
			local pos=aliveai.roundpos(self.object:get_pos())
			pos.y=pos.y-1
			local p3=aliveai.creatpath(self,pos,p2)
			if p3 then
				self.path=p3
				self.rndgoal=p1
				aliveai.showstatus(self,"random goal")
				aliveai.showpath(p3,1,true)
				return self
			end
		end
	end
end



aliveai.node_handler=function(self)
	local keep
	if self.nodehandler and self.path then
		aliveai.path(self)
		if self.done=="path" then
			self.mood=self.mood+1
			if type(self.nodehandler.handler)=="table" then
				self.nodehandler.handler.func(self,self.nodehandler.pos,self.nodehandler.handler.item,self.nodehandler.handler.pos)
			end
			if type(self.nodehandler.handler)=="function" then
				self.nodehandler.handler(self,self.nodehandler.pos)
			end
			if self.nodehandler.handler=="dig" then
				aliveai.stand(self)
				aliveai.lookat(self,self.nodehandler.pos)
				aliveai.dig(self,self.nodehandler.pos)
				keep=true
				self.time=self.otime
			end
			if aliveai.mesecons and self.nodehandler.handler=="mesecon_on" then
				mesecon.receptor_on(self,self.nodehandler.pos)
			end
			if aliveai.mesecons and self.nodehandler.handler=="mesecon_off" then
				mesecon.receptor_off(self,self.nodehandler.pos)
			end
			if aliveai.mesecons and self.nodehandler.handler=="punch" then
				local n=minetest.get_node(self.nodehandler.pos)
				if self.nodehandler.name==n.name and
				minetest.registered_nodes[n.name] and
				minetest.registered_nodes[n.name].on_rightclick then
					minetest.after(0.1, function(self)
						aliveai.clearinventory(self)
					end,self)
					minetest.registered_nodes[n.name].on_rightclick(self.nodehandler.pos,n,aliveai.createuser(self))
				end
			end
			if not keep then
				self.done=""
				self.nodehandler=nil
				return
			end
		end
	end
	if self.mood<10 then return end
	if (not keep and math.random(1,20)~=1) and not aliveai.constant_node_testing then return end
	aliveai.showstatus(self,"handling nodes")
	local p3
	local pos=self.object:get_pos()
	local pt={x=pos.x,y=pos.y-1,z=pos.z}
	for i, s in pairs(aliveai.nodes_handler) do
		if minetest.get_node(pt).name==i then
			self.path={pt}
			self.nodehandler={name=i,handler=s,pos=pt}
			self.done="path"
			return self
		end

		local p=minetest.find_node_near(pos, self.arm,i)
		if p and aliveai.visiable(self,p) then
			local p2=aliveai.neartarget(self,p)
			if p2 then
				local p3=aliveai.creatpath(self,pos,p2)
				if p3 then
					self.path=p3
					self.nodehandler={name=i,handler=s,pos=p}
					return self
				end
			end
		end
	end
end

aliveai.stuckinblock=function(self)
	local posl=self.object:get_pos()
	local n=minetest.get_node({x=posl.x,y=posl.y,z=posl.z})
	local stuck=1
	local p2={}
	local arm=math.floor(self.arm)+1
	self.object:set_yaw(math.random(0,6.28))
	aliveai.walk(self)
	if minetest.registered_nodes[n.name] and minetest.registered_nodes[n.name].walkable then
		local p
		for i=1,arm,1 do
			p={x=posl.x,y=posl.y+i,z=posl.z}
			n=minetest.get_node(p)
			local n2=minetest.registered_nodes[n.name]
			if (i==arm and n2 and n2.walkable) or minetest.is_protected(p,"") or minetest.get_meta(p):get_string("owner")~="" then
				stuck=2
			elseif n2 and n2.walkable then
				p2[i]=p
			elseif n2 and not n2.walkable then
				break
			end
		end
	end
	if stuck==1 then
		for i=1,#p2,1 do
			if not aliveai.dig(self,p2[i]) then
				stuck=2
				break
			end
		end
	end
	if stuck==2 then
		aliveai.punchdmg(self.object,1)
		aliveai.showstatus(self,"stuck inside block")
	end
	return nil
end



aliveai.need_helper=function(self)
	if self.mood>0 and self.help_need then
		if self.done=="come" then
			self.done=""
			if not self.help_need:get_luaentity() or aliveai.gethp(self.help_need)<=0 then self.help_need=nil return end
			for item, n in pairs(self.inv) do
				if not minetest.registered_tools[item] then
					aliveai.invadd(self.help_need:get_luaentity(),item,n)
					aliveai.invadd(self,item,-n)
				end	
			end
			aliveai.showstatus(self,"gave " .. self.help_need:get_luaentity().botname .." stuff",3)
			aliveai.known(self,self.help_need,"member")
			self.help_need=nil
			return self
		end
		return
	end
	if self.work_helper==0 or self.coming~=1 or self.building~=1 or math.random(1,50)~=1 then return end
	aliveai.max(self,true)
	local pos=self.object:get_pos()
	local self_inv=0
	local ob_inv=0
	local give
	local ob2

	for item, n in pairs(self.inv) do
		if not minetest.registered_tools[item] then
			self_inv=self_inv+n
		end
	end
	if self_inv<10 then return end
	for i, ob in pairs(aliveai.active) do
		ob2=ob:get_luaentity()
		if ob2 and ob2.need and ob2.building==1 and ob2.botname~=self.botname and ob2.team==self.team and aliveai.distance(self,ob2.object:get_pos())<self.distance*3 then
			local inv=0
			for item, n in pairs(ob2.inv) do
				inv=inv+n
			end
			if inv>ob_inv then
				ob_inv=inv
				give=ob
			end
		end
	end
	if ob_inv>self_inv and give then
		self.help_need=give
		self.come=give
		self.zeal=5
		aliveai.showstatus(self,"give " .. give:get_luaentity().botname .." stuff")
		return self
	end
end

aliveai.steal=function(self,ste)
	local known=aliveai.getknown(self,ste)
	if self.mood<1 or self.stealing~=1 or known=="member" or not ste:is_player() then return self end
	aliveai.showstatus(self,"stealing")
	local inv=ste:get_inventory()
	local ix=0
	for i=1,8,1 do
		local stack=inv:get_stack("main",i)
		if i~=ste:get_wield_index() and stack:get_name()~="" then ix=i end
		if ix~=0 and math.random(1,2)==1 then break end
	end
	if ix>0 then
		local stack=inv:get_stack("main",ix)
		aliveai.invadd(self,stack:get_name(),stack:get_count())
		inv:set_stack("main",ix,nil)
		if math.random(1,5)==1 then
			self.fight=ste
			aliveai.known(self,ste,"fight")
			self.temper=0.5
		else
			aliveai.known(self,ste,"fly")
		end
		aliveai.punch(self,ste,1)
		return self
	end
end

aliveai.light=function(self)
	if self.gotolight and self.path then
		aliveai.path(self)
		if self.done~="" then
			self.done=""
			self.gotolight=nil
			aliveai.stand(self)
			aliveai.rndwalk(self)
			return self
		end
		local l=minetest.get_node_light(self.object:get_pos()) or 0
		if (self.light>0 and l>=self.lowestlight) or (self.light<0 and l<=self.lowestlight) then
			aliveai.exitpath(self)
		end
		return self
	end

	if self.isrnd==false or self.path then
		return
	elseif self.light==0 or math.random(1,10)~=1 then
		return
	end

	if aliveai.max_path_delay>aliveai.max_path_delay_time then
		return nil
	end

	aliveai.showstatus(self,"check light")
	local pos=aliveai.roundpos(self.object:get_pos())
	pos.y=pos.y-1
	local l=minetest.get_node_light(pos)
	if l==nil or (self.light>0 and l>=self.lowestlight) or (self.light<0 and l<=self.lowestlight) then
		return
	end
	aliveai.showstatus(self,"escape light")
	local radius=self.distance
	local olight=l
	local light=l
	local lightpos
	local traped=false
	local maxpath=0
	for r = 1, radius do
		if traped and self.lightdamage==1 and ((self.light>0 and pos.y<0) or (self.light<0 and pos.y>0)) then
			aliveai.stuckinblock(self)
		end
		traped=true
	for y = -r, r do
	for x = -r, r do
	for z = -r, r do
	if  y==-r or y==r or x==-r or x==r or z==-r or z==r then
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		local node=minetest.get_node(p)
		if not minetest.registered_nodes[node.name] then return nil end
		if minetest.registered_nodes[node.name].walkable==false then
			traped=false
			local p2={x=pos.x+x,y=pos.y+y-1,z=pos.z+z}
			local p3={x=pos.x+x,y=pos.y+y+1,z=pos.z+z}
			local node2=minetest.get_node(p2)
			local node3=minetest.get_node(p3)
			local l2=minetest.get_node_light(p)
			if not (self.light and light and l2) then return end
			if not (minetest.registered_nodes[node2.name] and minetest.registered_nodes[node3.name]) then return end
			if ((self.light>0 and l2>light) or (self.light<0 and l2<light))
			and minetest.registered_nodes[node2.name].walkable 
			and minetest.registered_nodes[node3.name].walkable==false
			and (aliveai.visiable(self,p) or (maxpath<9 and math.random(1,20)==1 and aliveai.creatpath(self,pos,p,nil,true))) then
				maxpath=maxpath+1
				aliveai.showpath(p,2)
				light=minetest.get_node_light(p)
				lightpos=p
				if ((self.light>0 and light>=15) or (self.light<0 and light<=0)) then
					break
				end
			end
		end
	else
		z=r
	end
	end
	end
	end
	end

	if not lightpos then
		if self.lightdamage==1 and ((self.light>0 and pos.y<0) or (self.light<0 and pos.y>0)) then
			aliveai.punchdmg(self.object,1)
		end
		if self.lightdamage==0 or aliveai.enable_build==false then return self end
		for i, v in pairs(self.inv) do
			if minetest.registered_nodes[i] and minetest.registered_nodes[i].light_source>0 then
				aliveai.place(self,pos,i)
				return self
			end
		end
		return nil
	end

	local path=aliveai.creatpath(self,pos,lightpos,nil,true)
	if path then
		aliveai.showstatus(self,"go to light: " .. olight .." " .. light)
		aliveai.rndwalk(self,false)
		self.path=path
		self.gotolight=true
		return self
	end
end

aliveai.searchhelp=function(self)
	if self.coming==1 then
		aliveai.showstatus(self,"search help")
		local pos=self.object:get_pos()
		local d=aliveai.distance(self,pos)
		local obs
		if self.leader==1 then
			obs=aliveai.active
		else
			obs=minetest.get_objects_inside_radius(pos, self.distance)
		end
		for _, ob in ipairs(obs) do
			if ob and aliveai.team(ob)==self.team and not aliveai.same_bot(self,ob) and (aliveai.is_bot(ob) or ob:is_player()) and (self.leader==1 or aliveai.visiable(self,ob:get_pos())) and not aliveai.is_invisiable(ob) then
				local known=aliveai.getknown(self,ob)
				if known~="fight" and known~="fly" then
					if ob:is_player() then
						aliveai.say(self,ob:get_player_name() .." come")
					else
						aliveai.msg[ob:get_luaentity().botname]={name=self.botname,msg=ob:get_luaentity().botname .." come"}
						aliveai.say(self,ob:get_luaentity().botname .." come")
					end
					if self.leader==1 then
						aliveai.known(ob:get_luaentity(),self.fight,"fight")
						ob:get_luaentity().fight=self.fight
						ob:get_luaentity().temper=ob:get_luaentity().temper+2
					elseif math.random(1,3)==1 then
						return self
					end
				end
			end
		end
		return self
	end
end

aliveai.searchobjects=function(self)
		if (self.fight or self.fly or self.come) or (self.attacking==0 and self.mood<0) or aliveai.random(1,self.attack_chance)~=1 then
			return
		end
		local pos=self.object:get_pos()
		local d=aliveai.distance(self,pos)
		local rndob
		local d=self.distance
		aliveai.showstatus(self,"search objects")
		for i=0,1,1 do
			for iob, ob in ipairs(minetest.get_objects_inside_radius(pos, self.distance)) do
				if i==1 then
					if rndob then
						ob=rndob
					else
						return self
					end
				end
				local en=ob:get_luaentity()
				if aliveai.gethp(ob)>0 and aliveai.visiable(self,ob:get_pos()) and (aliveai.viewfield(self,ob) or aliveai.distance(self,ob:get_pos())<self.arm) and ((aliveai.team(ob)~=self.team and not aliveai.is_bot(ob)) or (en and en.itemstring==nil and en.type and en.type~="" and en.team~=self.team and en.botname~=self.botname)) and not aliveai.is_invisiable(ob) then
					local known=aliveai.getknown(self,ob)
					local enemy
					if (en and en.type=="monster" or aliveai.is_bot(ob)) or ob:is_player() then
						enemy=true
					end

					if math.random(1,2)+i==1 then
						rndob=ob
					elseif (aliveai.team_fight==true or (en and en.type=="animal") or known=="fight") and (self.attacking==1 or enemy or known=="fight" or (known==nil and self.object:get_hp()<self.hp_max and not (self.attack_players==0 and ob:is_player()))) then

						if aliveai.team(ob)=="nuke" or (en and en.mindamage and en.mindamage>self.dmg and not self.tools) then
							aliveai.flee_from(self,ob)
							return self
						end

						self.temper=2
						self.fight=ob
						self.on_detect_enemy(self,self.fight)
						if enemy or known=="fight" or math.random(1,3)==1 then
							aliveai.sayrnd(self,"come here")
							return self
						end
					elseif known=="come" then
						self.zeal=2
						self.come=ob
						return self
					elseif known=="fly" then
						self.temper=-0.3
						self.fly=ob
						aliveai.sayrnd(self,"ahh")
						aliveai.searchhelp(self)
						return self
					elseif self.coming==1 and known=="member" and aliveai.distance(self,ob:get_pos())>7 then
						self.come=ob
						self.zeal=5
						return self
					end
				end
			end
			d=1
		end



end

aliveai.known=function(self,ob,typ)
	if not ob then return end
	if not self.known then self.known={} end
	local name
	if ob:is_player() then 
		name=ob:get_player_name()
	elseif ob:get_luaentity() and ob:get_luaentity().aliveai and ob:get_luaentity().botname then
		name=ob:get_luaentity().botname
	elseif ob:get_luaentity() then
		name=ob:get_luaentity().name
	else
		return ""
	end
	if typ~="" then
		self.known[name]=typ
	else
		self.known[name]=nil
	end
end

aliveai.getknown=function(self,ob,typ)
	if not ob then return "" end
	if not self.known then self.known={} end
	local name
	if ob:is_player() then 
		name=ob:get_player_name()
	elseif ob:get_luaentity() and ob:get_luaentity().aliveai and ob:get_luaentity().botname then
		name=ob:get_luaentity().botname
	elseif ob:get_luaentity() then
		name=ob:get_luaentity().name
	else
		return ""
	end
	if not typ then return self.known[name] end
	return self.known[name]==typ
end

aliveai.come=function(self)
	if self.zeal and self.zeal>0 then
		self.zeal=self.zeal-0.02
		if self.zeal<=0 then self.zeal=nil self.come=nil end
	elseif self.coming==1 and not self.come and math.random(1,40)==1 then
		local pos=aliveai.roundpos(self.object:get_pos())
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 50)) do
			local en=ob:get_luaentity()
			if en and en.aliveai and en.botname~=self.botname and en.team==self.team then
			if aliveai.distance(self,ob:get_pos())<self.distance then
				self.come=nil
				self.zeal=nil
				return
			end
				aliveai.known(self,ob,"come")
				self.come=ob
				self.zeal=3
			end
		end
	end
	if self.coming==1 and self.come and (self.come:get_luaentity() or self.come:is_player()) then
		local pos=aliveai.roundpos(self.object:get_pos())
		local cpos=aliveai.roundpos(self.come:get_pos())
		local d=aliveai.distance(self,cpos)
		local see=aliveai.visiable(self,cpos)
		pos.y=pos.y-1
-- path and see

		if self.come and self.path then
 -- makes the bot dont stuck into walls
			if (self.pathwait and self.pathwait<=self.pathn) then
				aliveai.exitpath(self)
				self.pathwait=nil
			elseif see and d<self.arm*2 and not self.pathwait then
				self.pathwait=self.pathn+2
				aliveai.path(self)
				return self
			else
				aliveai.path(self)
				return self
			end
-- path
		elseif self.come and self.done~="" then
			self.done=""
		end
-- search
		if d<50 and self.zeal>0 then
			if see then
-- walking to
				aliveai.rndwalk(self,false)
				if d>2 and not self.path then
					aliveai.lookat(self,cpos)
					aliveai.walk(self)
					return self
				elseif not self.path then
-- meet
					aliveai.stand(self)
					aliveai.lookat(self,cpos)
					if self.come_give then
						if self.come:is_player() then
							self.come:get_inventory():add_item("main", self.come_give .." "  .. self.come_give_num)
						elseif aliveai.is_bot(self.come) then
							aliveai.invadd(self.come:get_luaentity(),self.come_give,self.come_give_num)
						end
						aliveai.invadd(self,self.come_give,self.come_give_num*-1)
						self.come_give=nil
						self.come_give_num=nil
					end
					self.on_meet(self,self.zeal)
					aliveai.showstatus(self,"meet",1)
					aliveai.known(self,self.come,"")
					self.come=nil
					self.zeal=nil
					aliveai.searchobjects(self)
					aliveai.showstatus(self,"came",3)
					self.done="come"
					return self
				end

			else
-- create path
				local path=aliveai.creatpath(self,pos,cpos,d)
				if path then
					aliveai.rndwalk(self,false)
					self.path=path
					aliveai.path(self)
					aliveai.showstatus(self,"path",3)
					return self
				else
-- rnd walk
					self.zeal=self.zeal-0.01
					aliveai.rndwalk(self)
					return self
				end
			end
		else
-- abort come
			self.zeal=0
			aliveai.rndwalk(self,false)
			self.come=nil
			return self
		end
	end
	return nil
end

aliveai.flee_from=function(self,ob)
	if self.escape~=1 then return end
	self.time=self.otime
	aliveai.known(self,ob,"fly")
	self.fly=ob
	self.fight=nil
	self.temper=-3
	self.fight_hp=nil
	aliveai.sayrnd(self,"ahh","",1)
	aliveai.fly(self)
	return self
end

aliveai.fly=function(self)

	if self.fly and self.fly_path and self.path then
		aliveai.path(self)
		return self
	elseif self.fly and self.done~="" then
		self.done=""
		self.fly_path=nil
		aliveai.stand(self)
	elseif self.temper<0 then
		self.temper=self.temper+0.01
		if self.temper>=0 then
			self.temper=0
			self.fly=nil 
		elseif self.temper>-1 and self.object:get_hp()>=self.hp_max then
			self.temper=5
			self.fight=self.fly
			self.fly=nil
			self.time=self.otime
			return self
		end
	end

	if self.fly and self.temper<0 and aliveai.visiable(self,self.fly:get_pos()) then
		self.object:set_yaw(self.object:get_yaw()+3.14)
		if not aliveai.viewfield(self,self.fly) then return self end
		self.on_escaping(self,self.fly)
		local pos1=self.object:get_pos()
		local pos2=self.fly:get_pos()
		pos1.y=pos1.y-1
		aliveai.lookat(self,pos2)
		local yaw=self.object:get_yaw()+3.14
		self.object:set_yaw(yaw)
		aliveai.walk(self,2)
		aliveai.showstatus(self,"fly " .. self.temper,1)
		if math.random(1,5)==1 then
			aliveai.sayrnd(self,"ahh")
			aliveai.searchhelp(self)
		end
		for i=1,self.arm,1 do
			local zr=math.sin(yaw)*i
			local xr=math.cos(yaw)* (i*-1)
			local zl=zr*-1
			local xl=xr*-1
			local z=self.move.z
			local x=self.move.x
			if aliveai.def({x=pos1.x+xr+x,y=pos1.y,z=pos1.z+zr+z},"walkable")==false 
			and aliveai.def({x=pos1.x+xr+x,y=pos1.y+1,z=pos1.z+zr+z},"walkable")==false
			and not aliveai.visiable({x=pos1.x+xr+x,y=pos1.y+1,z=pos1.z+zr+z},self.fly:get_pos()) then
				local path=aliveai.creatpath(self,pos1,{x=pos1.x+math.floor(xr+x+0.5),y=pos1.y,z=pos1.z+math.floor(zr+z+0.5)})
				if path then
					self.path=path
					self.fly_path=1
					aliveai.path(self)
					aliveai.showstatus(self,"hide",3)
					return self
				end
			elseif aliveai.def({x=pos1.x+xl+x,y=pos1.y,z=pos1.z+zl+z},"walkable")==false 
			and aliveai.def({x=pos1.x+xl+x,y=pos1.y+1,z=pos1.z+zl+z},"walkable")==false
			and not aliveai.visiable({x=pos1.x+xl+x,y=pos1.y+1,z=pos1.z+zl+z},self.fly:get_pos()) then
				pos1=aliveai.roundpos(pos1)
				local path=aliveai.creatpath(self,pos1,{x=pos1.x+math.floor(xl+x+0.5),y=pos1.y,z=pos1.z+math.floor(zl+z+0.5)})
				if path then
					self.path=path
					self.fly_path=1
					aliveai.path(self)
					aliveai.showstatus(self,"hide",3)
					return self
				end
			end
		end
		local mx=self.move.x/2
		local mz=self.move.z/2
		if aliveai.def({x=pos1.x+mx,y=pos1.y+1,z=pos1.z+mz},"walkable") and
		aliveai.def({x=pos1.x+mx,y=pos1.y+2,z=pos1.z+mz},"walkable") then
			local x=pos1.x+mx
			local z=pos1.z+mz
			for i=0,self.distance,1 do
				local p1={x=x,y=pos1.y+i,z=z}
				if aliveai.def(p1,"walkable")==false
				and aliveai.def({x=x,y=pos1.y+i+1,z=z},"walkable")==false
				and aliveai.def({x=pos1.x,y=pos1.y+i,z=pos1.z},"walkable")==false
				and aliveai.def({x=pos1.x,y=pos1.y+i+1,z=pos1.z},"walkable")==false then
					local path=aliveai.creatpath(self,pos1,p1,self.distance)
					if path then
						aliveai.rndwalk(self,false)
						self.path=path
						self.fly_path=1
						aliveai.path(self)
						return self
					end
					break
				end
			end
			local r={}
			r[1]=aliveai.random(yaw-2.5,yaw)
			r[2]=aliveai.random(yaw,yaw+2.5)
			self.object:set_yaw(r[aliveai.random(1,2)])
			aliveai.walk(self,2)
			return self
		end
		return self
	end
	return nil
end

aliveai.fight=function(self)
	if self.temper>0 then
		self.temper=self.temper-0.02
		if self.temper<=0 or (self.fight and aliveai.gethp(self.fight)<=0) then
			self.temper=0
			self.fight=nil
			self.backup=nil
			self.time=self.otime
			self.seen=nil
		end
	end

	if self.fighting==1 and (self.fight and (self.fight:get_luaentity() or self.fight:is_player())) then
		if self.fight_hp==nil then self.fight_hp=self.object:get_hp()/2 end
		local pos=aliveai.roundpos(self.object:get_pos())
		local fpos=aliveai.roundpos(self.fight:get_pos())
		local d=aliveai.distance(self,fpos)
		local see=aliveai.visiable(self,fpos)
		local vy
		if self.fight:get_luaentity() then
			vy=self.fight:get_velocity().y
		else
			vy=self.fight:get_player_velocity().y
		end
		pos.y=pos.y-1
-- fly from
		if self.escape==1 and self.object:get_hp()<self.fight_hp then
			aliveai.flee_from(self,self.fight)
			aliveai.searchhelp(self)
			return self
		end
-- path and see
		if self.fight and self.path then
 -- makes the bot dont stuck into walls
			if self.pathwait and self.pathwait<=self.pathn then
				aliveai.exitpath(self)
				self.pathwait=nil
			elseif see and d<self.arm*2 and not self.pathwait then
				self.pathwait=self.pathn+2
				aliveai.path(self)
				return self
			else
				aliveai.path(self)
				return self
			end
-- path
		elseif self.fight and self.done~="" then
			self.done=""
		end
		self.time=self.otime
-- search
		if d<self.distance and self.temper>0 then
		self.on_detecting_enemy(self)
			if see and self.seen or aliveai.viewfield(self,self.fight) then
				self.seen=true
				if aliveai.is_invisiable(self.fight) then
					self.fight=nil
					return
				end

-- attack
				aliveai.rndwalk(self,false)
				if d>self.arm and vy>-2 then
					aliveai.lookat(self,fpos)
					aliveai.walk(self,2)
					if self.tool_see==1 and aliveai.random(1,self.tool_chance)==1 then
						aliveai.use(self)
					end
					aliveai.showstatus(self,"attack",1)
					if math.random(1,100)==1 then
						aliveai.sayrnd(self,"come here")
					end
					return self
				else
-- fight
					self.time=0.2
					aliveai.stand(self)
					aliveai.lookat(self,fpos)
					self.on_fighting(self,self.fight)

					if self.type=="npc" and aliveai.is_bot(self.fight) and self.fight:get_luaentity().mindamage>self.dmg then
						aliveai.flee_from(self,self.fight)
						return self
					end

					if aliveai.random(1,math.floor(6-self.temper)+0.5)==1 then
						self.on_punching(self,self.fight)
						if self.tool_near==1 and aliveai.random(1,self.tool_chance)==1 then
							aliveai.use(self)
						else
							aliveai.anim(self,"mine")
							aliveai.punch(self,self.fight,self.dmg)
							self.on_punch_hit(self,self.fight)
						end
						local hp=aliveai.gethp(self.fight)
						if hp<=0 then
							aliveai.known(self,self.fight,"")
							self.fight=nil
							self.fight_hp=nil
							self.backup=nil
							self.time=self.otime
							aliveai.stand(self)
							aliveai.sayrnd(self,"got you")
						elseif not self.backup then
							self.backup=1
							aliveai.searchhelp(self)
						end
						return self
					elseif self.smartfight==1 and self.temper>1 then
						local yaw=self.object:get_yaw()
						aliveai.lookat(self,fpos)
						self.object:set_yaw(aliveai.random(yaw*0.5,yaw*1.5))
						aliveai.walk(self,2)
						if math.random(1,3)==1 and self.object:get_velocity().y==0 then
							self.object:set_velocity({x = self.move.x*4, y = 5.2, z =self.move.z*4})
						elseif math.random(1,3)==1 then
							local yu1={x=fpos.x,y=fpos.y-2,z=fpos.z}
							local ny1=minetest.get_node(yu1)
							local ny2=minetest.get_node({x=fpos.x,y=fpos.y-3,z=fpos.z})
							if ny1 and ny2 and aliveai.def(ny2.name,"walkable")==false and aliveai.def(ny1.name,"walkable") then
								aliveai.dig(self,yu1) 
							end
						end
						return self
					end
					aliveai.showstatus(self,"punch " .. self.temper,1)
					return self
				end
-- if not see
			else
				self.seen=nil
-- create path
				local path=aliveai.creatpath(self,pos,fpos,d)
				if path then
					aliveai.rndwalk(self,false)
					self.path=path
					aliveai.path(self)
					aliveai.showstatus(self,"path",3)
					return self
				else
-- rnd walk
					aliveai.rndwalk(self)
					return self
				end
			end
		else
-- abort fight
			self.temper=0
			aliveai.rndwalk(self,false)
			self.time=self.otime
			self.fight=nil
			self.backup=nil
			return self
		end
	end
	return nil
end

aliveai.findspace=function(self)
	if self.task=="build" then
		if self.path then
			aliveai.path(self)
			return self
		else
			aliveai.rndwalk(self)
		end
		aliveai.rndwalk(self,false)
		local pos=self.object:get_pos()
		pos.y=pos.y+0.5
		pos=aliveai.roundpos(pos)
		if math.random(1,5)==1 and self.done~="findspace" then
			if not self.build_x  then
				aliveai.showstatus(self,"Error: void build_x")
				aliveai.kill(self)
				return self
			end
			local look_for_free_space=aliveai.lookforfreespace(pos,self.build_x,self.build_x+10,self.build_x,self.build_y)
			if look_for_free_space then
				local path=aliveai.creatpath(self,pos,look_for_free_space,self.build_x+10)
				if path then
					aliveai.showstatus(self,"found space, goto",3)
					self.path=path
					self.done="findspace"
					aliveai.path(self)
				end
			end
		end
		if self.done~="findspace" and not aliveai.checkarea({x=pos.x,y=pos.y-1,z=pos.z},"air",self.build_x,1) and aliveai.checkarea(pos,"air",self.build_x,self.build_y) then
			aliveai.showstatus(self,"found space",3)
			self.done="findspace"
			self.taskstep=self.taskstep+1
			self.findspace=nil
			aliveai.stand(self)
		end
	end
	return self
end

aliveai.build=function(self)
	if not self.build then
		return self
	end
	local pos=aliveai.roundpos(self.object:get_pos())
	if not self.build.path then
		if type(self.build_pos)~="table" then
			self.build_pos=pos
		end
		self.build.path=aliveai.buildpath(self)
		if self.build.path==nil then
			self.build_step=0
			aliveai.showstatus(self,"buildpath mess, restart process")
		end
		return self
	end
	if self.path then
		local p=aliveai.path(self)
		if p==nil then
			aliveai.rndwalk(self)
			if math.random(1,5)==1 then
				aliveai.exitpath(self)
			end
			aliveai.showstatus(self,"path rnd")
			return self
		end
		if math.random(1,5)==1 and aliveai.distance(self,self.build.path[self.build_step].pos)<=self.arm then
			aliveai.exitpath(self)
			self.done="path"
			aliveai.rndwalk(self,false)
			aliveai.showstatus(self,"path skip")
		end
		return self
	end
	if self.done=="path" and self.build then
-- reset
		aliveai.rndwalk(self,false)
		self.time=self.otime
		self.rnd=0
		self.done=""
		aliveai.stand(self)
-- check if can place, or ignore or exit building
		if not aliveai.invhave(self,self.build.path[self.build_step].node,1) then
			local node1=self.build.path[self.build_step].node
			local node2=self.build.path[self.build_step].node
			if node1==node2 then
				self.ignore_item[node1]=1
				self.build_step=self.build_step+1
				aliveai.showstatus(self,"ignore " .. node1)
			else
				self.build_type=""
				self.build.path={} --[self.build_step]
				aliveai.showstatus(self,"abort building, no enough materials")
				return self
			end
			if not self.build.path[self.build_step] or self.build.path[self.build_step].node~=node1 then return self end
		end
-- keep build
		aliveai.lookat(self,self.build.path[self.build_step].pos)
		local place=aliveai.place(self,self.build.path[self.build_step].pos,self.build.path[self.build_step].node)
		if self.build.skiptolater then
			self.build.skiptolatercurr=self.build_step
			self.build_step=self.build.skiptolater
			self.build.skiptolater=nil
			aliveai.showstatus(self,"place last")
		elseif self.build.skiptolatercurr then
			self.build_step=self.build.skiptolatercurr
			self.build.skiptolatercurr=nil
		else
			self.build_step=self.build_step+1
		end
	end
	if not self.build.path[self.build_step] or not self.build.path[self.build_step].pos then
		aliveai.showstatus(self,"build done",3)
		aliveai.stand(self)
		self.build=nil
		self.done="build"
		self.taskstep=self.taskstep+1
		return self
	end

	if aliveai.distance(self,self.build.path[self.build_step].pos)<=self.arm or self.superbuild==1 then
		aliveai.rndwalk(self,false)
		self.time=0.2
		aliveai.stand(self)
		self.done="path"
		return self
	end
		local ii=self.build_step
		for i=ii,ii+1000,1 do
			if self.build.path[i] then
				if not self.ignore_item[self.build.path[i].node] then
					self.build_step=i
					break
				end
			else
				self.build_step=i
				return self
			end
		end
	local pn=aliveai.neartarget(self,self.build.path[self.build_step].pos,1,0)
		if pn~=nil then
		aliveai.showpath(pn,3)
		local p=aliveai.creatpath(self,pos,self.build.path[self.build_step].pos)
		aliveai.showstatus(self,"find path")
		if p~=nil then
			aliveai.showstatus(self,"path")
			self.path=p
			return self
		else
			aliveai.showstatus(self,"find path rnd " .. self.rnd,1)
			aliveai.buildproblem(self)
			return self
		end
	else
		aliveai.showstatus(self,"find near target, rnd " .. self.rnd,1)
		aliveai.buildproblem(self)
		return self
	end
	return self
end

aliveai.buildproblem=function(self)
	self.rnd=self.rnd+1
	if aliveai.distance(self,self.build.path[self.build_step].pos)<=self.arm then -- if near the node
		aliveai.stand(self)
		self.done="path"
		return self
	end
	if self.rnd>=4 then
		self.rnd=0
		if self.build.skiptolater then -- skip old node
			self.build_step=self.build_step+1
			self.build.skiptolater=nil
			aliveai.showstatus(self,"skip old node",1)

			return self
		end
		aliveai.showstatus(self,"skip to later")
		self.build.skiptolater=self.build_step -- skip node to later
		self.build_step=self.build_step+1
		self.mood=self.mood-1
		return self
	end

	aliveai.rndwalk(self)
	return self
end

aliveai.mineproblem=function(self)
	if not self.ignoreminechange then
		aliveai.showstatus(self,"Error: void ignoremine")
		aliveai.kill(self)
		return self
	end
	if self.ignoremineitem=="" or not self.need[self.ignoremineitem] then
		local item
		for name, need in pairs(self.need) do
			item=need.item
			break
		end
		if not item then self.need=nil end
		self.ignoremineitem=item
		self.ignoreminetime=0
		self.ignoreminechange=aliveai.invhave(self,item,0,true)
	end
	self.ignoreminetime=self.ignoreminetime+1
	if self.ignoreminetime>self.ignoreminetimer then
		if self.ignoreminechange==aliveai.invhave(self,self.ignoremineitem,0,true) then	--if time out and dont have more
			self.ignore_item[self.ignoremineitem]=1
			self.mood=self.mood-1
			self.need[self.ignoremineitem]=nil
			aliveai.showstatus(self,"ignoring item: " .. self.ignoremineitem)
			if #self.need==0 then self.need=nil end
		end
		self.ignoreminetime=0
		self.ignoremineitem=""
	end
	return self
end

aliveai.mine=function(self)
  if 1 then
    return
  end
	if not self.need then
		self.mine.target=self.object:get_pos()
		self.mine.status="dig"
	end
	if not self.ignoreminetime then
		aliveai.showstatus(self,"Error: void ignoremine timer")
		aliveai.kill(self)
		return self
	end
	local pos=self.object:get_pos()
--search-------------------------------------
	if not self.path and self.mine.status=="search" then
		if math.random(1,5)~=1 then return self end
--look for needed nodes
		aliveai.showstatus(self,"searching")
		aliveai.mineproblem(self)
		if not self.need then
			self.mine.target=self.object:get_pos()
			self.mine.status="dig"
			return self
		end
		for _, need in pairs(self.need) do
			local p
			if need.type=="node" and need.search~="" then
				p=aliveai.findnode(self,need.search,self.mine.ignore)
					aliveai.showstatus(self,"need: " .. need.item .." " .. need.num .." search " ..need.search .." have: " .. aliveai.invhave(self,need.item,0,true).." time: " .. self.ignoreminetime)
			end
			if aliveai.invhave(self,need.item,need.num) then
				if aliveai.haveneed(self) then
					self.mine.status="search"
					return self
				else
					self.mine=nil
					self.done="mine"
					self.taskstep=self.taskstep+1
					aliveai.stand(self)
					aliveai.showstatus(self,"mine done",3)
					self.mood=self.mood+5
					return self
				end
			else
				aliveai.showstatus(self,"need: " .. need.item .." " .. need.num .." search " ..need.search .." have: " .. aliveai.invhave(self,need.item,0,true).." time: " .. self.ignoreminetime)
			if math.random(1,1000)==1 then
				if need.search=="" then
					aliveai.say(self,"i need " .. need.item .. " " .. need.num)
				else
					aliveai.say(self,"i need " .. need.item .." " .. need.num.. " " ..  " or " .. need.search)
				end
			end
			end
			if p and p.pos then
				if aliveai.distance(self,p.pos)<self.arm and aliveai.visiable(self,p.pos) then
					self.time=self.otime
					self.done="path"
					self.mine.status="dig"
					self.mine.target=p.pos
					aliveai.rndwalk(self,false)
					break
				end
				self.path=p.path
				self.mine.target=p.pos
				self.mine.status="goto"
				aliveai.showstatus(self,"path")
				aliveai.rndwalk(self,false)
				break
			elseif p then
				self.mine.ignore=p
			end
		end
		if self.mine.status=="search" then
			aliveai.rndwalk(self)
			return self
		end
	end
--goto-------------------------------------
	if self.mine.status=="goto" then

		local p=aliveai.path(self)
		if p==nil or self.path==nil then
			aliveai.exitpath(self)
			self.mine.status="search"
			aliveai.showstatus(self,"path failed")
			self.mood=self.mood-1
			return self
		end


		if aliveai.visiable(self,self.mine.target) and
		(self.done=="path" and aliveai.distance(self,self.mine.target)<self.arm) or
		(math.random(1,10)==1 and aliveai.distance(self,self.mine.target)<self.arm) then
			self.time=self.otime
			self.done=""
			self.mine.status="dig"
			self.mood=self.mood+1
			aliveai.exitpath(self)
		end
	end
--dig-------------------------------------
	if self.mine.status=="dig" then
		self.resources=self.mine.target
		aliveai.stand(self)
		aliveai.lookat(self,self.mine.target)

		if not self.mine.delay then self.mine.delay=0 end
		if self.mine.delay<1 then
			self.mine.delay=self.mine.delay+0.5
			return self
		end
		self.mine.delay=0

		aliveai.dig(self,self.mine.target)
		if aliveai.haveneed(self) then
			self.mine.status="search"
			self.mood=self.mood+1
		else
			self.mood=self.mood+5
			self.mine=nil
			self.ignore_item={}
			self.done="mine"
			self.taskstep=self.taskstep+1
			aliveai.showstatus(self,"mine done",3)
		end
	end
	return self
end

aliveai.exitpath=function(self)
	self.time=self.otime
	self.pathn=1
	self.path=nil
	self.path_bridge=nil
	self.path_tower=nil
	self.path_timer=nil
	aliveai.stand(self)
	return self
end

aliveai.path=function(self)
	self.time=self.otime
	if self.path then
	if not self.path_timer then self.path_timer=0 end
		self.path_timer=self.path_timer+1
		self.time=0.1
		local pos=self.object:get_pos()
		pos.y=pos.y-(self.basey)
		if not self.path_bridge and aliveai.samepos(aliveai.roundpos(pos),self.path[self.pathn]) then
			if self.path[self.pathn] then
			self.path_timer=0
-- build tower
				if self.path_tower and self.path[self.pathn+1] and self.path[self.pathn+1].y>pos.y
				and self.path[self.pathn+2] and self.path[self.pathn+2].y>pos.y
				and self.path[self.pathn+2].x==pos.x and self.path[self.pathn+2].z==pos.z then
					aliveai.stand(self)
					local stuff=self.path_tower
					if stuff=="" then
						for i, v in pairs(self.inv) do
							if minetest.registered_nodes[i] and minetest.registered_nodes[i].walkable then
								stuff=i
								break
							end
						end
					end
					if aliveai.place(self,pos,stuff) then 
						self.pathn=self.pathn+1
					else
						self.path_tower=nil
					end
					return self
				elseif self.path_tower and self.path[self.pathn+2]==nil then
					aliveai.exitpath(self)
					return self
				end
--if path blocked
				local n=minetest.get_node(self.path[self.pathn]).name
				aliveai.lookat(self,self.path[self.pathn])
				aliveai.walk(self)
				self.pathn=self.pathn+1
				local nn=self.path[self.pathn]
				if nn==nil then return self end
				if aliveai.def(nn,"walkable") or (self.visual=="mesh" and aliveai.def({x=nn.x,y=nn.y+1,z=nn.z},"walkable")) then
					if aliveai.group({x=nn.x,y=nn.y-1,z=nn.z},"aliveai_door")>0 then
						self.path[self.pathn]={x=nn.x,y=nn.y-1,z=nn.z}
						aliveai.open_door(self,self.path[self.pathn])
						return true
					end
					aliveai.exitpath(self)
					aliveai.showstatus(self,"path blocked")
					self.object:set_yaw(math.random(0,6.28))
					aliveai.walk(self)
					self.mood=self.mood-1
					return 
				end
			end
		elseif self.path[self.pathn]==nil then
			self.done="path"
			aliveai.exitpath(self)
		else
			local pos=self.object:get_pos()
			if aliveai.def(pos,"climbable") then
				aliveai.stand(self)
				self.path_timer=0
				return self
			elseif self.path_timer>30 then
				aliveai.jumping(self)
				if not self.path_timer then self.path_timer=0 end
				if self.path_timer>60 then
					aliveai.exitpath(self)
					aliveai.showstatus(self,"path timeout")
					return self
				end
				aliveai.showstatus(self,"path problem")
			elseif self.path[self.pathn] and self.path[self.pathn].y>pos.y+3 then
				aliveai.exitpath(self)
				aliveai.showstatus(self,"fell from path")
			elseif self.path_bridge and self.path[self.pathn] then
-- bridge
				pos=self.object:get_pos()
				pos=aliveai.roundpos(pos)
				pos.y=pos.y-1
				local p3=self.path[self.pathn]
				if self.object:get_velocity().y==0 and aliveai.def({x=p3.x,y=p3.y-1,z=p3.z},"walkable")==false then
					local stuff=self.path_bridge
					if stuff=="" then
						for i, v in pairs(self.inv) do
							if minetest.registered_nodes[i] and minetest.registered_nodes[i].walkable then
							stuff=i
							break
							end
						end
					end
					aliveai.place(self,{x=p3.x,y=p3.y-1,z=p3.z},stuff)
				end
				if aliveai.samepos(pos,p3) then
						aliveai.stand(self)
						self.pathn=self.pathn+1
						self.path_timer=0
						return self
				else
					if p3.y>pos.y then
						aliveai.jump(self)
					end
					aliveai.lookat(self,p3)
					aliveai.walk(self)
				end
				return self
			else
				if self.path_tower and self.path[self.pathn].y>pos.y then
					return self
				end
				aliveai.lookat(self,self.path[self.pathn])
				aliveai.walk(self)
			end
		end
		return self
	else
		return self
	end
end


