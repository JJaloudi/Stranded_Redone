	util.AddNetworkString("InitData")
	util.AddNetworkString("SendMoney")
	util.AddNetworkString("SendLevel")
	util.AddNetworkString("SendExp")
	util.AddNetworkString("SendSkills")
	util.AddNetworkString("SendKarma")
	util.AddNetworkString("SendAllSkills")
	util.AddNetworkString("SendPerk")
	util.AddNetworkString("PlayerInteract")
	util.AddNetworkString("ReceiveInteract")
	util.AddNetworkString("PlayerInteractTrace")
	util.AddNetworkString("UpdateSquad")
	util.AddNetworkString("SetSquadPlayer")
	util.AddNetworkString("QuitSquad")
	util.AddNetworkString("RemoveSquad")
	util.AddNetworkString("SendBag")
	util.AddNetworkString("UpdateBagMenu")
	util.AddNetworkString("SelfInteract")
	util.AddNetworkString("RequestItemInfo")
	util.AddNetworkString("SendItemInfo")
	util.AddNetworkString("RequestItemPreview")
	util.AddNetworkString("SendItemPreview")
	util.AddNetworkString("UseItemAction")
	util.AddNetworkString("DropItem")
	util.AddNetworkString("HintPlayerEntity")
	util.AddNetworkString("NotifyPlayer")
	util.AddNetworkString("CraftingSystem")
	util.AddNetworkString("CraftItem")
	util.AddNetworkString("OpenInventory")
	util.AddNetworkString("UpdateSlot")
	util.AddNetworkString("ContainerMoveItems")
	util.AddNetworkString("TakeItemContainer")
	util.AddNetworkString("GiveItemContainer")
	util.AddNetworkString("PlayerCraftItem")
	util.AddNetworkString("SendSkill")
	util.AddNetworkString("SendSkillPoints")
	util.AddNetworkString("UpgradeSkill")
	util.AddNetworkString("SendStamina")
	util.AddNetworkString("SendHunger")
	util.AddNetworkString("LoadCharacters")
	util.AddNetworkString("CreateCharacter")
	util.AddNetworkString("ChooseCharacter")
	util.AddNetworkString("FactionMoney")
	util.AddNetworkString("FactionPlayers")
	util.AddNetworkString("FactionAddPlayer")
	util.AddNetworkString("FactionRemovePlayer")
	util.AddNetworkString("FactionName")
	util.AddNetworkString("FactionRanks")
	util.AddNetworkString("SendCharacterInfo")
	util.AddNetworkString("FactionKickPlayer")
	util.AddNetworkString("FactionRemoved")
	util.AddNetworkString("FactionCharOffline")
	util.AddNetworkString("FactionPlayerRank")
	util.AddNetworkString("FactionPromotePlayer")
	util.AddNetworkString("FactionDemotePlayer")
	util.AddNetworkString("FactionSetRankFlag")
	util.AddNetworkString("FactionSetRankName")
	util.AddNetworkString("FactionSetRankPay")
	util.AddNetworkString("SendItemPreview")
	util.AddNetworkString("SwapSlots")
	util.AddNetworkString("UseItem")
	util.AddNetworkString("OpenItemContainer")
	util.AddNetworkString("SendItemContainer")
	util.AddNetworkString("RequestItemContainer")
	util.AddNetworkString("RequestBuffData")
	util.AddNetworkString("RetrieveBuffData")
	util.AddNetworkString("RequestContainerInventory")
	util.AddNetworkString("SendContainerInventory")
	util.AddNetworkString("UpgradeWeapon")
	util.AddNetworkString("DoProgressBar")
	util.AddNetworkString("RequestWeapons")
	util.AddNetworkString("SendWeapons")
	util.AddNetworkString("RequestBuffs")
	util.AddNetworkString("SendBuffs")
	util.AddNetworkString("SendUpdatedName")
	util.AddNetworkString("SendPlayerInv")
	util.AddNetworkString("SendPlayerInvSlot")
	util.AddNetworkString("BuyItem")
	util.AddNetworkString("SellItem")
	util.AddNetworkString("EquipItem")
	util.AddNetworkString("UpdateLocation")
	util.AddNetworkString("TerritoryOwnerChange")
	util.AddNetworkString("SendShop")
	
	util.AddNetworkString("StartGhosting")
	util.AddNetworkString("EndGhosting")
	util.AddNetworkString("StartDeployment")
	util.AddNetworkString("CancelDeployment")
	util.AddNetworkString("FinishPlacement")
	
net.Receive("ChooseCharacter",function()
	local pl = net.ReadEntity()
	local id = net.ReadUInt(8)
	
	pl:LoadCharacter(id)
end)

net.Receive("CreateCharacter",function()
	local pl = net.ReadEntity()
	local Data = net.ReadTable()
	local pName = net.ReadString()
	local id = 1
	
	pl.Inventory = {}
	for i = 1,DEFAULT_SLOTS do
		pl.Inventory[i] = {[1] = false}
	end
	pl.Skills = {}
	for k,v in pairs(SKILLS) do
		pl.Skills[v.ID] = 0
	end
	
	if Data[1] && Data[2] then
		if pName then
			print("YA")
			db:Query("SELECT * FROM player where steamid='"..pl:SteamID().."'",function(r,s,e)
			id = #r[1].data + 1 or 1
			
				local skills = util.TableToJSON(pl.Skills)
				db:Query("INSERT INTO player (steamid, charid, inventory, gender, model, name, skills) VALUES('"..pl:SteamID().."', "..tonumber(id)..", '"..util.TableToJSON(pl.Inventory).."', '"..Data[1].."', "..Data[2]..", '"..pName.."', '"..skills.."')")
			end)	
		end
	end
	
	timer.Simple(1.5,function()
		pl:LoadCharacter(id)
	end)
end)

concommand.Add("testshop",function(pl)
	local ent = ents.Create("shop_npc")
	ent:SetPos(pl:GetPos())
	ent:Spawn()
	--ent:SetItem(1)
	--ent:SetWorth(math.random(1,200))
end)

concommand.Add("testent",function(pl)
	local ent = ents.Create("ent_bag")
	ent:SetPos(pl:GetPos())
	ent:Spawn()
	--ent:SetItem(1)
	--ent:SetWorth(math.random(1,200))
end)

hook.Add("PlayerInitialSpawn","Set Player Up",function(pl)
	local cTbl = {}
	db:Query("SELECT * FROM player WHERE steamid='"..pl:SteamID().."'",function(r)
			if r[1].data then
				for k,v in pairs(r[1].data) do
					cTbl[k] = {
						ID = tonumber(v.charid),
						Level = tonumber(v.level),
						Exp = tonumber(v.exp),
						Money = tonumber(v.money),
						Karma = tonumber(v.karma),
						Name = v.name,
						Fac = v.facid or false,
						FacRank = v.facrank or 0,
						Model = Models[v.gender][v.model].Model
					}
				end
			end
		
		
		net.Start("LoadCharacters")
		net.WriteTable(cTbl)
		net.Send(pl)
	end)
end)

concommand.Add("control_SetTeam",function(pl,_,args)
	if team.Joinable(tonumber(args[1])) then
		pl:SetTeam(tonumber(args[1]))
	end
end)

local P = FindMetaTable("Player") 

function P:Notify(text, dur, col, urg)
	net.Start("NotifyPlayer")
		net.WriteString(text)
	net.Send(self)
end


function P:Hint(area,text)
	if IsEntity(area) then
		net.Send("HintPlayerEntity")
			net.WriteEntity(area)
			net.WriteString(text)
		net.Send(self)
	end
end

function P:SetMoney(amt)
	amt = amt or 0
	self.Money = amt
	db:Query("UPDATE player SET money="..amt.." WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
	net.Start("SendMoney")
		net.WriteUInt(amt, 16)
	net.Send(self)
end

function P:GetMoney()
	return self.Money
end

function P:AddMoney(amt)
	self:SetMoney(self:GetMoney() + amt)
end

function P:SetLevel(lvl)
	self.Level = lvl or 1
	db:Query("UPDATE player SET level="..self.Level.." WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
	net.Start("SendLevel")
		net.WriteUInt(self.Level, 16)
	net.Send(self)
end

function P:GetLevel()
	return self.Level or 1
end

function P:AddLevel(lvl)
	self:SetLevel(self:GetLevel() + lvl)
end

function P:LevelUp()
	self:AddLevel(1)
	self:AddSkillPoints(1)
	self:Notify("You're now level "..self:GetLevel().." and you were rewarded a skill point!")
end

function P:GetExpToLevel()
	return self:GetLevel() * 200
end

function P:SetExp(exp)
	exp = exp or 0
	if exp >= self:GetExpToLevel() then
		self:SetExp(exp - self:GetExpToLevel() )
		self:LevelUp()
	else
		self.Exp = exp
		db:Query("UPDATE player SET exp="..exp.." WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
		net.Start("SendExp")
			net.WriteUInt(exp, 16)
		net.Send(self)
	end
end

function P:GetExp()
	return self.Exp or 0
end

function P:AddExp(exp)
	self:SetExp(self:GetExp() + exp)
end 

function P:SetKarma(amt)
	amt = amt or 0
	self.Karma = amt
	db:Query("UPDATE player SET karma="..amt.." WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
	net.Start("SendKarma")
		net.WriteUInt(amt, 16)
	net.Send(self)
end

function P:GetKarma()
	return self.Karma
end

function P:DoKarma(amt)
	self:SetKarma(self:GetKarma() + amt)
end

function P:SetSquad(sq_id)
	self.Squad = sq_id
	if sq_id then
		net.Start("SetSquadPlayer")
			net.WriteEntity(TEAM_DATA[self:Team()].Squads[sq_id].Leader)
			net.WriteTable(TEAM_DATA[self:Team()].Squads[sq_id].Players)
		net.Send(self)
	end
end

function P:GetSquad()
	if self.Squad then
		return self.Squad
	else
		return false
	end
end

function P:SaveInventory()
	db:Query("UPDATE player SET inventory='"..util.TableToJSON(self.Inventory).."' WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
end
	


function P:UpdateLocation(location)
	self.Location = location
	
	net.Start("UpdateLocation")
	
	if location then
		net.WriteString(location)
		if TERRITORIES[string.lower(game.GetMap())][location].Controller then
			net.WriteString(Factions[TERRITORIES[string.lower(game.GetMap())][location].Controller].Name)
		else
			net.WriteString("Disabled/Unowned")
		end
	else
		net.WriteString("Badlands")
	end
	
	net.Send(self)
end

local ENT = FindMetaTable("Entity")

function ENT:SetInventoryItem(slot, data, stack)
	if slot then
		local rItem = GetItem(data[1])
		if rItem then
			
			self.Inventory[slot] = data
			if stack then
				self.Inventory[slot].Stack = stack
			end

			if self:IsPlayer() then
				net.Start("UpdateSlot")
					net.WriteUInt(slot,8)
					net.WriteTable(data)
				net.Send(self)
				
				self:SaveInventory()
			end
		end
	end
end

function ENT:GetOpenSlot()
	for k,v in pairs(self.Inventory) do
		if !v[1] then
			return k
		end
	end
end

function ENT:SetItemStack(slot, amt)
	if self.Inventory[slot][1] then
		if amt > 0 then
			self.Inventory[slot].Stack = amt
		else
			print("Removed")
		
			if self:IsPlayer() then
				self:RemoveSlot(slot)
			else
				self.Inventory[slot] = {[1] = false}
			end
		end
		
		if self:IsPlayer() then
			net.Start("UpdateSlot")
				net.WriteUInt(slot,8)
				net.WriteTable(self.Inventory[slot])
			net.Send(self)
		end
 	end
end

function ENT:GetItemStack(slot)
	return self.Inventory[slot].Stack or 1
end

function ENT:AddItemStack(slot, amt)
	self:SetItemStack(slot, self:GetItemStack(slot) + amt)
end

function ENT:GetOpenItemStack(id)
	if GetItem(id).Stack then
		for k,v in pairs(self.Inventory) do
			if v[1] == id then
				return k
			end
		end
	end
end
		
function ENT:RemoveSlot(slot)
	self.Inventory[slot] = nil
	self.Inventory[slot] = {false}
	
	if self:IsPlayer() then
		net.Start("UpdateSlot")
			net.WriteUInt(slot,8)
			net.WriteTable({false})
		net.Send(self)
			
		self:SaveInventory()
	end
end

function ENT:SwapSlots(s1,s2)
	local oSlot1, oSlot2 = self.Inventory[s1], self.Inventory[s2]
	
	self.Inventory[s2] = oSlot1 or {}
	self.Inventory[s1] = oSlot2 or {}
	
	if self:IsPlayer() then
		timer.Simple(1,function()
			self:SaveInventory()
		end)
	end
end

function ENT:GetInventorySlot(slot)
	return self.Inventory[slot] or false
end

function ENT:HasItem(id)
	if !GetItem(id) then return end
	
	for k,v in pairs(self.Inventory) do
		if v[1] == id then
			return k
		end
	end
end

function P:SetSkillPoints(amt)
	self.SkillPoints = amt
	
	db:Query("UPDATE player SET skillpoints="..amt.." WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
	
	net.Start("SendSkillPoints")
		net.WriteUInt(amt,8)
	net.Send(self)
end

function P:GetSkillPoints()
	return self.SkillPoints or 0
end

function P:AddSkillPoints(amt)
	self:SetSkillPoints(self:GetSkillPoints() + amt)
end

function P:SetSkill(skill,amt, save)
	if GetSkill(skill) then
		self.Skills[skill] = tonumber(amt)
		
		net.Start("SendSkill")
			net.WriteUInt(skill,8)
			net.WriteUInt(tonumber(amt),8)
		net.Send(self)
		
		db:Query("UPDATE player SET skills='"..util.TableToJSON(self.Skills).."' WHERE steamid='"..self:SteamID().."' AND charid ='"..self.CharID.."'")
	
	end
end

function P:GetSkill(skill)
	return self.Skills[skill] or 0
end

function P:AddSkill(skill,amt)
	self:SetSkill(skill, self:GetSkill(skill) + amt, true)
end

function P:SetWetLevel(lvl)
	self.Wet = lvl
end

function P:GetWetLevel()
	return self.Wet or 0
end

function P:SetHunger(amt)
	self.Hunger = amt
	net.Start("SendHunger")
		net.WriteUInt(amt,8)
	net.Send(self)
end

function P:GetHunger()
	return self.Hunger or 100 + (self:GetSkill(8) * GetSkill(8).Value)
end

function P:AddHunger(amt)
	self:SetHunger(self:GetHunger() + amt)
end

function P:SetSicknessLevel(lvl)
	self.Sick = lvl
end

function P:GetSicknessLevel()
	return self.Sick or 0
end

function P:SetStamina(amt)
	self.Stamina = amt
	net.Start("SendStamina")
		net.WriteUInt(amt,8)
	net.Send(self)
end

function P:GetStamina()
	return self.Stamina or 100
end

function P:AddStamina(amt)
	self:SetStamina(self:GetStamina() + amt)
end

function P:LoadCharacter(id)
	local charid = id
	self.Skills = {}; self.Money = 500; self.Level = 1; self.Exp = 0; self.Karma = 0; self.Inventory = {}; self.Quests = {}
	
	db:Query("SELECT * FROM player WHERE steamid ='"..self:SteamID().."' and charid ='"..charid.."'",function(r,s,e)
		if r[1].data then
			local ref = r[1].data[1]
			PrintTable(ref)
			self.CharID = tonumber(ref.charid)
			self.CharName = ref.name
			self.FacRank = ref.facrank
			self:SetLevel(tonumber(ref.level))
			self:SetExp(tonumber(ref.exp))
			self:SetMoney(tonumber(ref.money))
			self:SetKarma(tonumber(ref.karma))
			self.Inventory = util.JSONToTable(ref.inventory)
			self.Skills = util.JSONToTable(ref.skills) || {}
			
			net.Start("SendSkills")
				net.WriteTable(self.Skills)
			net.Send(self)
			
			if ref.activequests then
				self.Quests = util.JSONToTable(ref.activequests)
			end
			
			net.Start("SendCharacterInfo")
				net.WriteUInt(self.CharID, 16)
				net.WriteString(self.CharName)
			net.Send(self)
			
			if ref.facid then
				self:SetFaction(tonumber(ref.facid))
			end
			self:SetSkillPoints(tonumber(ref.skillpoints))
			self:SetModel(Models[tostring(ref.gender)][tonumber(ref.model)].Model)
			
			net.Start("SendPlayerInv")
				net.WriteTable(util.JSONToTable(ref.inventory))
			net.Send(self)
		end
	end)
	
--[[ 	for k,v in pairs(SKILLS) do
		db:Query("SELECT points FROM "..v.Name.." WHERE stid='"..self:SteamID().."' AND charid ='"..charid.."'",function(r,s,e)
			if r[1] then
				print("Skill: "..r[1][1])
				self:SetSkill(v.ID, r[1][1] or 0)
			end
		end)
	end  ]]
	
	self:Spawn()
end

function CharacterIsOnline(steamid, charid)
	for k,v in pairs(player.GetAll()) do
		if v.CharID == charid && v:SteamID() == steamid then
			return true
		end
	end
end

function player.GetByCharacterID(charid)
	for k,v in pairs(player.GetAll()) do
		if v.CharID == charid then
			return v
		end
	end
end

function player.GetBySteamID(steamid)
	for k,v in pairs(player.GetAll()) do
		if v:SteamID() == steamid then
			return v
		end
	end
end


util.AddNetworkString("SendFactionInfo")
util.AddNetworkString("SendFactionHierarchy")
util.AddNetworkString("SendFactionPlayers")
util.AddNetworkString("FactionPlayerOnline")
function P:SetFaction(facid)
	if facid != 0 then
		if !Factions[facid] then
		
			LoadFactionData(facid)
			
		end
		
		timer.Simple(1,function() //We need a second to load the info from the database.
			self.FacID = facid
		
			local id = 0
			for k,v in pairs(Factions[facid].Players) do
				if v.CharID == self.CharID then
					id = k
					
					self.FacRank = v.Rank
				end
			end
			
			for k,v in pairs(GetOnlineFactionPlayers(facid)) do
				net.Start("FactionPlayerOnline")
					net.WriteUInt(id,8)
				net.Send(v)
				
				print(v:Name())
			end
		
			net.Start("SendFactionInfo")
				net.WriteString(Factions[facid].Name)
				net.WriteUInt(facid, 16)
			net.Send(self)
			
			
			db:Query("select fac_data from factions where fac_id="..facid,function(res)
				if res[1].data then
					local tbl = util.JSONToTable(res[1].data[1].fac_data)
			
					net.Start("SendFactionHierarchy")
						net.WriteTable(tbl.Ranks)
					net.Send(self)
				end
			end)
			local tbl = {}
			
			for k,v in pairs(Factions[facid].Players) do
				tbl[k] = v
				if player.GetBySteamID(v.SteamID) then
					if player.GetBySteamID(v.SteamID).CharID == v.CharID then
						tbl[k].Online = true
					end
				end
			end
			
			net.Start("SendFactionPlayers")
				net.WriteTable(Factions[facid].Players)
			net.Send(self)
		end)
	else
		self.FacID = false
	end
end

function P:SaveFaction(fac_id, pID)
	if fac_id then
		db:Query("update player set facid ='"..fac_id.."' where steamid ='"..self:SteamID().."' and charid='"..self.CharID.."'")
		self:SetFaction(fac_id)
	end
end

function P:HasFlag(flag)
	if self.FacID && self.FacRank then
		return table.HasValue(Factions[self.FacID].Data.Ranks[self.FacRank].Flags, flag) 
	else
		print("na b")
		return false
	end
end

function P:StartPlacement(itm)
	net.Start("StartGhosting")
		net.WriteUInt(itm, 16)
	net.Send(self)
	
	self:Notify("Left click to place the item, right click to cancel placement. Use keys Q and E to rotate.")
	
	self.bGhosting = true
end

function P:StopPlacement()
	net.Start("EndGhosting") net.Send(self)

	self.bGhosting = false
end

net.Receive("StartDeployment", function()
	local invEnt = net.ReadEntity()
	local pl = net.ReadEntity()
	local slot = net.ReadUInt(16)
	
	local item = invEnt.Inventory[slot][1]
	
	if item then
		pl:StartPlacement(item)
		invEnt:RemoveSlot(slot)
		
		pl.DeploymentItem = item
	end
end)

hook.Add("PlayerDeath", "RemoveDeployment", function(pl)
	pl:StopPlacement()

	if pl.DeploymentItem then
	
	end
end)

net.Receive("FinishPlacement",function()
	local pl = net.ReadEntity()
	local item = net.ReadUInt(16)
	local vPos = net.ReadVector()
	local aPos = net.ReadAngle()
	
	local con = ents.Create(GetItem(item).DeployData.Ent)
	con:SetPos(vPos)
	con:SetAngles(aPos)
	con:Spawn()
	con:Activate()
	
	pl.DeploymentItem = false
	
	pl:StopPlacement()
end)