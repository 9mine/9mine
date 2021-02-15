aliveai.rnd_talk_to=function(self,ob)
	local bot=aliveai.is_bot(ob)
	local player=ob:is_player()
	if bot or player then
		local r=math.random(1,10)
		if r==1 then
			aliveai.say(self,"who are you?")
		elseif r==2 then
			aliveai.say(self,"what is your name?")
		elseif r==3 then
			aliveai.say(self,"what is your favorite color")
		elseif r==4 then
			aliveai.say(self,"do you have " .. self.lastitem_name)
		elseif r==5 then
			aliveai.say(self,"how are you")
		elseif r==6 and not (bot and ob:get_luaentity().type=="npc") then
			aliveai.say(self,"what is this?")
		elseif r==7 and aliveai.getknown(self,ob)=="" then
			aliveai.say(self,"friends?")
			minetest.after(1, function(self,ob)
				if aliveai.last_spoken_to=="ok" then
					aliveai.known(self,ob,"member")
					self.home=ob:get_luaentity().home
				end
			end, self,ob)
		elseif r==8 and bot and not self.home and ob:get_luaentity().home then
			aliveai.say(self,"can i live with you?")
			minetest.after(1, function(self,ob)
				if aliveai.last_spoken_to=="ok" and ob:get_luaentity() then
					self.house=nil
					self.home=ob:get_luaentity().home
				end
			end, self,ob)
		elseif r==9 then
			aliveai.say(self,"whats up?")
		elseif r==10 then
			aliveai.say(self,"who want to mine with me?")
		end
	end
end

aliveai.on_spoken_to=function(self,name,speaker,msg)
	aliveai.showstatus(self,"spoken to: " .. msg)
	self.on_chat(self,name,speaker,msg)


	local player=minetest.get_player_by_name(speaker)
	if player==nil or self.coming_players==0 then
		player=aliveai.get_bot_by_name(speaker)
	end
	if player==nil then return self end
	local known=aliveai.getknown(self,player)

	aliveai.sub_response(self,msg,5,{{2,"i"," am","my"," me"},{2,"im ","my"," me"}},{"not me","me too","ok","i dont think so","thats cool"})
	aliveai.sub_response(self,msg,5,{"sorry","sry","my wrong"},{"no problem"})
	aliveai.sub_response(self,msg,5,{2,"what is ","how old are "," you"," your"," age"},{"i dont know"})
	aliveai.sub_response(self,msg,5,{"what are you","who are you","your name"},{"im "..self.botname.." and you?","a npc","a bot","you cant see my nametag?"})
	aliveai.sub_response(self,msg,5,{"what","why"},{"yes","yeah","because i think so","as i said","because you said it"})
	aliveai.sub_response(self,msg,5,{"call you"},{"?"})
	aliveai.sub_response(self,msg,3,{"?"},{"what?"})
	aliveai.sub_response(self,msg,3,{"with what?"},{"this"})

	aliveai.sub_response(self,msg,5,{"go to the spawn"},{"whare is that?","where are spawn?","what spawn?","what is that?"})
	aliveai.sub_response(self,msg,5,{{"tp to me"},{"teleport to me"},{"tp me to"},{"teleport me to"}},{"im not a taxi!","admin, " .. speaker .. " want teleport"})

	if aliveai.sub_response(self,msg,3,{{"grant"},{"grant me"},{"grantme"}},{"admin, " .. speaker .. " asks for privs!","no im not admin","no i will be moderator next time, me!!","no"}) then
		if math.random(1,2)==1 then minetest.chat_send_all("*** " .. speaker .. " has been granted the privilege: Noob") end
	end

	if aliveai.sub_response(self,msg,1,{"can you help me",{"i will build a house, any help?"}},{"with?","with what?"},speaker) then
		return
	elseif aliveai.expected_response(self,speaker,msg,"this") then
		aliveai.say(self,aliveai.rndkey({"ok","comming","right"}))
		msg="come"
	end
		if known~="member" and (known=="fight" or known=="fly" or self.temper>1 or self.mood<-4 or aliveai.team(player)~=self.team) then
			local name=""
			if aliveai.is_bot(player) then
				name=player:get_luaentity().botname
			elseif player:get_luaentity() then
				name=player:get_luaentity().name
			elseif player:is_player() then
				name=player:get_player_name()
			end
			self.temper=self.temper+0.5
			aliveai.sayrnd(self,"no",name,true)
			if self.temper>2 then
				self.fight=player
			elseif self.temper>1 then
				self.staring={name=name,step=1}
				aliveai.lookat(self,player:get_pos(),true)
			end
			return self
		end
		local pos=player:get_pos()
		if aliveai.distance(self,pos)>self.distance*2 then
			aliveai.sayrnd(self,"no, too far")
			return self
		end
		if player:get_luaentity() then
			if player:get_luaentity().fly then
				self.fly=player:get_luaentity().fly
				self.temper=-2
				return self
			elseif player:get_luaentity().fight then
				self.fight=player:get_luaentity().fight
				self.temper=2
				return self
			end
		end
		local no_came

		if msg=="hi" or msg=="hello" then
			self.mood=self.mood-1
			aliveai.say(self,aliveai.rndkey({"hi","hello","hey"}))
		end

		if aliveai.find(msg,{"?"}) then self.mood=self.mood-1 end
		aliveai.find(msg,{"him"},self,"who?")
		aliveai.find(msg,{"aaa"},self,"what?")
		aliveai.find(msg,{"hey"},self,"what?")
		aliveai.find(msg,{"did","hear","that"},self,"what?")
		aliveai.find(msg,{"who","are","you"},self,"a npc")
		aliveai.find(msg,{"who","made","you"},self,"AiTechEye")
		aliveai.find(msg,{"you","like","color"},self,self.namecolor)
		aliveai.find(msg,{"your","name"},self,self.botname)
		aliveai.find(msg,{"your","favorite","color"},self,self.namecolor)
		aliveai.find(msg,{"your","team"},self,self.team)
		aliveai.find(msg,{"what","you","doing"},self,self.task .." step " .. self.taskstep)
		aliveai.find(msg,{"where are you"},self,aliveai.strpos(self.object:get_pos()))

		if aliveai.find(msg,{"kill","help"},self) then
			for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
				if aliveai.team(ob)~=self.team then
					self.fight=ob
					self.temper=self.temper+1
					aliveai.lookat(self,ob:get_pos())
					aliveai.say(self,"ok")
					return
				end
			end
		end

		if aliveai.find(msg,{"run","ahh","no"},self) then
			for _, ob in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), self.distance)) do
				if aliveai.visiable(self,ob:get_pos()) and ob:get_luaentity() and ob:get_luaentity().type=="monster" then
					aliveai.flee_from(self,ob)
					return
				end
			end
		end

		if msg=="can i live with you?" or msg=="friends?" then
			if self.mood>20 then aliveai.say(self,"ok") self.folow=player
			elseif self.mood>0 then aliveai.say(self,"not now")
			elseif self.mood<0 then aliveai.sayrnd(self,"no") end
			return
		end

		if msg=="folow me" and self.mood>0 then
			self.folow=player
			aliveai.say(self,"ok")
		end

		if aliveai.find(msg,{"how to craft "}) and self.mood>0  then
			local it1=msg.split(msg,"ow to craft ")
			if not it1[2] then
				aliveai.say(self,"idk")
				return
			end
			local it=string.lower(it1[2])
			local item
			if it and minetest.registered_items[it] then
				item=it
			else
				for i, v in pairs(minetest.registered_items) do
					if v.description and string.lower(v.description)==it then
						item=i
						break
					end
				end
				if not item then
					aliveai.say(self,"the item does not exist")
					return
				end
			end
			local c=minetest.get_craft_recipe(item)
			if c and c.type=="normal" then
				local n=""
				for i, v in pairs(c.items) do
					n=n .. i .. ": " .. v .. ", "
				end
				aliveai.say(self,n)
			elseif c and c.type=="cooking" and #c.items==1 then
				aliveai.say(self,"burn " ..  c.items[1])
			else
				aliveai.say(self,"idk")
			end
			return
		end

		if aliveai.find(msg,{"do you","want"}) and aliveai.find_item(self,msg) then aliveai.say(self,"ok") msg="come" end

		if msg=="who?" and self.fight or self.fly then
			if self.fight and self.fight:is_player() then
				aliveai.say(self,self.fight:get_player_name())
			elseif self.fly and self.fly:is_player() then
				aliveai.say(self,self.fly:get_player_name())
			elseif self.fight and aliveai.is_bot(self.fight) then
				aliveai.say(self,aliveai.get_bot_name(self.fight))
			elseif self.fly and aliveai.is_bot(self.fly) then
				aliveai.say(self,aliveai.get_bot_name(self.fly))
			elseif self.fight and self.fight:get_luaentity() then
				aliveai.say(self,self.fight:get_luaentity().name)
			elseif self.fly and self.fly:get_luaentity() then
				aliveai.say(self,self.fly:get_luaentity().name)
			else
				aliveai.say(self,"that thing")
			end
			return
		end
		if aliveai.find(msg,{"do you","have"}) then
			local it,n=aliveai.find_item(self,msg,true)
			if it then
				aliveai.say(self,self.inv[it])
			else
				aliveai.say(self,"no")
			end
			return
		end

		if msg=="who want to mine with me?" then
			if self.mood>20 then aliveai.say(self,"me")
				aliveai.say(self,"where are you?")
				msg="come"
			elseif self.mood<0 then aliveai.sayrnd(self,"no") end
		end

		if self.mood>15 and aliveai.find(msg,{"give","me"}) or aliveai.find(msg,{"i","need"}) then
			local it,n=aliveai.find_item(self,msg,true)
			if it then
				if n>self.inv[it] then n= self.inv[it] aliveai.say(self,"you can get " .. self.inv[it]) no_came=true end
				self.come_give=it
				self.come_give_num=n
				msg="come"
			end
		elseif self.mood>1 and aliveai.find(msg,{"give","me"}) or aliveai.find(msg,{"i","need"}) then
			local it=aliveai.find_item(self,msg,true)
			if it then
				aliveai.say(self,"you can get 1")
				no_came=true
				self.come_give=it
				self.come_give_num=1
				msg="come"
			end
		elseif self.mood<0 and aliveai.find(msg,{"give","me"}) or aliveai.find(msg,{"i","need"}) then
			aliveai.say(self,"get your own stuff")
		end

		if aliveai.find(msg,{"how are you"}) or aliveai.find(msg,{"how do you feel"}) or aliveai.find(msg,{"whats up?"}) then
			if self.mood>20 then aliveai.say(self,"awesome")
			elseif self.temper<0 then aliveai.say(self,"keep me hidden")
			elseif self.mood>10 then aliveai.say(self,"good")
			elseif self.mood>0 then aliveai.say(self,"fine")
			elseif self.mood<1 then aliveai.say(self,"nothng")
			elseif self.mood<2 then aliveai.say(self,"...")
			end
		end

		if aliveai.find(msg,{"what is","this"}) then
			local name=""
			if minetest.get_player_by_name(speaker) then
				name=speaker
			end
			for _, ob in ipairs(minetest.get_objects_inside_radius(player:get_pos(), 5)) do
				local en=ob:get_luaentity()
				if not (ob:is_player() and ob:get_player_name()==name)
				and not aliveai.same_bot(self,ob) then
					if ob:is_player() then aliveai.say(self,"a player, " .. name)
					elseif aliveai.is_bot(ob) then aliveai.say(self,"a aliveai bot, " .. en.name)
					elseif en.type and en.type~="" then aliveai.say(self,en.type)
					elseif en.itemstring and minetest.registered_items[en.itemstring] and minetest.registered_items[en.itemstring].description then aliveai.say(self,minetest.registered_items[en.itemstring].description)
					else aliveai.say(self,"idk, " .. en.name)
					end
					if aliveai.team(ob)==self.team then
						 aliveai.say(self,"team member")
					elseif (en and en.type=="monster" or aliveai.is_bot(ob)) or ob:is_player() then
						aliveai.say(self,"enemy")
						self.temper=2
						self.fight=ob
						self.on_detect_enemy(self,self.fight)
					end
					return
				end
			end
			local pp=player:get_pos()
			local nn=minetest.get_node({x=pp.x,y=pp.y-1,z=pp.z}).name
			if minetest.registered_items[nn] then
				aliveai.say(self,minetest.registered_items[nn].description or nn)
			end
		end


		if aliveai.find(msg,{"come"}) or aliveai.find(msg,{"help"}) then
			if not self.zeal then self.zeal=1 end
			self.zeal=self.zeal+1
			self.mood=self.mood-1
			self.come=player
			aliveai.known(self,player,"come")
			if not no_came then aliveai.sayrnd(self,"coming") end
		end

	return self
end


aliveai.find_item=function(self,msg,inv)-- self, item exist, item in inventory
	local it=msg.split(msg," ")
	local n=1
	for i, s in pairs(it) do
		local ins=minetest.registered_items[s]
		if ins then
			if it[i+1] and tonumber(it[i+1])~=nil then n=tonumber(it[i+1]) end
			if inv and self.inv[s] then return s,n end
			if not inv then return true end
		end
	end
end


aliveai.find=function(msg,strs,self,say)
	if not (strs and msg) or type(strs)~="table" then
		return false
	end
	if aliveai.find_in(msg,strs,self,say) then
		return true
	end
	for i, s in pairs(strs) do
		if type(s)=="table" and aliveai.find_in(msg,s,self,say,wait_for_answere) then
			return true
		end
	end
	return false
end


aliveai.find_in=function(msg,strs,self,say)
	local tr=#strs
	local trs=0
	for i, s in pairs(strs) do
		if type(s)=="string" and string.find(msg,s)~=nil then
			trs=trs+1
			if trs>=tr then
				break
			end
		elseif type(s)=="table" then
			tr=tr-1
		end
	end
	if trs>=tr then
		if self and say then
			aliveai.say(self,say)
		end
		return true
	end
end

aliveai.sub_response=function(self,msg,chance,keywords,response,talking_to)
	if math.random(1,chance)~=1 or not (msg and self and keywords and response) then
		return false
	end
	local num=1
	for i, s in pairs(keywords) do
		if type(s)=="table" then
			local num2=1
			for i, ss in pairs(s) do
				if type(ss)=="number" then
					num2=num2+ss
				elseif string.find(msg,ss)~=nil then
					num2=num2-1
					if num2<=0 then
						break
					end
				end
			end
			if num2<=0 then
				num=0
				break
			end
		elseif type(s)=="number" then
			num=num+s
		elseif string.find(msg,s)~=nil then
			num=num-1
			if num<=0 then
				break
			end
		end
	end
	if num<=0 then
		local say=response[math.random(1,#response)]
		aliveai.say(self,say)
		if talking_to and type(talking_to)=="string" then
			self.talking_to=talking_to
		end
		return true
	end
	return false
end

aliveai.expected_response=function(self,speaker,msg,keyword)
	if self.talking_to and self.talking_to==speaker and msg==keyword then
		return true
	end
	return false
end

aliveai.sayrnd=function(self,t,t2,nmood)
	if (self.mood<1 and not nmood) or t==nil or self.talking==0 then return self end
	local a
	if t=="coming" then
		a={"ok","what?","ok, but then?","so?"}
	elseif t=="ahh" then
		a={"AHHH NOOB","im sorry!!!!","run","RUN!!","AHH!!","nooo","help!","HELP MEEE","ohh no","you again","hey be cool!","need something?","i dont have enough","STOP HIM!!!","plz stop him!"}
	elseif t=="ouch" then
		a={"ow","ah","ahhh","ohha","it hurts","A","stop it!","aaaa"}
	elseif t=="come here" then
		a={"ohh your litle","hey you, come here","please come here... i will give you a surprise!","wait","stay","you are dead","i want to talk to you","one by one","i will kick your"," ya r stinking","ban","please ban him!","this is your end of life!"}
	elseif t=="thanks" then
		a={"thx ".. t2,"thanks i needed that ".. t2,"do you have some more? ","thats nice ".. t2,"cool ".. t2,"thanks a lot","nice"}
	elseif t=="got you" then
		a={"eliminated","feel good, and stay there!","HA HA!","XD","I got him","Got ya!", "c ya","see ya","loser","u r 2 bad","lol","yeah","..."}
	elseif t=="no" then
		a={"no way!","stop it!","go away","shut up","stop nagging"}
	elseif t=="what are you staring at?" then
		a={"what are you looking for?","waiting for something??","you are disgust me","you are interferes me","turn away your face!","???","?","-_-","what are you doing?","what you want?"}
	elseif t=="murder!" then
		a={"criminal!","stop him","get him!","killer","betrayer!","hey look that","what r u doing?"}
	elseif t=="its dead!" then
		a={"weird","ohh a corpse","what happend here?","cool!","um?","something went wrong, please try again","hey look!","?","en of the life","Fail!","ugly","this is crazy!"}
	elseif t=="mine" then
		a={"its not safe here","lol this is so much","look in the chest","me want blocks","hi guys","back","i have skills in buildning","go to the spawn","tp to me","tp me to","grant me eveything","i want be admin","go to the spawn","where are " .. self.talking_to ,"can you help me","i will build a house, any help?","yumm","go to the spawn","plz protect this to me","this is hard!","borring","who are you","im hungry","what are you doing?","i need " .. self.lastitem_name,"cant find " .. self.lastitem_name,"thats cool","what are your name","hey, can someone give me " .. self.lastitem_count .." " .. self.lastitem_name .."?","this is creepy",":D","how are you",":)",":(","what are this",".","hey you","can you meet at " .. math.random(1,24) ..":" .. math.random(0,59) .." ?",aliveai.genname() .." " ..aliveai.genname(),"i just have " .. self.lastitem_count,"do you want ".. self.lastitem_name .."?","k","no","zzz","did someone hear that?","i want a pet","lag","afk","how to craft " .. self.lastitem_name,"folow me"}
	elseif t=="AHHH" then
		a={"aaaaaaaaa","ooooo","hhaaaaa","waaaaa","njaaaaa","?","?????","!??","DOH","Hey im flying!","WEEEE"}
	elseif t=="Hey, im flying!" then
		a={"Hej, hey im flying!","whoo!?","weeeee","look at me, im flying!","cool","help!","plz let me down!","aaaa"}
	elseif t=="its flying!" then
		a={"Hej, its flying!","i want to fly!","this guy is flying!","look","cool","plz let me down!","aaaa"}
	elseif t=="LAAAAAAAAG!" then
		a={"lag and goodbye","borring server, bye","nothing to mine","can't find a place to mine here i'm leaving!","this is too laggy for me! bye"}
	end
	if not a then
		aliveai.say(self,t)
		return self
	end
	table.insert(a, t)
	local say=a[aliveai.random(1,#a)]
	aliveai.say(self,say)
	aliveai.on_chat(self.object:get_pos(),self.botname,say)	
end

aliveai.say=function(self,text)
	if self.talking==0 then return self end
	local pos1=self.object:get_pos()
	aliveai.last_spoken_to=text
	aliveai.on_chat(pos1,self.botname,text)
	for _,player in ipairs(minetest.get_connected_players()) do
		if aliveai.distance(pos1,player:get_pos())<aliveai.max_chat_distance then
			 minetest.chat_send_player(player:get_player_name(), "<" .. self.botname .."> " .. text)
		end
	end
end

aliveai.rndkey=function(a)
	if not a or #a<1 then return "" end
	local r=math.random(1,#a)
	return a[r]
end

aliveai.msghandler=function(self)
	if self.talking==1 and aliveai.msg[self.botname] then
		local name=aliveai.msg[self.botname].name
		local msg=aliveai.msg[self.botname].msg
		aliveai.msg[self.botname]=nil
		msg=string.sub(msg,string.len(self.botname)+2)
		self.on_spoken_to(self,self.botname,name,msg)
	end
	return self
end

minetest.register_on_chat_message(function(name, message)
	local pl=minetest.get_player_by_name(name)
	if not pl then return end
	local p=pl:get_pos()
	aliveai.on_chat(p,name,message)
end)

aliveai.on_chat=function(pos,name,message)
	local d1=25
	local en2
	for i,v in pairs(aliveai.active) do
		local en=v:get_luaentity()
		if en and aliveai.visiable(pos,v:get_pos()) and aliveai.get_bot_name(en.object)~=name then
			local d2=aliveai.distance(en,pos)
			if d1>d2 then
				d1=d2
				en2=en
			end
			if string.find(message,en.botname .." ",1)~=nil then
				aliveai.msg[en.botname]={name=name,msg=message}
				return
			elseif string.find(message,en.team .." ",1)~=nil then
				local na,na2=string.find(message," ")
				local ms=string.sub(message,na)
				local ms2=en.botname .. ms
				aliveai.msg[en.botname]={name=name,msg=ms2}
				if math.random(1,3)==1 then return end
			end
		end
	end
	if en2 then
		aliveai.msg[en2.botname]={name=name,msg=en2.botname .." "..message}
	end
	return
end