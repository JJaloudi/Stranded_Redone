include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Interactions = {
		[1] = {Name = "Take Money: $", Args = true,
		OnInteract = function(user,ent) 
			user:AddMoney(ent.Worth) 
			user:EmitSound("physics/cardboard/cardboard_box_break1.wav")
			ent:Remove()
		end},
		[2] = {Name = "Burn Money",Args = true, OnInteract = function(user,ent) ent:Ignite(50) timer.Simple(5, function() ent:Remove() end) end}
	}
	self.Worth = 50
	self.Interactions[1].Name = "Take Money: $"..self.Worth
	self:SetModel("models/props/cs_assault/money.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SetWorth(amt)
	self.Worth = amt
	self.Interactions[1].Name = "Take Money: $"..self.Worth
end

function ENT:Used(user)
	
end