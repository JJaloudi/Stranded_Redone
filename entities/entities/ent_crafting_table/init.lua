include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Upgrades = {
		[1] = "models/props_wasteland/controlroom_desk001b.mdl",
		[2] = "models/props_wasteland/kitchen_counter001c.mdl",
		[3] = "models/props_wasteland/kitchen_counter001d.mdl"
	}
	
	self.Interactions = {
		[1] = {Name = "Use Crafting Table",
			Args = function(user, ent)
				return true
			end,
			OnInteract = function(user,ent) 
				net.Start("CraftingSystem")
				net.WriteUInt(self.Level,8)
				net.WriteEntity(self)
				net.Send(user)
		end},
		[2] = {Name = "Upgrade Table",
			Args = function(user, ent)
				return ent.Level + 1 <= #ent.Upgrades
			end,
			OnInteract = function(user,ent)
				if self.Level + 1 <= 3 then
					self:Upgrade()
				end
		end}
	} 
	self.Level = 1
	self:SetModel(self.Upgrades[self.Level])
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	self.Sounds = {"physics/metal/metal_barrel_impact_soft1.wav","physics/metal/metal_barrel_impact_soft2.wav","physics/metal/metal_barrel_impact_soft3.wav","physics/metal/metal_barrel_impact_soft4.wav"}
	
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Queue(id,pl)
	if GetItem(id) then
		self.Crafter = pl
		self.MaxProgress = 15
		self.Progress = 0
		self:SetNWInt("mProgress",self.MaxProgress)
		self:SetNWInt("Item",id)
		timer.Create("Craft", 1,0, function()
			if self.IsCrafting then
				if self.Progress + 1 <= self.MaxProgress then
					self.Progress = self.Progress + 1
					self:SetNWInt("Progress",self.Progress)
					local snd = table.Random(self.Sounds)
					self:EmitSound(snd)
					
				else
					self:SetNWInt("Item",false)
					self:EmitSound("plats/elevbell1.wav")
					local ent = ents.Create("ent_item")
					ent:SetPos(self:GetPos() + Vector(0,0,50))
					ent:Spawn()
					ent:SetItem(id)
					ent:Activate()
					self.Crafter = nil
					self.MaxProgress = nil
					self.Progress = nil
					timer.Destroy("Craft")
				end
			end
		end)
	end
end

function ENT:Touch(ent)
	if self.LastTouch then
		if self.LastTouch <= CurTime() then
			if ent:GetClass() == "ent_item" then
			end
		end
	else
		self.LastTouch = CurTime()
	end
end

function ENT:Upgrade()
	self.Level = self.Level + 1
	self:SetModel(self.Upgrades[self.Level])
	self:EmitSound("physics/metal/metal_barrel_impact_soft4.wav")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:Think()
	if self.Crafter then
		if self.Crafter:GetPos():Distance(self:GetPos()) <= 200 then
			self.IsCrafting = true
		else
			self.IsCrafting = false
		end
	end
end

function ENT:Used(user)
	
end