include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("SendMachine")
function ENT:Initialize()
	self.Viewers = {}
	
	self.Interactions = {
		[1] = {Name = "Extinguish",
		Args = function(user, ent)
			return ent:IsOnFire()
		end,
		OnInteract = function(user, ent)
			ent:Extinguish()
		end},
		[2] = {Name = "Open Mining Machine",
		Args = true,
		OnInteract = function(user, ent)
			net.Start("SendMachine")
				net.WriteTable(self.Inventory)
				net.WriteEntity(self)
			net.Send(user)
			
			table.insert(ent.Viewers, user)
		end
		}
	} 
	
	self.HP = 100
	self:SetNWInt("HP", 100)
	self.Inventory = {}
	for i = 1, 6 do
		self.Inventory[i] = {}
	end
	self:SetModel("models/props_wasteland/laundry_basket001.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_BSP)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetNWInt("StrikeCompletion", 0)
	self.Oil = 0
	self.Sound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHP(self.HP - dmg:GetDamage())
end

function ENT:Toggle(b)
	if b then
	
		if table.HasValue({8003, 9}, self.Inventory[1][1]) then
			self.Oil = self.Inventory[1].Stack
		end
		
		if self.Oil > 0 then
			self.Activated = true
			self:SetNWInt("Enabled", 1)
			self:EmitSound("ambient/fire/gascan_ignite1.wav")
			self.Sound:Play()
		end
		
	else
		self.Activated = false
		self:SetNWInt("Enabled", -1)
		//self.Effect:Remove()
		
		self.Sound:Stop()
	end
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
			if self:GetNWInt("StrikeCompletion", 0) + 10 < 100 then
				self:SetNWInt("StrikeCompletion", self:GetNWInt("StrikeCompletion") + 10)
			else
				self:SetNWInt("StrikeCompletion", 0)
				
				self.Oil = self.Oil - 1
				for k,v in pairs(self.Inventory) do
					if v[1] then
						if GetItem(v[1]).Smelt then
							local item = v[1]
							local slot = self:GetOpenItemStack(GetItem(item).Smelt)
							if !slot then
								slot = self:GetOpenSlot()
								if slot then
									local tbl = GetItemSpawnData(GetItem(item).Smelt)
									tbl.Stack = 1
									self.Inventory[slot] = {GetItem(item).Smelt, tbl}
								end
							end
							
							if slot then
								self:AddItemStack(slot, 1)
								self:EmitSound("physics/metal/metal_computer_impact_bullet2.wav", 40)
								
								local vec = self:GetPos()
								local edata = EffectData()
								edata:SetOrigin( vec )
								util.Effect( "cball_bounce", edata )
								
								if v.Stack - 1 > 0 then
									v.Stack = v.Stack - 1
								else
									self:RemoveSlot(k)
								end
							else
								self:Ignite(5)//Absolutely no room for the item.
							end
							
							for k,v in pairs(self.Viewers) do
								net.Start("UpdateContainer")
									net.WriteEntity(self)
									net.WriteTable(self.Inventory)
								net.Send(v)
							end
						end	
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

util.AddNetworkString("ToggleMachine")
net.Receive("ToggleMachine",function()
	local pl = net.ReadEntity()
	local machine = net.ReadEntity()
	local bool = net.ReadBool()
	
	machine:Toggle(bool)
end)