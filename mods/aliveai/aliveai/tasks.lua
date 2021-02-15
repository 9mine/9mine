aliveai.savedata.taskbuild=function(self)
	if self.task=="build" then
		return {
			house=self.house,
			build_step=self.build_step,
			build_x=self.build_x,
			build_y=self.build_y,
			build_z=self.build_z,
			build_pos=self.build_pos,
			ignoremineitem=self.ignoremineitem,
			ignoreminechange=self.ignoreminechange,
			ignoreminetime=self.ignoreminetime,
			ignoreminetimer=self.ignoreminetimer,
		}
	end
end

aliveai.loaddata.taskbuild=function(self,r)
	if self.task=="build" then
		self.house=r.house
		self.build_step=r.build_step
		self.build_x=r.build_x
		self.build_y=r.build_y
		self.build_z=r.build_z
		self.build_pos=r.build_pos
		self.ignoremineitem=r.ignoremineitem
		self.ignoreminetime=tonumber(r.ignoreminetime)
		self.ignoreminetimer=tonumber(r.ignoreminetimer)
		self.ignoreminechange=tonumber(r.ignoreminechange)
	end
	return self
end

aliveai.task_farming=function(self)
	if aliveai.farming and self.home and self.type=="npc" then
		if not self.farming and aliveai.distance(self,self.home)<self.distance*1.5 then
			local name
			local c=0
			for i, v in pairs(aliveai.farming) do
				c=((v.area*2)+1)*((v.area*2)+1)
				if self.creative==1 or (self.inv[v.seed] and self.inv[v.seed]>=c) then
					name=i
					break
				elseif not (self.need and self.need[v.seed]) then
					aliveai.add_mine(self,v.dig,c,v.seed)
				end
			end
			local p=aliveai.roundpos(self.object:get_pos())
			if not name or minetest.get_item_group(minetest.get_node({x=p.x,y=p.y-2,z=p.z}).name, aliveai.farming[name].ground_group)==0 then return end
			c=math.floor(c/2)*-1
			local a=aliveai.farming[name].area
			local paths={}
			for x=-a,a,1 do
			for z=-a,a,1 do
				local p1={x=p.x+x,y=p.y-1,z=p.z+z}
				local n=minetest.registered_nodes[minetest.get_node(p1).name]
				if p1 and n and n.buildable_to and not n.next_plant and
				minetest.get_node_light(p1)>14 and
				minetest.get_item_group(minetest.get_node({x=p.x+x,y=p.y-2,z=p.z+z}).name, "soil")>0 then
					table.insert(paths,p1)
					aliveai.showpath(p1,1)
				else
					aliveai.showpath(p1,3)
					c=c+1
					if c>0 then return end
				end
			end
			end
			self.farming_name=name
			self.farming=paths
			self.tmpfunc=self.step
			self.step=aliveai.task_farming
			self.time=0.5
			return self
		elseif self.farming then
			local p=self.farming[1]
			if p then
				local place=aliveai.farming[self.farming_name].seed
				local set=aliveai.farming[self.farming_name].ground
				local w=aliveai.roundpos(self.object:get_pos())
				aliveai.lookat(self,p)
				if aliveai.samepos(p,{x=w.x,y=w.y-1,z=w.z}) then
					set=aliveai.farming[self.farming_name].source
				else
					aliveai.place(self,p,place)
					minetest.get_node_timer(p):start(math.random(166, 286))
					minetest.swap_node(p,{name=place,param2=1})

				end
				minetest.set_node({x=p.x,y=p.y-1,z=p.z},{name=set})
				table.remove(self.farming,1)
				return self
			else
				self.controlled=nil
				self.farming_name=nil
				self.farming=nil
				self.step=self.tmpfunc
				self.tmpfunc=nil
				aliveai.exitpath(self)
				return self
			end
		end
	end
end

aliveai.task_stay_at_home=function(self)
	if self.home then
		if self.path then 
			aliveai.path(self)
			return self
		end
		if math.random(1,10)==1 then
			local d=aliveai.distance(self,self.home)
			if d>self.distance*3 then
				aliveai.showstatus(self,"teleport home")
				self.object:set_pos(self.home)
				return self
			elseif d>self.distance*1.5 then
				local pos=self.object:get_pos()
				local p=aliveai.creatpath(self,pos,aliveai.roundpos(self.home))
				if p~=nil then
					self.path=p
					aliveai.showstatus(self,"go home")
					return self
				else
					local p=aliveai.neartarget(self,self.home,1,-10)
					if p then
						self.path=p
						self.home=p
						aliveai.showstatus(self,", change home pos, go home")
						return self
					end
				end
			end
		end
	end
end

aliveai.task_build=function(self)
		if self.building~=1 or self.home then return end
		if aliveai.enable_build==true and self.task=="" then			--setting up for build a home
			aliveai.showstatus(self,"set up for build a home")
			self.build_step=1
			self.build_pos=""
			self.task="build"
			self.ignoremineitem=""
			self.ignoreminetime=0
			self.ignoreminetimer=200
			self.ignoreminechange=0
			self.taskstep=0
			aliveai.rndwalk(self,false)				-- stop rnd walking
		end
		if self.path and self.done=="" and self.tmpgoto then			-- path
			aliveai.path(self)
			self.tmpgoto=self.tmpgoto+1
			if self.tmpgoto>=20 then 
				aliveai.exitpath(self)
				aliveai.showstatus(self,"path failed, mine")
			end
		end
		if self.taskstep<1 then		--if need to dig
			aliveai.buildpath(self,true) -- get need info
			if aliveai.haveneed(self) then
				self.done=""
				if self.resources then
					local pos=self.object:get_pos()
					pos.y=pos.y+1
					local p=aliveai.creatpath(self,pos,self.resources,20)
					if p then
						self.path=p
						aliveai.showstatus(self,"go to resources and mine",4)
						return self
					end

				end
				self.mine={target={},status="search"}
				aliveai.showstatus(self,"mine",4)
			else
				self.taskstep=1
			end
			return self
		end
		if self.taskstep==1 then			-- mine done: find space
			self.findspace=true
			self.done=""
			aliveai.showstatus(self,"findspace",4)
			return self
		end
		if self.taskstep==2 then		-- findspace done: build
			self.build={}
			self.done=""
			aliveai.showstatus(self,"build",4)
			return self
		end
		if self.taskstep==3 then			-- build building done, clear status
			if not self.home then		-- set home if it was a house
				local pos=self.object:get_pos()
				pos.y=pos.y+1
				self.home=pos
				aliveai.showstatus(self,"home set, build done",3)
			else
				aliveai.showstatus(self,"status build done",3)
			end
			self.mine=nil
			self.need=nil
			self.ignore_item={}
			self.done=""
			self.task=""
			self.build_step=nil
			self.build_x=nil
			self.build_y=nil
			self.build_z=nil
			self.build_pos=nil
			self.house=nil
			self.taskstep=0
			return self
		end
end

