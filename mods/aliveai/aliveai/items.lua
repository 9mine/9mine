minetest.register_tool("aliveai:book", {
	description = "Ai Book",
	range=15,
	inventory_image = "aliveai_book.png",
	on_use=function(itemstack, user, pointed_thing)
		local pos=user:get_pos()
		local name=user:get_player_name()
		local pos2=pointed_thing.under
		local item=itemstack:to_table()
		local save
		local meta=minetest.deserialize(item.metadata) or {bots={},selected="",pages=0,selected_num=0,user=name,description="Ai Book by ".. name}

		if meta.user==name then
			local bots={}
			for i, b in ipairs(meta.bots) do
				bots[b]=1
			end
			if pointed_thing.type=="node" and aliveai.group(pointed_thing.under,"aliveai")>0 and not bots[minetest.get_node(pointed_thing.under).name] then
				bots[minetest.get_node(pointed_thing.under).name]=1
				if meta.selected=="" then
					meta.selected=minetest.get_node(pointed_thing.under).name
				end
				save=true
			elseif pointed_thing.type=="object" and aliveai.is_bot(pointed_thing.ref) and not bots[pointed_thing.ref:get_luaentity().name] then
				bots[pointed_thing.ref:get_luaentity().name]=1
				meta.selected=pointed_thing.ref:get_luaentity().name
				save=true
			else
				for _, ob in ipairs(minetest.get_objects_inside_radius(pos,5)) do
					if aliveai.is_bot(ob) and not bots[ob:get_luaentity().name] and aliveai.visiable(pos,ob) then
						bots[ob:get_luaentity().name]=1
						meta.selected=ob:get_luaentity().name
						save=true
					end
				end
			end
			if save then
				local sbots={}
				local num=0
				for b, n in pairs(bots) do
					num=num+1
					table.insert(sbots,b)
					if meta.selected_num==0 and b==meta.selected then
						meta.selected_num=num
					end
					meta.pages=num
				end
				meta.bots=sbots
				item.meta={description="Ai Book by ".. name}
				minetest.chat_send_player(name, "Book: New content added")

				if aliveai.grant_invisiable==true and not meta.finished and meta.pages>=aliveai.loaded_objects then
					local p=minetest.get_player_privs(name)
					p.aliveai_invisibility=true
					minetest.set_player_privs(name, p)
					meta.finished=1
					minetest.chat_send_player(name, "Book: You have been granted aliveai_invisibility")
					minetest.chat_send_player(name, "Book: Ai's will not detect you when you are sneaking")
				end

				item.metadata=minetest.serialize(meta)
				itemstack:replace(item)
			end
		end
		aliveai.view_book(user,meta)
		return itemstack
	end,
})

aliveai.view_book=function(user,meta)
	table.sort(meta.bots)
	local list=""
	local c=""
	local name=user:get_player_name()
	local a=aliveai.registered_bots[meta.selected]
	for i, bot in ipairs(meta.bots) do
		list=list .. c .. bot
		c=","
	end

	local gui="size[10,8]"
	.."background[-0.2,-0.2;10.4,8.6;gui_formbg.png]"
	.. "label[8,0;Page: " .. meta.selected_num.. "/" .. meta.pages .. " (" .. aliveai.loaded_objects ..")]"
	.."dropdown[0,-0.1;3,1;list;" .. list.. ";" .. meta.selected_num .."]"
	.."button[3,-0.2;1,1;bac;<]"
	.."button[4,-0.2;1,1;fro;>]"

	if a then
		local light="light"
		local flying="true"
		local drops="none"
		local aggressive="false"
		if a.floating==0 then
			flying="false"
		end
		if a.attacking==1 then
			aggressive="true"
		end
		if a.light<0 then
			light="darknes"
		elseif a.light==0 then
			light="light and darknes"
		end
		if type(a.start_with_items)=="table" then
			drops=""
			local rit
			for it, c in pairs(a.start_with_items) do
				rit=it
				if minetest.registered_items[it] then
					rit=minetest.registered_items[it].description
				end
				drops=drops .. rit .." " .. c ..", "
			end
		end
		gui=gui
		.. "label[0,0.5;"
		.."Name: " .. a.name .."\n"
		.."Type: " .. a.type .."\n"
		.."Team: " .. a.team .."\n"
		.."Health: " .. a.hp .."\n"
		.."Damage: " .. a.dmg .."\n"
		.."Durability: " .. a.mindamage .."\n"
		.."Drops: " .. drops .."\n"
		.."Flying: " .. flying .."\n"
		.."Aggressive: " .. aggressive .."\n"
		.."Thrive in " .. light .."\n\n"
		.. a.description
		.."]"
		.."item_image[5.5,0.5;5,5;" .. a.item .. "]"
	else
		gui=gui .. "label[0,0.5;\nEmpty Ai Book\n\nPunch one or use the book near AI to add.\nBlocks too.]"
	end
	minetest.after(0, function(gui)
		return minetest.show_formspec(name, "aliveai.book",gui)
	end, gui)
end


aliveai.register_buildings_spawner=function(name,def)
	aliveai.buildings_spawners[minetest.get_current_modname() .. "." .. name]={
		name=name,
		mod=minetest.get_current_modname(),
		on_use=def.on_use,
		on_place=def.on_place
	}
end

minetest.register_tool("aliveai:buildings_spawner", {
	description = "Buildings spawner",
	range=15,
	inventory_image = "aliveai_buildings_spawner.png",
	on_use=function(itemstack, user, pointed_thing)
		aliveai.show_buildings_spawner(itemstack, user, pointed_thing)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		aliveai.show_buildings_spawner(itemstack, user, pointed_thing,true)
		return itemstack
	end,
})

aliveai.show_buildings_spawner=function(itemstack, user, pointed_thing,place)
		if not user or type(user)~="userdata" then return end
		local name=user:get_player_name()
		if minetest.check_player_privs(name, {aliveai_buildings_spawning=true})==false then
			if type(itemstack)=="userdata" then
				itemstack:replace(nil)
			end
			minetest.chat_send_player(name,"You are unallowed to use this tool")
			return itemstack
		end
		local use=":on_use"
		if place then
			use=":on_place"
		end
		local gui="size[10,8]"
		local x,y=0,0
		local l=0
		for i, v in pairs(aliveai.buildings_spawners) do
			if (not place and v.on_use) or (place and v.on_place) then
				l=string.len(v.name)
				if l<5 then
					l=1
				elseif l<15 then
					l=2
				else
					l=3	
				end
				gui=gui .. "tooltip[" .. v.mod .."." .. v.name .. use ..";" .. v.name .."]"
				.. "button[" .. x .."," .. y .. ";" .. l ..",1;" .. v.mod .."." .. v.name .. use ..";" .. v.name .."]"
				x=x+l
				if x>10 then
					x=0
					y=y+1
				end

			end
		end
		aliveai.terminal_users[user:get_player_name()]={itemstack=itemstack,user=user,pointed_thing=pointed_thing}
		minetest.after(0, function(gui)
			return minetest.show_formspec(name, "aliveai.buildings_spawner",gui)
		end, gui)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form=="aliveai.book" then
		if pressed.quit then
			return
		end
		local item=player:get_wielded_item():to_table()
		local meta=minetest.deserialize(item.metadata) or {bots={},selected=""}
		if not meta.pages or meta.pages==0 then return end
		table.sort(meta.bots)
		if pressed.fro then
			meta.selected_num=meta.selected_num+1
			if meta.selected_num>meta.pages then
				meta.selected_num=1
			end
			meta.selected=meta.bots[meta.selected_num]
		elseif pressed.bac then
			meta.selected_num=meta.selected_num-1
			if meta.selected_num<1 then
				meta.selected_num=meta.pages
			end
			meta.selected=meta.bots[meta.selected_num]
		elseif pressed.list then
			meta.selected=pressed.list
			for i, b in ipairs(meta.bots) do
				if b==meta.selected then
					meta.selected_num=i
					break
				end
			end
		end
		item.metadata=minetest.serialize(meta)
		player:get_inventory():set_stack("main", player:get_wield_index(),item)
		aliveai.view_book(player,meta)
	elseif form=="aliveai.buildings_spawner" then
		local name=player:get_player_name()
		if pressed.quit or not aliveai.terminal_users[name] then
			aliveai.terminal_users[name]=nil
			return
		end
		local na
		local s
		for name, v in pairs(pressed) do
			na=name
			break
		end
		s=na.split(na,":")
		if s and s[2] and aliveai.buildings_spawners[s[1]] then
			local a=aliveai.terminal_users[name]
			aliveai.buildings_spawners[s[1]][s[2]](a.itemstack,a.user,a.pointed_thing)
		end
	end
end)



aliveai.crafttools=function(self,t)
	if self.crafting~=1 or math.random(1,10)~=1 then return end
	if type(self.tools)=="table" then return end
	for name, s in pairs(aliveai.tools_handler) do
		if s.try_to_craft and s.tools and not self.creative==1 then
			for i, name2 in pairs(s.tools) do
				if not self.inv[name ..":" ..name2] then
					aliveai.crafting(self,name ..":" ..name2)
				end
			end
		end
	end
	return self
end

aliveai.tool_handler=function(self,t)
	if self.using_tool then return end
	self.using_tool=true
	if not minetest.registered_tools[t] then return end
	local ts=t.split(t,":")
	local tool=aliveai.tools_handler[ts[1]]
	if not tool or not tool.use then return end
	aliveai.showstatus(self,"tool handler")
	if tool.tool_group and minetest.get_item_group(t, tool.tool_group)==0 and minetest.get_item_group(t, tool.tool_group)==0 then
		return
	end
	if tool.tools then
		local nm=true
		for i, name in pairs(tool.tools) do
			if ts[2]==name then nm=false break end
		end
		if nm then return end
	end
	if tool.amo and self.inv[tool.amo] then
		if tool.amo_index and tool.tool_index then
			if tool.amo_index<=tool.tool_index then
				self.tools={tool.amo,t}
			else
				self.tools={t,tool.amo}
			end
		elseif tool.amo_index and tool.amo_index>1 then
			self.tools={tool.amo,t}
		elseif tool.tool_index and tool.tool_index>1 then
			self.tools={t,tool.amo}
		else
			self.tools={tool.amo,t}
		end
	elseif tool.amo_group then
		for name, s in pairs(self.inv) do
			if minetest.get_item_group(name, tool.amo_group)>0 
			or minetest.get_item_group(name, tool.amo_group)>0 then
				if tool.amo_index and tool.tool_index then
					if tool.amo_index<=tool.tool_index then
					self.tools={name,t}
					else
						self.tools={t,name}
					end
				elseif tool.amo_index and tool.amo_index>1 then
					self.tools={name,t}
				elseif tool.tool_index and tool.tool_index>1 then
					self.tools={t,name}
				else
					self.tools={name,t}
				end
			end
		end
	else
		return self
	end
	self.tool_index= tool.tool_index or self.self.tool_index
	self.tool_reuse= tool.tool_reuse or self.tool_reuse
	self.tool_near= tool.tool_near or self.tool_near
	self.tool_see= tool.tool_see or self.tool_see
	self.tool_chance= tool.tool_chance or self.tool_chance
end

aliveai.give_to_bot=function(self,clicker)
	local stack=clicker:get_wielded_item()
	if stack:get_name()=="" or stack:get_name()=="aliveai:team_gift" or stack:get_name()=="aliveai_minecontroller:controller" then
		aliveai.on_spoken_to(self,self.botname,clicker:get_player_name(),"come")
		return self
	end

	if stack:get_name()=="aliveai:hypnotics" then
		local inv=clicker:get_inventory()
		local i=clicker:get_wield_index()
		stack:take_item(1)
		inv:set_stack("main", i,stack)
		if self.hp_max<101 and self.type=="npc" then
			aliveai.sleep(self,2)
		else
			aliveai.punch(self,self.object,20)
		end
		return self
	end

	if stack:get_name()=="aliveai:relive" then
		local inv=clicker:get_inventory()
		local i=clicker:get_wield_index()
		stack:take_item(1)
		inv:set_stack("main", i,stack)

		if self.dying or self.dead then
			aliveai.dying(self,3)
		elseif self.hp_max<101 and self.drop_dead_body==1 then
			self.hp=-10
			aliveai.dying(self,1)
		else
			aliveai.punch(self,self.object,20)
		end
		return self
	end

	if self.dead then return end
	self.mood=self.mood+1
	local inv=clicker:get_inventory()
	local i=clicker:get_wield_index()
	if self.hp<self.hp_max and minetest.get_item_group(stack:get_name(),"aliveai_eatable")>0 then
		aliveai.known(self,clicker,"member")
		self.mood=self.mood+2
		aliveai.sayrnd(self,"thanks",clicker:get_player_name())
		aliveai.invadd(self,stack:get_name(),stack:get_count())
		inv:set_stack("main", i,nil)
		return self
	elseif self.dying then
		return
	end
	
	if stack:get_name()=="aliveai_minecontroller:controller" then return end

	aliveai.invadd(self,stack:get_name(),stack:get_count())

	if stack:get_name()=="default:diamond" and aliveai.team(clicker)==self.team then
		self.taskstep=3
		self.task="..."
		aliveai.task_build(self)
		aliveai.say(self,"ok, im a guard")
		self.namecolor="0000ff55"
		aliveai.showtext(self,"Guard")
		self.home=aliveai.roundpos(self.object:get_pos())
		aliveai.showstatus(self,"guard")
		inv:set_stack("main", i,nil)
		return self
	end

	if self.need then
		local name=stack:get_name()
		for ii, vv in pairs(self.need) do
			if vv.item==name or vv.search==name then
				aliveai.known(self,clicker,"member")
				self.mood=self.mood+2
				aliveai.sayrnd(self,"thanks",clicker:get_player_name())
				break
			end
		end
	end
	inv:set_stack("main", i,nil)
	return self
end

aliveai.invadd=function(self,add,num,nfeedback)
-- inventory
	if not (add and num) or add=="" or num=="" or add=="air" then return self end
	if num>1 then self.mood=self.mood+1 end

	if self.inv[add] then
		self.inv[add]=self.inv[add]+num
		self.lastitem_name=add
		self.lastitem_count=self.inv[add]
	else
		self.inv[add]=num
	end
	if self.inv[add]<=0 then
		self.inv[add]=nil
	else
		aliveai.eat(self)
	end
-- needs
	if self.need and self.need[add] then
		if num<0 then num=num*-1 end
		self.need[add].num=self.need[add].num-num
		if self.need[add].num<=0 then self.need[add]=nil end
	end
--feedback

	if self.tools=="" then
		if minetest.registered_tools[add] then
			if minetest.registered_tools[add].tool_capabilities then
				local tool=minetest.registered_tools[add].tool_capabilities
				if tool.damage_groups and tool.damage_groups.fleshy and tool.damage_groups.fleshy> self.dmg then
					self.dmg=tool.damage_groups.fleshy
				end
			elseif minetest.registered_tools[add].on_use then
				self.tools={add}
				self.tool_near=1
				self.savetool=1
			end
		elseif minetest.registered_craftitems[add] then
			if minetest.registered_craftitems[add].tool_capabilities then
				local tool=minetest.registered_craftitems[add].tool_capabilities
				if tool.damage_groups and tool.damage_groups.fleshy and tool.damage_groups.fleshy> self.dmg then
					self.dmg=tool.damage_groups.fleshy
				end
			elseif minetest.registered_craftitems[add].on_use and minetest.get_item_group(add,"aliveai_eatable")==0 then
				self.tools={add}
				self.tool_near=1
				self.savetool=1
			end
		end
	end




	if aliveai.armor then aliveai.armor(self,{item=add}) end
	if aliveai.wieldviewr and not nfeedback then aliveai.wieldviewr(self,add) end

	aliveai.crafttools(self,add)
	if self.need and not nfeedback then aliveai.haveneed(self,true) end
	return self
end

aliveai.invhave=function(self,name,n,getnum)
		if self.creative==1 and getnum then
			return n
		elseif self.creative==1 then
			self.need=nil
			return true
		end
		local group=name
		local count=0
		if group~=name then-- only for namecuts
			for nm, s in pairs(self.inv) do
				if minetest.get_item_group(nm, group)>0 then 
					count=count+s
				end
			end
		elseif self.need and self.crafting==1 then
			-- if its a group, return an item/node
			name=aliveai.crafttoneed(self,name,true)
		end
		if getnum then
			if count>0 then return count end
			return self.inv[name] or 0
		end
		if count>0 and count>=n then
			return true
		end
		if self.inv[name]==nil then
			return false
		elseif n>self.inv[name] then
			return false
		end
		return true
end

aliveai.newneed=function(self,item,num,search,type)
	if self.creative==1 then return end
	if not self.need then self.need={} end
	search=search or ""
	num=num or 1
	if self.ignore_item[item] or (self.need[item] and self.need[item].search==search) or aliveai.invhave(self,item,num) then
		return
	end
	if type==nil then
		type="item"
		if minetest.registered_items[item] then type="item" end
		if minetest.registered_nodes[item] then type="node" end
	end
-- some extra help for the bot
	if item=="default:chest"			then search="default:chest" type="node" end
	if item=="default:chest_locked"		then search="default:chest_locked" type="node" end
	if item=="default:glass"			then search="group:sand" type="node" end
	if item=="default:wood"			then search="group:tree" type="node" end
	if item=="default:stone"			then item="default:cobble" search="group:stone" type="node" end
	if item=="default:bush_stem"		then search="group:tree" item="default:wood" type="node" end
	if item=="default:acacia_bush_stem"		then search="group:tree" item="default:wood" type="node" end
	if item=="default:iron_lump"			then item="default:steel_ingot" end
	if item=="default:copper_lump"		then item="default:copper_ingot" end
	if item=="default:gold_lump"			then item="default:gold_ingot" end
	if item=="default:stone"			then search="group:stone" end
	if item=="default:leaves"			then search="group:leaves" end
	if item=="default:dirt"			then search="group:soil" end
	if item=="wool:white"			then search="farming:cotton_8" end
	if item=="wool:blue"			then search="farming:cotton_8" end
	if item=="wool:red"			then search="farming:cotton_8" end
	if item=="air"				then return self end
	self.need[item]={num=num,item=item,search=search,type=type}
	
	if not self.mine then
		self.mine={target={},status="search"}
		aliveai.showstatus(self,"mine",4)
	end
	return self
end

aliveai.haveneed=function(self,craft)
	if self.creative==1 then return nil end
	if self.need then
		local have={}
		local name2=""
		local n=true
		for name, need in pairs(self.need) do
			n=false
			if aliveai.invhave(self,need.item,need.num) then
				self.need[name]=nil
				for name2, count2 in pairs(self.need) do
					return self
				end
				n=true
			elseif craft and self.crafting==1 then
				aliveai.crafting(self,need.item,1,need.num)
			end
		end
		if n then
			self.need=nil
			return nil,self
		end
		return self
	end
	return nil
end

aliveai.place=function(self,pos,name)
	local n=minetest.registered_nodes[minetest.get_node(pos).name]
	if minetest.registered_nodes[name] and aliveai.invhave(self,name,1) and n and n.buildable_to and not aliveai.protected(pos,self) then
		local name=name
		if self.inv[name] or self.creative==1 then
			--if minetest.registered_nodes[name] and
			--(minetest.registered_nodes[name].after_place_node
			--or minetest.registered_nodes[name].on_construct 
			--or minetest.registered_nodes[name].on_destruct) then
				--minetest.registered_nodes[name].on_place(ItemStack(name), aliveai.createuser(self), {under=pos,above={x=pos.x,y=pos.y+0.5,z=pos.z}})
				--minetest.place_node(pos, {name=name})
			--else
				minetest.set_node(pos, {name=name})
				if aliveai.def(name,"on_construct") then minetest.registered_nodes[name].on_construct(pos) end


			--end

			if self.creative==0 then aliveai.showstatus(self,name .." left: " .. self.inv[name],4) end
			aliveai.invadd(self,name,-1,true)
			return self
		end
		for node, c in pairs(self.inv) do
			if minetest.get_item_group(node, name)>0 then
				minetest.set_node(pos, {name=node})
				aliveai.showstatus(self,name .." left: " .. (self.inv[node]-1),4)
				aliveai.invadd(self,node,-1)
				return self
			end
		end
	else
		return nil
	end
end

aliveai.dig=function(self,pos)
	if minetest.is_protected(pos,"")==false and aliveai.protected(pos,self)==false and minetest.get_node(pos) then
		local name=minetest.get_node(pos).name
		if name=="air" then return true end
-- have inventory/owned
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local owner=meta:get_string("owner")
		if meta:get_int("owner")==1 or owner=="" or owner==self.botname then
			if inv and not inv:is_empty("main") then
				for i=1,inv:get_size("main"),1 do
					local it=inv:get_stack("main",i):get_name()
					local co=inv:get_stack("main",i):get_count()
					inv:set_stack("main",i,nil)
					aliveai.spawnpickup(pos,it,co)
				end
			end
		else
			aliveai.ignorenode(self,pos)
			return false
		end
--dig + drops
		local n=1
		local drop=aliveai.digdrop(pos)
		if drop==nil then
			--minetest.remove_node(pos)
			minetest.check_for_falling(pos)
		end
		if not drop then return false end
		if drop.name~=nil then
			--minetest.remove_node(pos)
			minetest.check_for_falling(pos)
		end
		if minetest.get_node(pos).name~="air" then
			aliveai.ignorenode(self,pos)
			return self
		end
		aliveai.showstatus(self,"dig " .. name,4)
		aliveai.invadd(self,drop.name,drop.n)
		self.on_dig(self,pos,drop.name,drop.n)
-- if dug was added need
		if self.need and self.need[name] and self.need[name]==1 then
			self.need[name]=nil
		end
		return true
	end
	return false
end

aliveai.digdrop=function(pos)
	local node
	if minetest.registered_nodes[pos] then
		node=minetest.registered_nodes[pos]
	elseif pos and pos.x and pos.y and pos.z then
		node=minetest.registered_nodes[minetest.get_node(pos).name]
	else
		return nil
	end
-- have drop
	if not node then
		return nil
	elseif node.drop then
		local n=1
		local name=node.name
-- string drop
		if type(node.drop)=="string" then
			if node.drop=="" or node.groups.unbreakable then return nil end
			name=node.drop
			if string.find(name," ")~=nil then
				local sp=name.split(name," ")
				name=sp[1]
				n=tonumber(sp[2])
	
			end
			return {name=name,n=n}
		end
-- advanced drop
		if not (type(node.drop)=="table" and node.drop.items) then
			return {name=name,n=n}
		end
		local maxitems=node.drop.max_items or 1
		local items={}
		n=0
		for i, v in pairs(node.drop.items) do
				n=n+1
				items[n]={}
				if v.rarity then
					items[n].rnd=v.rarity
				end
				if v.items then
					items[n].items={}
					if type(v.items)=="table" then
						items[n].name=v.items[1]
					else
						items[n].name=v.items
					end
					items[n].n=1
					if string.find(items[n].name," ")~=nil then
						local sp=items[n].name.split(items[n].name," ")
						items[n].name=sp[1]
						items[n].n=tonumber(sp[2])
					end
				end
		end
		local rr=0
		for i=1,n,1 do
			if items[i] and items[i].name and items[i].rnd and aliveai.random(1,items[i].rnd)==1 then
				return {name=items[i].name,n=items[i].n}
			elseif items[i] and items[i].name and not items[i].rnd then
				return {name=items[i].name,n=items[i].n}
			end
		end
	else
		return {name=node.name,n=1}
	end
end

aliveai.eat=function(self)
	local hp=aliveai.gethp(self.object)
	if hp<=0 or hp>=self.hp_max then
		return nil
	end
	local ohp=hp
	for i, h in pairs(self.inv) do
		local eat=minetest.get_item_group(i,"aliveai_eatable")
		if eat>0 then
			for i2=1,h,1 do
				hp=hp+eat
				if hp>=self.hp_max then
					self.inv[i]=h-i2
					if self.inv[i]<=0 then self.inv[i]=nil end
					self.object:set_hp(self.hp_max)
					self.hp=self.hp_max
					aliveai.showhp(self,true)
					aliveai.showstatus(self,"ate, hp now " .. self.hp)
					return
				end
			end
			self.inv[i]=nil
		end
	end
	if ohp~=hp then
		self.object:set_hp(hp)
		self.hp=hp
		aliveai.showhp(self,true)
		aliveai.showstatus(self,"ate, hp now " .. self.hp)
	end
	return self
end

aliveai.crafting=function(self,name,norecraft,neednum)

	if self.crafting~=1 or name==nil or aliveai.enable_build==false then return false end
	neednum=neednum or 1
	if not norecraft then norecraft=0 end
	norecraft=norecraft+1
	if norecraft>5 then return self end
	name=name
	local c=minetest.get_craft_recipe(name)
	local n=1
	local relist1={}
	local relist2={}
	local list=c.items
	local output=c.output
--if group or burn
	if not c.output then 
		local group=name
		output=group
		local old=output
		for i, s in pairs(self.inv) do
			local from=minetest.get_craft_result({ method = "normal", width = 1, items = { ItemStack(i)}})
			local burn=minetest.get_craft_result({ method = "cooking", width = 3, items = { ItemStack(i)}})
			if (from and from.item) or (burn and burn.item) then
				local a1=from.item:to_table()
				local a2=burn.item:to_table()
				if a2~=nil and a2.name and aliveai.invhave(self,i,neednum) then -- cooking
					local have=s
					local take=neednum
					if take>have then
						local l=s-take
						take=take-l
					end
					aliveai.invadd(self,i,take*-1,true)
					aliveai.invadd(self,a2.name,take, true)
					return self
				end
				if a1~=nil and minetest.get_item_group(a1.name, group)>0 then
					list={i}
					output=a1.name
					n=a1.count
					break
				end
			end
		end
		if old==output then
			return false
		end
	end
-- collect items to remove
	if not list then return end
	for i, v in pairs(list) do
		local gr=v
		if not relist1[gr] then relist1[gr]=0 end
		relist1[gr]=relist1[gr]+1
	end
	if not relist1 then return end
-- check if list can be removed, or try to craft
	local nothaveall=false
	for i, v in pairs(relist1) do
		local ii=i
		if self.need and string.find(ii,"group:",1)~=nil then
			ii=aliveai.crafttoneed(self,ii,true)
		end
		if not aliveai.invhave(self,ii,v) then
			local getc
			if self.need then getc=aliveai.crafttoneed(self,ii,false,v) end
			if getc then aliveai.crafting(self,getc,norecraft,v) end
			nothaveall=true
		end
		relist2[ii]=v
	end
	if nothaveall or not relist2 then return self end
-- remove list
	for i, v in pairs(relist2) do
		if self.inv[i]==nil then
			for ii, vv in pairs(self.inv) do
				if minetest.get_item_group(ii, i)>0 or minetest.get_item_group(ii, i)>0 then
					aliveai.invadd(self,ii,v*-1,true)	
				end
			end
		else
			aliveai.invadd(self,i,v*-1,true)
		end
	end
	aliveai.invadd(self,name,n,true)
	return self
end

aliveai.getmaxstack=function(a)
	if a==nil or a=="" then return 1 end
	local b
	if minetest.registered_nodes[a] then
		b=minetest.registered_nodes[a]
	elseif minetest.registered_items[a] then
		b=minetest.registered_items[a]
	elseif minetest.registered_craftitems[a] then
		b=minetest.registered_craftitems[a]
	elseif minetest.registered_tools[a] then
		b=minetest.registered_tools[a]
	end

	if not b then return 1 end
	return b.stack_max
end

aliveai.spawnpickup=function(pos,name,n,self)
	if (name==nil or name=="") or
	(minetest.registered_nodes[name]==nil
	and minetest.registered_items[name]==nil
	and minetest.registered_craftitems[name]==nil
	and minetest.registered_tools[name]==nil) then return end
	if n==nil or tonumber(n)==nil or n==0 then n=1 end
	local ob=minetest.add_item(pos, name .." ".. n)
	if self then ob:get_luaentity().dropped_by=self.botname end
	ob:set_velocity({x = math.random(-1, 1),y=5,z = math.random(-1, 1)})
	minetest.after(3, function(ob)
		if ob and ob:get_luaentity() then
			local pos=ob:get_pos()
			local n=minetest.get_node(pos)
			local nr=minetest.registered_nodes[n.name]
			if nr and (nr.damage_per_second>0 or minetest.get_item_group(n.name,"igniter")>0 or minetest.get_item_group(n.name,"lava")>0) then
				ob:punch(ob, 1, "default:sword_wood", nil)
				minetest.add_particlespawner({
				amount = 1,
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
		end
	end,ob)

end

aliveai.invdropall=function(self)
	local pos=self.object:get_pos()
	local c=0
	local max
	aliveai.showstatus(self,"drop all items")
	if not self.inv then aliveai.kill(self) return self end
	for i, itt in pairs(self.inv) do
		max=aliveai.getmaxstack(i)
		if i and itt<=max then
			aliveai.spawnpickup(pos,i,itt,self)
		else
			local io=itt
			for b=1,itt, 1 do
				if io>max then
					io=io-max
					aliveai.spawnpickup(pos,i,max,self)
				else
					aliveai.spawnpickup(pos,i,io,self)
					break
				end
			end
		end
	end
	self.inv={}
	return self
end

aliveai.pickup=function(self,rnd)
	if self.pickuping~=1 then return self end
	if not self.pickupgoto then
		if not rnd and math.random(0,5)>1 then return self end
	end
	self.pickupgoto=nil
	if self.isrnd and not rnd then
		local pos=self.object:get_pos()
		pos.y=pos.y-1
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.distance)) do
			if ob and ob:get_luaentity() and ob:get_luaentity().name=="__builtin:item" then
				local pos2=ob:get_pos()
				if aliveai.visiable(self,pos2) then
					aliveai.lookat(self,pos2)
					aliveai.walk(self)
					self.pickupgoto=true
					aliveai.showstatus(self,"goto item")
					aliveai.showpath(pos2,3)
					break
				end
			end
		end
	end
	local pos=self.object:get_pos()
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.arm)) do
		if ob and ob:get_luaentity() and ob:get_luaentity().name=="__builtin:item" then
			local item=ob:get_luaentity().itemstring
			local droppedby=ob:get_luaentity().dropped_by
			local n=1
			if string.find(item," ")~=nil then
				local sp=item.split(item," ")
				item=sp[1]
				n=tonumber(sp[2])
			end
			if item==nil then
				ob:set_hp(0)
				ob:punch(self.object, 1, "default:sword_wood", nil)
				return self
			end
			if droppedby~=nil then
				local player=minetest.get_player_by_name(droppedby)
				if self.need and self.need[item] then
					if not self.fight and not self.fly and player then
						aliveai.known(self,player,"member")
						aliveai.sayrnd(self,"thanks",droppedby)
					end
					if self.fight and aliveai.getknown(self,self.fight,"fight") then
						aliveai.known(self,self.fight,"")
						aliveai.sayrnd(self,"thanks",droppedby)
					end
				end
			end
			aliveai.invadd(self,item,n)
			aliveai.punch(self,ob,1)
			self.pickupgoto=nil
			aliveai.showstatus(self,"picked up " .. item)	
		end
	end
end

minetest.after(0, function()
	aliveai.inventorycreate()
end)
aliveai.inventorycreate=function()
aliveai.inventory=minetest.create_detached_inventory("main", {
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		return count
	end,
	allow_put = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	allow_take = function(inv, listname, index, stack, player)
		return stack:get_count()
	end,
	})
	aliveai.inventory:set_size("main", 16)
end

aliveai.clearinventory=function(self)
	local pos
	if self then pos=self.object:get_pos() end
	local inv = minetest.get_inventory({type="detached", name="main"})
	for i=1,inv:get_size("main"),1 do
		local it=inv:get_stack("main",i):get_name()
		local co=inv:get_stack("main",i):get_count()
		inv:set_stack("main",i,nil)
		if it~="" and pos and pos.x and type(self.tools)=="table" then
			local nohaveit=true
			for ii, name in pairs(self.tools) do
				if name==it then
					nohaveit=false
					break
				end
			end
			if nohaveit then  aliveai.spawnpickup(pos,it,co,self) end
		end
	end
end

aliveai.re=function(a)
	return (function() return a end)
end
	
aliveai.use=function(self)
	if self.tools==nil or type(self.tools)~="table" then return self end

	if self.tools[1] and not self.tools[2] then
		aliveai.tool_handler(self,self.tools[1])
	end

	local inv=minetest.get_inventory({type="detached", name="main"})
	local n=0
	local tool=""
	local pointed_thing={type="nothing"}
	local pos=self.object:get_pos()
	for i, name in pairs(self.tools) do
		n=n+1
		if n==self.tool_index then
			if not (minetest.registered_tools[name] and minetest.registered_tools[name].on_use) then print("error: tried to use " .. name .." as a tool, but doesn't have the on_use() function") return self end
			tool=name
		end
		inv:set_stack("main", n, ItemStack(name .. " " .. 1))
	end
	local user=aliveai.createuser(self,self.tool_index)
	if self.fight then
		local range=self.arm
		if minetest.registered_tools[tool] and minetest.registered_tools[tool].range then range=minetest.registered_tools[tool].range end
		local fpos=self.fight:get_pos()
		local d=aliveai.distance(self,fpos)
		if d<self.distance and aliveai.visiable(self,fpos) then
			local dir=aliveai.get_dir(self,fpos)
			user.get_look_dir=aliveai.re(dir)
			if d<=range then
				pointed_thing.type="object"
				pointed_thing.ref=self.fight
			end
		end
	end
	local stack=ItemStack(inv:get_stack("main", self.tool_index))
	aliveai.showstatus(self,"use tool: " .. stack:get_name())
	if not minetest.registered_tools[tool] then return end

	if aliveai.wieldviewr then aliveai.wieldviewr(self,tool) end

	minetest.log("aliveai:" .. self.botname .." uses " .. tool)

	local error
	error,stack=pcall(minetest.registered_tools[tool].on_use,unpack{stack,user,pointed_thing})

	if error==true and self.tool_reuse==1 then
		tool=stack:get_name()
		minetest.after(0.1, function(self,tool,inv,stack,user,pointed_thing)
			minetest.registered_tools[tool].on_use(stack,user,pointed_thing)
			aliveai.clearinventory(self)
		end,self,tool,inv,stack,user,pointed_thing)
	else
		aliveai.clearinventory(self)
	end
	return self
end

aliveai.spawnbones=function(self)
	if not self and self.object then return end
	local pos=self.object:get_pos()
	pos={x=pos.x,y=pos.y+0.5,z=pos.z}
	if self.dropbones==1 and aliveai.set_bones and aliveai.bones and aliveai.def(pos,"buildable_to") and not minetest.is_protected(pos,"") then
		minetest.set_node(pos,{name="bones:bones"})
		local meta=minetest.get_meta(pos)
		local inv=meta:get_inventory()
		inv:set_size("main", 32)
		meta:set_string("infotext", self.botname .."'s bones")
		meta:set_string("formspec",
		"size[8,8]" ..
		"list[context;main;0,0;8,4;]" ..
		"list[current_player;main;0,4;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;main]")
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 3)) do
			local en=ob:get_luaentity()
			if en and en.name=="__builtin:item" and en.dropped_by==self.botname then
				if inv:room_for_item("main", en.itemstring) then
					inv:add_item("main", en.itemstring)
					aliveai.kill(en)
				else
					return
				end
			end
		end
	end
end



aliveai.createuser=function(self,index)
	index=index or 1
	local yaw=self.object:get_yaw()
	if type(yaw)~="number" then yaw=0 end
	yaw=yaw+1.575
	local pos=self.object:get_pos()
	local inv=minetest.get_inventory({type="detached", name="main"})
	return {
		get_player_control=aliveai.re({sneak=false,up=false,down=false,left=false,right=false}),
		get_inventory=aliveai.re({contains_item=aliveai.re(true)}),
		get_luaentity=aliveai.re(self.object),
		get_player_name=aliveai.re(self.botname),
		get_look_horizontal=aliveai.re(0),
		set_look_horizontal=aliveai.re(0),
		set_animation=aliveai.re(),
		set_eye_offset=aliveai.re(),
		get_look_dir=aliveai.re(aliveai.get_dir(self,aliveai.pointat(self))),
		get_look_pitch=aliveai.re(math.pi/2),
		get_look_yaw=aliveai.re(self.object:get_yaw()),
		get_player_control=aliveai.re({jump=false,right=false,left=false,LMB=false,RMB=false,sneak=false,aux1=false,down=false,up=false}),
		get_player_control_bits=aliveai.re(0),
		is_player=aliveai.re(true),
		set_hp=aliveai.re(),
		get_hp=aliveai.re(self.object:get_hp()),
		get_breath=aliveai.re(11),
		get_inventory_formspec=aliveai.re(""),
		set_inventory_formspec=aliveai.re(0),
		get_inventory=aliveai.re(inv),
		get_wielded_item=aliveai.re(inv:get_stack("main", index)),
		get_wield_index=aliveai.re(self.tool_index),
		get_wield_list=aliveai.re("main"),
		set_wielded_item=function(self, item)
			items=item
			inv:set_stack("main", items, item)
		end,
		setpos=aliveai.re(),
		set_pos=aliveai.re(),
		getpos=aliveai.re(pos),
		get_pos=aliveai.re(pos),
		moveto=aliveai.re(),
		punch=aliveai.re(),
		remove=aliveai.re(),
		right_click=aliveai.re(),
		set_properties=aliveai.re(),
		set_animation=aliveai.re(),
		get_attach=aliveai.re(),
		set_attach=aliveai.re(),
		set_detach=aliveai.re(),
		set_bone_position=aliveai.re(),
		hud_change=aliveai.re(),
	}
end


aliveai.register_buildings_spawner("Copy building",{
		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				aliveai.form(user:get_player_name())
			end
			return itemstack
		end,
		on_place = function(itemstack, user, pointed_thing)
			if pointed_thing.type=="node" then
				local name=user:get_player_name()
				if not aliveai.buildingtool then
					aliveai.form(name)
					return itemstack
				end
				local pos=pointed_thing.under
				local last=""
				local node=""
				local nodes=""
				local count=0
				local need={}
				local dir=minetest.dir_to_facedir(user:get_look_dir())
				local z1=1
				local x1=1
				if dir==1 then x1=1 z1=1 end
				if dir==3 then x1=-1 z1=-1 end
				if dir==0 then x1=-1 z1=1 end
				if dir==2 then x1=1 z1=-1 end
				local toy=aliveai.buildingtool.y
				local tox=aliveai.buildingtool.x*x1
				local toz=aliveai.buildingtool.z*z1
				local status=false
				if aliveai.status==false then status=true end
				aliveai.status=true

				for y=0,toy,1 do
					for x=0,tox,x1 do
						for z=0,toz,z1 do
							local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
							node=minetest.get_node(p).name
							if last=="" then last=node end
							if node~="a" then
								if not need[node] then need[node]=0 end
								need[node]=need[node]+1
							end
							if (y==0 or y==toy) or (x==0 or x==tox) or (z==0 or z==toz) then
								aliveai.showpath(p,2)
							end

							if node~=last then
								nodes=nodes ..last .." " .. count .. "!"
								count=0
							end
							count=count+1
							last=node
							if y==toy and x==tox and z==toz and last~="a" then
								nodes=nodes ..last .." " .. count .. "!"
								count=0
							end
						end
					end
				end
			if status then aliveai.status=false end
			local t=""
			for n, v in pairs(need) do
				t=t .. n.." " ..v .."!"
			end
			nodes=aliveai.buildingtool.x .." " .. aliveai.buildingtool.y .." " .. aliveai.buildingtool.z .. "+++" .. t .."+" .. nodes
			aliveai.form(name,nodes)
			return itemstack
			end
		end
})

aliveai.register_buildings_spawner("Generate building",{
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local pos=pointed_thing.above
			local name=user:get_player_name()
			for y=0,7,1 do
			for x=0,10,1 do
			for z=0,10,1 do
				local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				local node=minetest.get_node(p)
				if not node then
					minetest.set_node(p,{name="air"})
					node=minetest.get_node(p)
				end
				if minetest.registered_nodes[node.name].buildable_to==false or minetest.is_protected(p,name) then
					minetest.chat_send_player(name, "aliveai: area not able: " .. node.name)
					return itemstack
				end
			end
			end
			end
			aliveai.generate_house(pos)
		end
	end
})
