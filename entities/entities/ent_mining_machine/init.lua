include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Interactions = {
		[1] = {Name = "Activate",
		Args = function(user, ent)
			if !ent.Activated then
				return true
			else
				return false
			end
		end,
		OnInteract = function(user,ent) 
			if ent.Inventory[1][1] then
				if ent.Inventory[1][1] == 8003 then
					ent:SetNWInt("Enabled", 1)
					self.Oil = ent.Inventory[1].Stack
			
					ent.Activated = true
				else
					ent:EmitSound("vehicles/Jetski/jetski_no_gas_start.wav")
				end
			else
				ent:EmitSound("vehicles/Jetski/jetski_no_gas_start.wav")
			end
		end},
		[2] = {Name = "Deactivate",
		Args = function(user, ent)
			if ent.Activated then
				return true
			else
				return false
			end
		end,
		OnInteract = function(user,ent) 
			ent.Activated = false
			
			self:SetNWInt("Enabled", -1)
		end},
		[3] = {Name = "Extinguish",
		Args = function(user, ent)
			return ent:IsOnFire()
		end,
		OnInteract = function(user, ent)
			ent:Extinguish()
		end},
		[4] = {Name = "Check Container",
		Args = function(user, ent)
			if !ent.Activated then
				return true
			else
				return false
			end
		end,
		OnInteract = function(user, ent)
			net.Start("SendBag")
				net.WriteTable(self.Inventory)
				net.WriteEntity(self)
			net.Send(user)
		end
		
		}
	} 
	
	self.HP = 100
	self:SetNWInt("HP", 100)
	self.Inventory = {}
	for i = 1, 5 do
		self.Inventory[i] = {}
	end
	self:SetModel("models/props_wasteland/laundry_washer001a.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_BSP)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetNWInt("StrikeCompletion", 0)
	self.Oil = 0
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHP(self.HP - dmg:GetDamage())
end

function ENT:SetHP(amt)
	self.HP = amt
	self:SetNWInt("HP", self.HP)
	
	if amt <= 10 then
		self:Ignite(10)
	end
	
	if amt <= 0 then
		self:Remove()
	end
end
		
function ENT:Think()
	if self.Activated then
		if self.Oil > 0 then
			if self:GetNWInt("StrikeCompletion", 0) + 2 < 100 then
				self:SetNWInt("StrikeCompletion", self:GetNWInt("StrikeCompletion") + 2)
			else
				self:EmitSound("physics/metal/metal_barrel_impact_hard1.wav")
				self:SetNWInt("StrikeCompletion", 0)
				
				util.ScreenShake( self:GetPos(), 3, 3, 1, 400 )
				
				self.Oil = self.Oil - 1
				local chance = math.random(1,10)
				if chance != 10 then
					local item = table.Random({9001, 9002})
					local slot = self:GetOpenItemStack(item)
					if !slot then
						slot = self:GetOpenSlot()
						if slot then
							local tbl = GetItemSpawnData(item)
							tbl.Stack = 1
							self.Inventory[slot] = {item, tbl}
						end
					end
					
					if slot then
						self:AddItemStack(slot, math.random(5,40))
					else
						//Absolutely no room for the item.
					end
				end
				
				if self.Inventory[1].Stack - 1 > 0 then
					self.Inventory[1].Stack = self.Inventory[1].Stack - 1
				else
					self.Activated = false
					self:SetNWInt("Enabled", -1)
					self.Inventory[1].Stack = self.Inventory[1].Stack - 1
					
					self:RemoveSlot(1)
					
					self:EmitSound("vehicles/Jetski/jetski_no_gas_start.wav")
				end
			end
		else
			self:EmitSound("vehicles/Jetski/jetski_no_gas_start.wav")
		end
	end
end