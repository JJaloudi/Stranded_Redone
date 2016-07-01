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
			ent.Activated = true
			ent:EmitSound("ambient/machines/thumper_startup1.wav")
			ent.Sound = CreateSound(ent, "ambient/machines/thumper_amb.wav")
			timer.Simple(1, function()
				ent.Sound:Play()
			end)
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
			ent:EmitSound("ambient/machines/thumper_shutdown1.wav")
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
	for i = 1, 3 do
		self.Inventory[i] = {}
	end
	self:SetModel("models/props_combine/CombineThumper001a.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_BSP)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetNWInt("StrikeCompletion", 0)	
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
	
--[[ 	if amt <= 0 then
		self:Remove()
	end ]]
end
		
function ENT:Think()
	if self.Activated then
		if self:GetNWInt("StrikeCompletion", 0) + 2 < 100 then
			self:SetNWInt("StrikeCompletion", self:GetNWInt("StrikeCompletion") + 2)
		else
			self:EmitSound("ambient/machines/thumper_hit.wav")
			self:SetNWInt("StrikeCompletion", 0)
			
			util.ScreenShake( self:GetPos(), 3, 3, 1, 400 )
			
			local item = table.Random({9003})
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
				self:AddItemStack(slot, math.random(5,30))
			else
				//Absolutely no room for the item.
			end
		end
	else
		if self.Sound then
			self.Sound:Stop()
			self.Sound = nil
		end
	end
end