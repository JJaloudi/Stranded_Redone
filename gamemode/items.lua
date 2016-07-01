//The structure of the SQL tables for items go as:
//ID in SQL table - Data( JSON; (ID, Attributes) ) - Location of item (Not configured yet.)


function GetFormattedAttribute(id)
	local ref = GetItem(id)
	
	local savedVar = {}
	savedVar["ID"] = ref.ID
	savedVar["Attributes"] = {}
	for k,v in pairs(ref.Attributes) do
		savedVar["Attributes"][k] =  v.value
	end
	
	return savedVar
end

local function seralize(val)
	if type(val) == "boolean" then	
		if val then
			return 1
		else
			return 0
		end
	else
		return tonumber(val)
	end
end

net.Receive("UseItem",function()
	local entUser = net.ReadEntity()
	local entContainer = net.ReadEntity()
	local cSlot = net.ReadUInt(8)
	local cAction = net.ReadUInt(8)
	
	local tbl_item = GetItem(entContainer.Inventory[cSlot][1])
	if tbl_item then
		print("Item exists")
		for k,v in pairs(tbl_item.Actions) do
			if cAction == k then
				v.Use(entUser, entContainer, cSlot)
			end
		end
	end
end)

net.Receive("RequestBuffData",function()
	local requester = net.ReadEntity()
	local bagEnt = net.ReadEntity()
	local slot = net.ReadUInt(8)
	local containerSlot = net.ReadUInt(8)
	local ref
	
	print("SLOT OF BOX IS: "..slot)
	print("SLOT OF CONTAINER IS: "..containerSlot)
	
	if containerSlot != 0 then
		ref = bagEnt.Inventory[containerSlot][2][slot]
	else
		ref = bagEnt.Inventory[slot]
	end
	
	if GetItem(ref[1]) then
		if GetItem(ref[1]).Category == "Buff" then
			
			local Data = {Name = ref[2][3], Type = ref[2][1], Amount = ref[2][2]}
				
			net.Start("RetrieveBuffData")
				net.WriteTable(Data)
			net.Send(requester)
		end
	end
end)

net.Receive("RequestContainerInventory",function()
	local requester = net.ReadEntity()
	local bagEnt = net.ReadEntity()
	local slot = net.ReadUInt(8)
	
	local refInv = bagEnt.Inventory[slot][2]
	
	net.Start("SendContainerInventory")
		net.WriteTable(refInv)
	net.Send(requester)
end)

net.Receive("UpgradeWeapon",function()
	local pl = net.ReadEntity()//Location of buff we're trying to use
	local wepSlot = net.ReadUInt(8) // slot of inv where wep is
	local wepUpgrade = net.ReadUInt(8) //slot of wep we're upgrading
	local invUpgrade = net.ReadUInt(8) // slot in inv where buff is
	
	if pl.Inventory[invUpgrade] then
	
		oldLevel = GetWeaponLevel(pl.Inventory[wepSlot])
	
		pl.Inventory[wepSlot][2][wepUpgrade] = pl.Inventory[invUpgrade][2]
		
		pl:RemoveSlot(invUpgrade)
		
		if pl:IsPlayer() then
		
			pl:SaveInventory()	
			
			net.Start("UpdateSlot")
				net.WriteUInt(wepSlot,8)
				net.WriteTable(pl.Inventory[wepSlot])
			net.Send(pl)
			
		end
		
		local level = GetWeaponLevel(pl.Inventory[wepSlot])
		local prefix
			
			if !ITEM_NAMES[GetItem(pl.Inventory[wepSlot][1]).Category][level] then
				prefix = ITEM_NAMES[GetItem(pl.Inventory[wepSlot][1]).Category][#ITEM_NAMES[GetItem(pl.Inventory[wepSlot][1]).Category]]
				level = #ITEM_NAMES[GetItem(pl.Inventory[wepSlot][1]).Category]
			else
				prefix = table.Random(ITEM_NAMES[GetItem(pl.Inventory[wepSlot][1]).Category][level])
			end
		
		
		if oldLevel != level then
			pl.Inventory[wepSlot].Name = prefix .. " " .. GetItem(pl.Inventory[wepSlot][1]).Name
			
			net.Start("SendUpdatedName")
				net.WriteString(prefix .. " " .. GetItem(pl.Inventory[wepSlot][1]).Name)
			net.Send(pl)
		end
		
	end
end)

net.Receive("RequestWeapons",function()
	local requester = net.ReadEntity()
	
	local tbl = {}
	
	for k,v in pairs(requester.Inventory) do
		if GetItem(v[1]) then
			if GetItem(v[1]).Category == "Weapon" ||  GetItem(v[1]).Category == "Tool" then
				tbl[k] = {Item = v[1], Data = v[2], Name = v.Name}
			end
		end
	end

	net.Start("SendWeapons")
		net.WriteTable(tbl)
	net.Send(requester)
end)

function GetWeaponLevel(wep)
	local points = 0
	for k,v in pairs(wep[2]) do
		if v[2] then	
			points = points + v[2]
		end
	end
	local level = 1
	if math.floor(points/20) <= 0 then
		level = 1
	else
		level = math.floor(points/20)
	end

		
	return level
end

net.Receive("RequestBuffs",function()
	local requester = net.ReadEntity()

	
	local tbl = {}
	
	for k,v in pairs(requester.Inventory) do
		if GetItem(v[1]) then
			if GetItem(v[1]).Category == "Buff" then
				tbl[k] = {Data = v[2], ID = v[1]}
			end
		end
	end
	
	net.Start("SendBuffs")
		net.WriteTable(tbl)
	net.Send(requester)
end)

function CreateRandomBuff(it) //Just a test function to create data for buffs generated into the test entity.
	PrintTable(GetItem(it))
	local ref = BUFF_TYPES[GetItem(it).BuffType]
	
	local type = math.random(1, #ref)
	local buffamount = math.random(1, 25)
	local buffname = table.Random(ref[type].CommonNames)
	
	return {type, buffamount, buffname}
end

function GenerateWeaponName(wepId)
	local ref = GetItem(wepId)
	if ref then
		return table.Random(ITEM_NAMES[ref.Category][1]) .." " .. ref.Name
	end
end

function CreateWeaponAttributes()
	local amt = math.random(1,5)
	local buffs = {}
	
	for i = 1,amt do
		buffs[i] = {}
	end
	
	return buffs
end

concommand.Add("CheckBox",function(pl)
	local tr = pl:GetEyeTrace()
	if tr.Entity then
		PrintTable(tr.Entity.Inventory)
	end
end)

net.Receive("EquipItem", function() 
	local invEnt = net.ReadEntity()
	local intEnt = net.ReadEntity()
	local slot = net.ReadUInt(8)
	
	local ref = invEnt.Inventory[slot]
	
	
	if slot != 0 && slot <= #invEnt.Inventory then
		if ref then
			if GetItem(ref[1]) then	
				if table.HasValue({"Tool", "Weapon"}, GetItem(ref[1]).Category) then
					if !intEnt.EquippedItem then
						local wep = intEnt:Give(GetItem(ref[1]).EntName)
							
						wep:SetStats(ref[2])						
						wep.Data = ref
							
						intEnt.EquippedItem = wep
							
						invEnt:RemoveSlot(slot)
								
					else 
							
						intEnt:Notify("You must unequip your current item before equipping another!")
					end
				end				
			end
		end 
	end	
end)

hook.Add("PlayerDeath", "FixEquip", function(pl)
	pl.EquippedItem = false
end)

concommand.Add("unequip",function(pl)
	if pl.EquippedItem then
		local slot = pl:GetOpenSlot()
	
		if slot then
			pl:Notify("Moved item to slot #"..slot)
			pl:SetInventoryItem(slot, pl.EquippedItem.Data)
			
			pl:StripWeapon(pl.EquippedItem:GetClass())
			pl.EquippedItem = false
		else
			pl:Notify("You need to free up some inventory space to do this!")
		end
	else
		pl:Notify("You have nothing to unequip!")
	end
end)

function CreateItem(id)
	local item = GetItem(id)
	
	if item.Category == "Weapon"|| item.Category == "Tool" then
		return {id, CreateWeaponAttributes(), Name = GenerateWeaponName(id)} 
	elseif item.Category == "Buff" then
		local buff = CreateRandomBuff(id)
		return {id, buff, Name = buff[3]} 
	else
		return {id, GetItemSpawnData(id)}
	end

end
