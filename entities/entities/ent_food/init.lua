include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Interactions = {
		[1] = {Name = "Take Food", 
		OnInteract = function(user,ent) 
			user:EmitSound("physics/cardboard/cardboard_box_break1.wav")
			ent:Remove()
		end},
		[2] = {Name = "Eat Food", OnInteract = function(user,ent) user:SetHealth(user:Health() + 5) ent:Remove() end}
	}
	self:SetModel("models/props_junk/garbage_takeoutcarton001a.mdl")
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

function ENT:Used(user)
	
end