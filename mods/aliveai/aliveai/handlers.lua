aliveai.sitchair=function(self,pos)
	pos=aliveai.roundpos(pos)
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1)) do
		if aliveai.is_bot(ob) and  ob:get_luaentity().sleeping then return end
	end
	local p,y=aliveai.param2_to_xzyaw(pos)
	aliveai.sleep(self,2)
	aliveai.anim(self,"sit")
	self.sleeptimer=math.random(20,200)
	self.object:set_pos({x=pos.x+(p.x*-0.05),y=pos.y+1,z=pos.z+(p.z*-0.05)})
	self.object:set_yaw(y)
	aliveai.showstatus(self,"sit")
	return self
end
minetest.after(1, function()
	aliveai.nodes_handler["aliveai:chair"]=aliveai.sitchair
end)

aliveai.drive_vehicle=function(self,pos,vehicle,p)
	if not self.inv[vehicle] or self.object:get_attach() then return end
	local n

	if minetest.registered_craftitems[vehicle] and minetest.registered_craftitems[vehicle].on_place then
		n=minetest.registered_craftitems[vehicle]
	elseif minetest.registered_tools[vehicle] and minetest.registered_tools[vehicle].on_place then
		n=minetest.registered_tools[vehicle]
	elseif minetest.registered_nodes[vehicle] and minetest.registered_nodes[vehicle].on_place then
		n=minetest.registered_nodes[vehicle]
	else
		return
	end
	aliveai.invadd(self,vehicle,-1)
	aliveai.showstatus(self,"use " .. vehicle)
	local user=aliveai.createuser(self)
	user.get_player_control=aliveai.re({sneak=false,up=true,down=false,left=false,right=false})
	n.on_place(ItemStack(vehicle),user,{type="node",under=pos,above=pos})

	local v
	local en
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
		en=ob:get_luaentity() 
		if en and en.name==vehicle then
			v=ob
			en.on_rightclick(en, user)
			break
		end
	end
	if not v then return end

	self.object:set_attach(v, "",p or {x=0,y=10,z=0}, {x=0,y=0,z=0})
	self.controlled=1
	aliveai.stand(self)
	aliveai.anim(self,"sit")

	local tr={true,false}
	local r=0
	local rn=0
	for i=1,10,1 do
		r=aliveai.random(i*5,i*10)
		minetest.after(r, function(self,tr,v,user)
			if self and self.object and self.object:get_luaentity() and v:get_luaentity() then
				user.get_player_control=aliveai.re({
					sneak=false,
					up=true,
					down=false,
					left=tr[aliveai.random(1,2)],
					right=tr[aliveai.random(1,2)]
				})
			end
		end,self,tr,v,user)
		minetest.after(r+aliveai.random(1,5), function(self,r,v,user)
			if self and self.object and self.object:get_luaentity() and v:get_luaentity() then
				local p=aliveai.roundpos(v:get_velocity())
				if i>9 or (p and p.x+p.z==0) then
					en.on_rightclick(en, user)
					self.object:set_detach()
					aliveai.anim(self,"stand")
					self.controlled=nil
					aliveai.invadd(self,vehicle,1)
					v:remove()
					self.object:set_acceleration({x=0,y=-10,z =0})
				else
					user.get_player_control=aliveai.re({sneak=false,up=true,down=false,left=false,right=false})
				end
			end
		end,self,r,v,user)
	end
end



if minetest.get_modpath("carts") then
	aliveai.cart=function(self,pos)
		if not self.inv["carts:cart"] or self.object:get_attach() then return end
		aliveai.invadd(self,"carts:cart",-1)
		aliveai.showstatus(self,"use cart")
		local user=aliveai.createuser(self)
		minetest.registered_craftitems["carts:cart"].on_place(ItemStack("carts:cart"),self,{type="node",under={x=pos.x,y=pos.y+0.5,z=pos.z},above={x=pos.x,y=pos.y+0.5,z=pos.z}})

		local cart
		local en

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			en=ob:get_luaentity() 
			if en and en.name=="carts:cart" then
				cart=ob
				en.on_rightclick(en, user)
				break
			end
		end
		if not cart then return end

		self.object:set_attach(cart, "",{x=0,y=5,z=-2}, {x=0,y=0,z=0})
		self.controlled=1
		aliveai.stand(self)
		aliveai.anim(self,"sit")

		local rnddir={{x=10,y=0,z =0},{x=-10,y=0,z =0},{x=0,y=0,z =10},{x=0,y=0,z =-10}}

		local dir=rnddir[math.random(1,4)]
		local r=0
		for i=1,10,1 do
			r=aliveai.random(i*2,i*5)
			minetest.after(r, function(self,cart,en)
				if self and self.object and self.object:get_luaentity() and cart:get_luaentity() then
					local p=aliveai.roundpos(cart:get_velocity())
					if i>2 and ((p and p.x+p.z==0) or i==10)  then
						self.object:set_detach()
						aliveai.anim(self,"stand")
						self.controlled=nil
						aliveai.invadd(self,"carts:cart",1)
						self.object:set_acceleration({x=0,y=-10,z =0})
						local cpos=cart:get_pos()
						self.object:set_pos({x=cpos.x,y=cpos.y+2,z =cpos.z})
						en.on_step=nil
						if en.sound_handle then minetest.sound_stop(en.sound_handle) end
						cart:remove()
					else
						local p1=aliveai.roundpos(cart:get_pos())
						if en.velocity.x>-1 and minetest.get_item_group(minetest.get_node({x=p1.x+1,y=p1.y,z=p1.z}).name, "connect_to_raillike")>0 then
							en.velocity={x=10,y=0,z=0}
						elseif en.velocity.x<1 and minetest.get_item_group(minetest.get_node({x=p1.x-1,y=p1.y,z=p1.z}).name, "connect_to_raillike")>0 then
							en.velocity={x=-10,y=0,z=0}
						elseif en.velocity.z>-1 and  minetest.get_item_group(minetest.get_node({x=p1.x,y=p1.y,z=p1.z+1}).name, "connect_to_raillike")>0 then
							en.velocity={x=0,y=0,z=10}
						elseif en.velocity.z<1 and minetest.get_item_group(minetest.get_node({x=p1.x,y=p1.y,z=p1.z-1}).name, "connect_to_raillike")>0 then
							en.velocity={x=0,y=0,z=-10}
						end
						en.punched=true
					end
				end
			end,self,cart,en)
		end
	end

	minetest.after(1, function()
		aliveai.nodes_handler["carts:rail"]=aliveai.cart
		aliveai.tools_handler["carts"]={try_to_craft=true,use=false,tools={"cart"}}
	end)
end


if minetest.get_modpath("boats") then
	aliveai.boat=function(self,pos)
		if not self.inv["boats:boat"] or self.object:get_attach() then return end
		aliveai.invadd(self,"boats:boat",-1)
		aliveai.showstatus(self,"use boat")

		local user=aliveai.createuser(self)
		user.get_player_control=aliveai.re({sneak=false,up=true,down=false,left=false,right=false})
		minetest.registered_craftitems["boats:boat"].on_place(ItemStack("boats:boat"),user,{type="node",under=pos})
		local boat
		local en
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			en=ob:get_luaentity() 
			if en and en.name=="boats:boat" then
				boat=ob
				en.on_rightclick(en, user)
				break
			end
		end
		if not boat then return end

		self.object:set_attach(boat, "",{x=0,y=11,z=-3}, {x=0,y=0,z=0})
		self.controlled=1
		aliveai.stand(self)
		aliveai.anim(self,"sit")

		local tr={true,false}
		local r=0
		for i=1,10,1 do
			r=aliveai.random(i*5,i*10)
			minetest.after(r, function(self,tr,boat,user)
				if self and self.object and self.object:get_luaentity() and boat:get_luaentity() then
					user.get_player_control=aliveai.re({
						sneak=false,
						up=true,
						down=false,
						left=tr[aliveai.random(1,2)],
						right=tr[aliveai.random(1,2)]
					})
				end
			end,self,tr,boat,user)
			minetest.after(r+aliveai.random(1,5), function(self,r,boat,user)
				if self and self.object and self.object:get_luaentity() and boat:get_luaentity() then
					local p=aliveai.roundpos(boat:get_velocity())
					if i>9 or (p and p.x+p.z==0) then
						en.on_rightclick(en, user)
						self.object:set_detach()
						aliveai.anim(self,"stand")
						self.controlled=nil
						aliveai.invadd(self,"boats:boat",1)
						boat:remove()
						self.object:set_acceleration({x=0,y=-10,z =0})
					else
						user.get_player_control=aliveai.re({sneak=false,up=true,down=false,left=false,right=false})
					end
				end
			end,self,r,boat,user)
		end

	end
	minetest.after(1, function()
		aliveai.nodes_handler["default:water_source"]=aliveai.boat
		aliveai.tools_handler["boats"]={try_to_craft=true,use=false,tools={"boat"}}
	end)
end



if aliveai.smartshop then
aliveai.use_smartshop=function(self)
	if self.smartshop and self.path then
		aliveai.path(self)
		if self.done=="path" or (math.random(1,10)==1 and aliveai.distance(self,self.smartshop.pos)<self.arm and aliveai.visiable(self,self.smartshop.pos)) then
			aliveai.exitpath(self)
			local pay=self.smartshop
			local inv=minetest.get_inventory({type="detached", name="main"})
			for i=1,inv:get_size("main"),1 do
				if inv:get_stack("main",i):get_count()==0 then
					inv:set_stack("main", i, ItemStack(pay.pay .. " " .. pay.count))
					break
				end
			end
			local user=aliveai.createuser(self)
			aliveai.invadd(self,pay.pay,-pay.count,true)
			smartshop.use_offer(pay.pos,user,pay.i)
			aliveai.clearinventory(self)
			self.smartshop=nil
			aliveai.showstatus(self,"pay: " ..  pay.pay .." " .. pay.count)
		end
		return self
	end
	if math.random(1,50)~=1 or self.smartshop then return end
	local np1=minetest.find_node_near(self.object:get_pos(), self.distance,{"smartshop:shop"})
	if np1 then
		local walkto
		local offer=smartshop.get_offer(np1)
		for i, v in pairs(offer) do
			if self.need then
				for ii, vv in pairs(self.need) do
				if (vv.item==v.give
				or (vv.search~="" and vv.search==v.give)
				or math.random(1,20)==1)
					and self.inv[v.pay] and self.inv[v.pay]>=v.pay_count then
					walkto={pos=np1,i=i,pay=v.pay,count=v.pay_count}
					break
				end
				end
			elseif math.random(1,3)==1 and v.pay~="" and self.inv[v.pay] and self.inv[v.pay]>=v.pay_count then
				walkto={pos=np1,i=i,pay=v.pay,count=v.pay_count}
				break
			end
		end	
		if walkto then
			aliveai.showstatus(self,"go to smartshop")
			local np2=aliveai.neartarget(self,np1,0)
			if np2 then
				local path=aliveai.creatpath(self,self.object:get_pos(),np2)
				if path then
					self.path=path
					self.smartshop=walkto
					return self
				end
			end
		end
	end
end
end


