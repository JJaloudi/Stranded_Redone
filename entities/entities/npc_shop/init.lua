AddCSLuaFile()

ENT.Base 			= "ent_base_control"
ENT.Type = "ai"

function ENT:Initialize( )
	self.Inventory = {}
	local itmList = {}
	
	self.Worth = 1000
	
	for k,v in pairs(ITEMS) do
		--[[ if v.Rarity then
			local chance = math.random(1,10)
			local cPercent = math.Clamp((chance * 100) / 10, 0, 100)
			
			if cPercent >= v.Rarity then
				local i = table.Count(self.Inventory) + 1
				local it = GetItem(v.ID)
			
				if it.Category == "Buff" then 
					self.Inventory[i] = {it.ID, CreateRandomBuff(it.ID)}
				elseif it.Category == "Weapon" || it.Category == "Tool" then
						self.Inventory[i] = {it.ID, CreateWeaponAttributes(), Name = GenerateWeaponName(it.ID)} 
				else
					local stack = 10
							
					self.Inventory[i] = {it.ID, GetItemSpawnData(it.ID)}
					if v.DefaultStack then
						stack = v.DefaultStack
					end				
					if it.Stack then
						self.Inventory[i].Stack = stack
					end
				end
			end
		end ]]
			local tbl = {}
			local it = GetItem(v.ID)
			if it.Category == "Buff" then 
					tbl = {it.ID, CreateRandomBuff(it.ID)}
				elseif it.Category == "Weapon" || it.Category == "Tool" then
						tbl = {it.ID, CreateWeaponAttributes(), Name = GenerateWeaponName(it.ID)} 
				else
					local stack = 10
							
					tbl = {it.ID, GetItemSpawnData(it.ID)}
					if v.DefaultStack then
						stack = v.DefaultStack
					end				
					if it.Stack then
						tbl.Stack = stack
					end
				end
				table.insert(self.Inventory, tbl)
	end
	
	PrintTable(self.Inventory)
	
	self.Viewers = {}
	
	self.Interactions = {
		[1] = {Name = "Access Shop",
		Args = function(user, ent)
			if !table.HasValue(self.Viewers, user) then	
				return false
			else
				return true
			end
		end,
		OnInteract = function(user,ent) 
			net.Start("SendShop")
				net.WriteEntity(self)
				net.WriteUInt(self.Worth, 16)
				net.WriteTable(self.Inventory)
			net.Send(user)
			
			table.insert(self.Viewers, user)
		end} 
	} 
 
 
	self:SetModel( "models/humans/group01/female_01.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD ) 
	self:DropToFloor()
 
	self:SetMaxYawSpeed(90)
 
end
				