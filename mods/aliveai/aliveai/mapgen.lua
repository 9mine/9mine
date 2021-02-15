aliveai.registered_rndcheck_nodes={}

aliveai.register_rndcheck_on_generated=function(def)
	if not def then return end
	def.miny=def.miny or -500
	def.maxy=def.maxy or 500
	def.chance=def.chance or 1
	def.mindistance=def.mindistance or 0
	if def.node and type(def.node)~="string" then
		print("failed to add to check random generated node: node aren't a string")
	elseif def.chance and type(def.chance)~="number" then
		print("failed to add to check random generated chance aren't a number")
	elseif def.mindistance and type(def.mindistance)~="number" then
		print("failed to add to check random generated mindistance aren't a number")
	elseif def.group and type(def.group)~="string" then
		print("failed to add to check random generated node:group aren't a string")
	elseif type(def.run)~="function" then 
		print("failed to add to check random generated node: no run function")
		return
	elseif not (def.node or def.group) then
		print("failed to add to check random generated node: choose node or group or both")
		return
	end
	table.insert(aliveai.registered_rndcheck_nodes,{
		func=def.run,
		miny=def.miny,
		maxy=def.maxy,
		group=def.group,
		node=def.node,
		first_only=def.first_only,
		chance=def.chance,
		mindistance=def.mindistance
	})
end

minetest.register_on_generated(function(minp, maxp, seed)
	local nodes={}
	for _, f in pairs(aliveai.registered_rndcheck_nodes) do
		if f.miny<=minp.y and f.maxy>=maxp.y then
			f.first=nil
			table.insert(nodes,f)
		end
	end
	if #nodes==0 then
		return
	end
	local center={x=minp.x+math.floor((maxp.x-minp.x)/2),y=minp.y+math.floor((maxp.y-minp.y)/2),z=minp.z+math.floor((maxp.z-minp.z)/2)}
	local a
	for ii=-20,20,1 do
		a=ii+math.pi
		local cp={x=center.x+20*math.cos(a),y=center.y+ii,z=center.z+20*math.sin(a)}
		--minetest.set_node(cp,{name="default:mese"})
		local node=minetest.get_node(cp).name
		for _, f in pairs(nodes) do
			if not f.first and math.random(1,f.chance)==1 and (f.node and f.node==node) or (f.group and minetest.get_item_group(node,f.group)>0) then
				if not f.lpos then
					f.lpos=cp
				end
				if f.mindistance<=aliveai.distance(cp,f.lpos) then
					if f.first_only then
						f.first=true
					end
					f.lpos=cp
					minetest.after(0, function(f,cp)
						f.func(cp)
					end,f,cp)
				end
			end
		end
	end
end)