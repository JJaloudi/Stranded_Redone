include("map_system.lua")

concommand.Add("Spawnshit",function()
	for k,v in pairs(LOADENTS[game.GetMap()]) do
		local ent = ents.Create(v.Name)
		ent:SetPos(v.vec); ent:SetAngles(v.ang) 
		ent:Spawn()
	end
end)
 
net.Receive("ReceiveInteract",function()
	local int = net.ReadEntity()
	local pl = net.ReadEntity()
	local int_id = net.ReadUInt(16)
	
	if int:IsValid() then
		if pl:Alive() then
			if int.Interactions then
				int.Interactions[int_id].OnInteract(pl,int)
			else
				if GBL_Interactions[int:GetClass()] then
					GBL_Interactions[int:GetClass()][int_id].OnInteract(pl,int)
				end
			end
		end
	end
end)

function GetItemSpawnData(item)

	if ItemIsValid(item) then
		local tbl = {}
		for k,v in pairs(GetItem(item).Attributes) do
			tbl[k] = v.value
		end
		return tbl
	end
	
end

net.Receive("RequestItemInfo", function()
	local bagEnt = net.ReadEntity()
	local bagSlot = net.ReadUInt(8)
	local pl = net.ReadEntity()
	local bagItem = bagEnt.Inventory[bagSlot]
	
	if ItemIsValid(bagItem[1]) then
		net.Start("SendItemInfo")
		net.WriteTable(bagItem[2])
		net.Send(pl)
	end
end)

function NetworkInv(bagEnt)
	local tbl = {}
	for k,v in pairs(bagEnt.Inventory) do
		if v[1] then
			tbl[k] = v[1]
		else
			tbl[k] = v
		end
	end
	return tbl
end

net.Receive("RequestItemPreview", function()
	local bagEnt = net.ReadEntity()
	local pl = net.ReadEntity()
	
	if bagEnt.Inventory then
		net.Start("SendItemPreview")
			net.WriteTable(NetworkInv(bagEnt))
		net.Send(pl)
	end
end)

net.Receive("RequestItemPreview", function()
	local bagEnt = net.ReadEntity()
	local pl = net.ReadEntity()
	
	if bagEnt.Inventory then
		net.Start("SendItemPreview")
			net.WriteTable(NetworkInv(bagEnt))
		net.Send(pl)
	end
end)

net.Receive("RequestItemContainer", function()
	local requester = net.ReadEntity() //Who is requesting this
	local cHolder = net.ReadEntity() // What's the entity that holds this item
	local cSlot = net.ReadUInt(8) // Slot of the holding entities inventory
	
	if cHolder[cSlot] then
		net.Start("SendItemContainer")
			net.WriteTable(cHolder.Inventory[slot][2][1])
		net.Send(requester)
	end
end) 

net.Receive("SwapSlots",function()
	local containerEnt = net.ReadEntity()
	local slot1 = net.ReadUInt(8) //This is the receiver
	local slot2 = net.ReadUInt(8)	// This would be the active slot
	local selectedStack = net.ReadUInt(16)

	local item = containerEnt.Inventory[slot2][1]

	
	if GetItem(item) then
		if GetItem(item).Stack then	
		
			local stackAmt = 0	
			if selectedStack == 0 then
				stackAmt = containerEnt.Inventory[slot2].Stack
			else
				stackAmt = selectedStack
			end
			stackAmt = tonumber(stackAmt)
			
			if containerEnt.Inventory[slot1][1] == item then
				containerEnt:AddItemStack(slot1, stackAmt)
				containerEnt:AddItemStack(slot2, -stackAmt)
			else
				if containerEnt.Inventory[slot1][1] != false then		
					containerEnt:SwapSlots(slot2, slot1)
				else
					containerEnt.Inventory[slot1] = {item, containerEnt.Inventory[slot2][2], Stack = stackAmt}
					containerEnt:AddItemStack(slot2, -stackAmt)
				end
			end
			
		else
			containerEnt:SwapSlots(slot2, slot1	)
		end
	end
	
	if !containerEnt:IsPlayer() then
		if #containerEnt.Viewers > 0 then
			for k,v in pairs(containerEnt.Viewers) do
				net.Start("UpdateContainer")
					net.WriteEntity(containerEnt)
					net.WriteTable(containerEnt.Inventory)
				net.Send(v)
			end
		end
	end
	
end)

util.AddNetworkString("UpdateContainer")
net.Receive("TakeItemContainer",function()
	local bagEnt = net.ReadEntity() //Bag item is coming from
	local ent = net.ReadEntity() //Receiver
	local slot1 = net.ReadUInt(8) // Inventory
	local slot2 = net.ReadUInt(8) // Container
	local selectedStack = net.ReadUInt(16)
	
	local bagRef = bagEnt.Inventory[slot2]
	local rcvRef = ent.Inventory[slot1]
	
	if rcvRef[1] == false then
		if bagRef.Stack then

			local stackAmt = 0	
			if selectedStack == 0 then
				stackAmt = bagEnt.Inventory[slot2].Stack
			else
				stackAmt = selectedStack
			end
			stackAmt = tonumber(stackAmt)
			
			ent:SetInventoryItem(slot1, {bagRef[1], bagRef[2], Stack = stackAmt})			
			bagEnt:AddItemStack(slot2, -stackAmt)
		else
			ent:SetInventoryItem(slot1, bagRef)
			bagEnt:RemoveSlot(slot2)
		end
	else
		if rcvRef[1] == bagRef[1] then
			local stackAmt = 0	
			if selectedStack == 0 then
				stackAmt = bagEnt.Inventory[slot2].Stack
			else
				stackAmt = selectedStack
			end
			stackAmt = tonumber(stackAmt)
		
			ent:AddItemStack(slot1, stackAmt)
			bagEnt:AddItemStack(slot2, -stackAmt)
		else
		
			local oldItem = {bagRef[1], bagRef[2]}
			if bagRef.Stack then
				oldItem.Stack = bagRef.Stack
			end
		
			bagEnt:SetInventoryItem(slot2, rcvRef)
			ent:SetInventoryItem(slot1, oldItem)
		end
	end
	
	
	if !bagEnt:IsPlayer() then
		if bagEnt.Viewers then
			if #bagEnt.Viewers > 0 then
				for k,v in pairs(bagEnt.Viewers) do
					net.Start("UpdateContainer")
						net.WriteEntity(bagEnt)
						net.WriteTable(bagEnt.Inventory)
					net.Send(v)
				end
			end
		end
	end
	
	if !ent:IsPlayer() then
		if #ent.Viewers > 0 then
			for k,v in pairs(ent.Viewers) do
				net.Start("UpdateContainer")
					net.WriteEntity(ent)
					net.WriteTable(ent.Inventory)
				net.Send(v)
			end
		end
	end 
end)

net.Receive("GiveContainerItem",function()
	local container = net.ReadEntity()
	local pl = net.ReadEntity()
	local slot1 = net.ReadUInt(8)
	local slot2 = net.ReadUInt(8)
	
	local oI,oI2 = container.Inventory[slot2], pl.Inventory[slot1]
	
	container.Inventory[slot2] = oI2
	pl:SetInventoryItem(slot1, oI)
	
	print("Cock")
	
	if #container.Viewers > 0 then
		for k,v in pairs(container.Viewers) do
			net.Start("UpdateContainer")
				net.WriteEntity(container)
				net.WriteTable(container.Inventory)
			net.Send(v)
		end
	else
		print("uh")
	end
end)
	
net.Receive("ContainerMoveItems",function()
	local ent = net.ReadEntity()
	local slot1 = net.ReadUInt(8)
	local slot2 = net.ReadUInt(8)
	
	local inv = ent.Inventory
	
	local oS, oS2 = inv[slot1], inv[slot2]
	
	inv[slot2] = oS
	inv[slot1] = oS2
	
	print("Fuck")
end)

net.Receive("UseItemAction",function()
	local bagEnt = net.ReadEntity()
	local bagSlot = net.ReadUInt(8)
	local action = net.ReadUInt(8)
	local pl = net.ReadEntity()
	
	if ItemIsValid(bagEnt.Inventory[bagSlot][1]) then
		
		if bagEnt == pl then
			GetItem(bagEnt.Inventory[bagSlot][1]).Actions[action].Use(pl,bagSlot)
			pl:SaveInventory()
		else
			GetItem(bagEnt.Inventory[bagSlot][1]).Actions[action].Use(pl,bagSlot)
		end
		
	end
end)

net.Receive("DropItem",function()

	local pl = net.ReadEntity()
	local bagSlot = net.ReadUInt(8)
	
	if ItemIsValid(pl.Inventory[bagSlot][1]) then
		if pl:IsPlayer() then
			
			local pos = pl:GetShootPos()
			local ang = pl:GetAimVector()
			local tracedata = {}
			tracedata.start = pos
			tracedata.endpos = pos+(ang*80)
			tracedata.filter = pl
			local ent = ents.Create("ent_item")
			ent:SetPos(tracedata.endpos)
			ent:Spawn()
			ent:Activate()
			ent:SetItem(pl.Inventory[bagSlot][1], pl.Inventory[bagSlot].Data)
			
			pl.Inventory[bagSlot] = false
			pl.Inventory[bagSlot] = {}
			
 			net.Start("SendItemPreview")
				net.WriteTable(NetworkInv(pl))
			net.Send(pl)
			
		end
	end
	
end)

net.Receive("CraftItem",function()
	local pl = net.ReadEntity()
	local bench = net.ReadEntity()
	local it_id = net.ReadUInt(8)
	local level = 1
	
	local invTbl = {}
	local cData = {}
	local subTbl = {} //Key is slot, value is how much we take from slot.
	
	if GetItem(it_id) then
		if pl != bench then
			level = bench.CraftLevel
		end
		
		if GetItem(it_id).CraftData then
			local item = GetItem(it_id)
		
			for k,v in pairs(item.CraftData.Table) do
				cData[k] = v
				for key, val in pairs(pl.Inventory) do
					if val[1] == k then
						invTbl[key] = {ID = val[1], Stack = val.Stack or false}
					end
				end
				
				for key, val in pairs(invTbl) do
					if val.ID == k then
						if cData[k] then
							if val.Stack then
								if cData[k] - val.Stack  > 0 then
									cData[k] = cData[k] - val.Stack
									subTbl[key] = val.Stack
								
								print("We need to keep going")
								else
									subTbl[key] = cData[k]
									cData[k] = false
								end
							else
								print("non stack")
								if cData[k] - 1 <= 0 then
									subTbl[key] = 1
									cData[k] = false
									
									print("finished item "..GetItem(k).Name)
								else
									subTbl[key] = 1
									cData[k] = cData[k] - 1
									print("need "..cData[k].." more "..GetItem(k).Name)
								end
							end
						end
					end
				end
			end
			
			local count = 0 
			for k,v in pairs(cData) do
				if v then
					pl:Notify("You lack the resources to create a "..item.Name.."!")
					break
				else
					count = count + 1
				end
			end
			
	--[[ 		print("Craft Data ")
			PrintTable(cData)
			print("-------------")
			
			print("Inventory Table")
			PrintTable(invTbl)
			print("---------------")
			
			print("Subtraction Table")
			PrintTable(subTbl)
			print("---------------")
			 ]]
			 
 			if count == table.Count(cData) then
				for k,v in pairs(subTbl) do
					if pl.Inventory[k].Stack then
						pl:AddItemStack(k, -v)
					else
						pl:RemoveSlot(k)
					end
				end
				
				local slot 
				
				if item.CraftData.Stack then
					slot = pl:GetOpenItemStack(it_id)
					if !slot then
						slot = pl:GetOpenSlot()
						pl:SetInventoryItem( slot, CreateItem(it_id), item.CraftData.Stack )
					else
						if slot then
							pl:AddItemStack( slot, item.CraftData.Stack )
						else
							pl:Notify("Spawn on ground")
						end
						
						pl:Notify("Crafted " ..  item.CraftData.Stack .. "x ".. item.Name)
					end
				else
					slot = pl:GetOpenSlot()
					if slot then
						pl:SetInventoryItem( slot, CreateItem(it_id) )
						pl:Notify("Crafted "..GetItem(it_id).Name..".")
					else
						pl:Notify("Spawn on ground")
					end
				end
			end
		else
			pl:Notify("This item is uncraftable!")
		end
	else
		pl:Notify("Wut?")
	end
end)

net.Receive("UpgradeSkill",function()
	local pl = net.ReadEntity()
	local sk = net.ReadUInt(8)
	local level = net.ReadUInt(8)
	
	local curSkill = pl:GetSkill(sk)
	
	
	if pl:GetSkillPoints() - (level - curSkill) >= 0  then
		pl:SetSkill(sk, level)
		pl:AddSkillPoints(level - curSkill)
	end
end)

net.Receive("SellItem",function()
	local pl = net.ReadEntity()
	local shop = net.ReadEntity()
	local invslot = net.ReadUInt(8)
	
	local plInv = pl.Inventory[invslot]
	local shopSlot = table.Count(shop.Inventory) + 1
	
	if shop then
		if plInv then
			for k,v in pairs(shop.Inventory) do
				if v == false then
					shopSlot = k
					return
				end
			end
			
			shop.Inventory[shopSlot] = plInv
			
			local price = GetEstimatedValue(plInv) or GetItem(plInv[1]).Price
			
			pl:RemoveSlot(invslot)
			pl:AddMoney(math.floor(price/2))
		end
	end
end)

hook.Add("PlayerDeath","Ragdoll System", function(vic)
--[[ 	if vic:IsPlayer() then
		if vic:GetModel() then
			local plRagdoll = ents.Create("prop_ragdoll")
			plRagdoll:SetPos(vic:GetPos())
			plRagdoll.Interactable = true
			plRagdoll.Inventory = vic.Inventory
			plRagdoll.Player = vic
			plRagdoll:SetModel(vic:GetModel())
			plRagdoll:Spawn()
			plRagdoll:Activate()
			
			timer.Simple(30,function()
				plRagdoll:Remove()
			end)
			
			vic:GetRagdollEntity():Remove()
		end
	end ]]
end)

GBL_Interactions = {}

GBL_Interactions["prop_ragdoll"] = {
	[1] = {Name = "Check Bag", Args = function(user, ent) return ent.Interactable end,
	OnInteract = function(user, ent)
		net.Start("SendBag")
		net.WriteTable(ent.Inventory)
		net.WriteEntity(ent)
		net.Send(user)
	end
	}
}

GBL_Interactions["player"] = {
	[1] = {Name = "Examine Player",Args = true, OnInteract = function(user, ent) print(ent:Name()) end},
	[2] = {Name = "Invite To Squad",
	Args = function(user) 
		if user:GetSquad() then 
			return true 
		else 
			return false
		end
	end, 
	OnInteract = function(user, ent) AddPlayerToSquad(user:Team(), user:GetSquad(), ent) end},
	[3] = {Name = "Check Bag",
	Args = function(user, opl) 
		if user:Team() == opl then
			if opl.HasBag then
				return true
			else
				return false
			end
		else
			return false
		end
	end,
	OnInteract = function(user, ent)
		print("Woot")
	end},
	[4] = {Name = "Add to Faction",
	Args = function(pl, int)
		if pl.FacID then
			return pl:HasFlag(FLAG_LEADER)
		end
	end,
	OnInteract = function(pl, int) 
		AddFactionPlayer(pl.FacID, int, 1) 
	end
	}
	
}

GBL_Interactions["npc_shop"] = {
	[1] = {Name = "What're you selling?",
			Args = true, 
			OnInteract = function(user, ent) 
				print("SHOP ACCESS")
				table.insert(ent.Viewers, user)
			end
		}
}

GBL_Interactions["npc_miner"] = {
		[1] = {Name = "Greet",
			Args = true, 
			OnInteract = function(user, ent) 

			end
		}
}

GBL_Interactions["ent_persona"] = {
	[1] = {Name = "Greet",
			Args = true, 
			OnInteract = function(user, ent) 

			end
		}
}

GBL_Interactions["prop_vehicle_jeep"] = {
	[1] = {Name = "Lock Car",Args = true, OnInteract = function(user, ent) end},
	[2] = {Name = "Unlock Car",Args = true, OnInteract = function(user, ent) end},
	[3] = {Name = "Check Inventory", Args = true,
	OnInteract = function(user,ent)
		if !ent.Inventory then
			ent.Inventory = {}
			for i = 1, 3 do
				ent.Inventory[i] = {}
			end
		end
		net.Start("SendBag")
			net.WriteTable(ent.Inventory)
			net.WriteEntity(ent)
		net.Send(user)
	end}
}

hook.Add("Think", "Interact NonEnts", function()
	for k,v in pairs(player.GetAll()) do
		if !v:InVehicle() then
			if v:KeyDown(IN_USE) then
				if v.LastUse then
					if v.LastUse < CurTime() then
						v.LastUse = CurTime() + 0.5
						local tr = v:GetEyeTrace()
						if GBL_Interactions[tr.Entity:GetClass()] then
							net.Start("PlayerInteractTrace")
							
								net.WriteEntity(tr.Entity)
								local tbl = {}
								for key,inf in pairs(GBL_Interactions[tr.Entity:GetClass()]) do
									if inf.Args then
										if inf.Args == true then
											tbl[key] = inf.Name
										else
											if inf.Args(v, tr.Entity) then
												tbl[key] = inf.Name
											end
										end
									end
								end
								net.WriteTable(tbl)
								net.WriteVector(tr.HitPos)
							net.Send(v)
						end
					end
				else
					v.LastUse = CurTime()
				end
			end
		end
	end
end)


util.AddNetworkString("RemoveViewer")
function RemoveViewer(ent, pl)
	if IsValid(ent) then
		table.RemoveByValue(ent.Viewers, pl)
	end
end
net.Receive("RemoveViewer", function() RemoveViewer(net.ReadEntity(), net.ReadEntity()) end)


util.AddNetworkString("BuyItem")
util.AddNetworkString("UpdateShop")
net.Receive("BuyItem", function()
	local pl = net.ReadEntity()
	local shopEnt = net.ReadEntity()
	local slot = net.ReadUInt(16)
	local stack = net.ReadUInt(16)
	local invSlot = net.ReadUInt(16)
	
	stack = stack or 1
	
	local it = GetItem(shopEnt.Inventory[slot][1])
	local price = 0
	if it.Stack then
		price = stack * (it.Price or 10)
	else
		if shopEnt.Inventory[slot].Price then
			price = shopEnt.Inventory[slot].Price
		else
			price = it.Price
		end
	end
	
	local bSuccess = true
	
	print("Slot being used "..invSlot)
	
	if pl:GetMoney() > price then
		if it.Stack then
			if pl.Inventory[invSlot][1] != false then
				print("Dis slot ain't empty")
				if pl.Inventory[invSlot][1] == it.ID then
					pl:AddItemStack(invSlot, stack)
					
					print("Stack we tried is good to go :)")
				else
					local nSlot = pl:GetOpenItemStack(it.ID)
					if nSlot then
						pl:AddItemStack(nSlot, stack)
						
						print("Found a stack that already exists")
					else
						nSlot = pl:GetOpenSlot()
						if nSlot then
							local tbl = shopEnt.Inventory[slot]
							tbl.Stack = stack
							pl:SetInventoryItem(nSlot, shopEnt.Inventory[slot])
							
							print("New open slot")
						else
							bSuccess = false
							pl:Notify("Your inventory is full!")
						end
					end
				end
			else
				local tbl = shopEnt.Inventory[slot]
				tbl.Stack = stack
				pl:SetInventoryItem(invSlot, shopEnt.Inventory[slot])
				
				print("Empty slot is g2g :)")
				
				print("yea dude")
			end
		else
			if pl.Inventory[invSlot][1] then
				local nSlot = pl:GetOpenSlot()
				if nSlot then
					pl:SetInventoryItem(nSlot, shopEnt.Inventory[slot])
					
					print("New slot we discovered")
				else
					bSuccess = false
					pl:Notify("Your inventory is full!")
				end
				
				print("The slot you tried is full")
			else
				pl:SetInventoryItem(invSlot, shopEnt.Inventory[slot])
				
				print("YE NIGa")
			end
		end
		
		if bSuccess then
			for k,v in pairs(shopEnt.Viewers) do
				net.Start("UpdateShop")
					net.WriteUInt(slot, 16)
					net.WriteUInt(stack, 16)
				net.Send(v)
			end
			
			pl:AddMoney(-price)
		end
	else
		pl:Notify("You're broke, dude!")
	end 
end)
