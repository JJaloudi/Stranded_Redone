include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Interactions = {
		[1] = {Name = "Pickup ...",
		Args = function(user, ent)
			return true
		end,
		OnInteract = function(user,ent) 
			if user:GetOpenSlot() then
				user:SetInventoryItem(user:GetOpenSlot(), self.Data)
				self:Remove()
			else
				user:Notify("You don't have enough inventory space to pick this up!")
			end
		end} 
	} 
	self:SetModel("models/items/item_item_crate.mdl")
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

function ENT:SetItem(item)
	if ItemIsValid(item) then
		self.Item = item
		self:SetModel(GetItem(item).Model)
		self.Data = CreateItem(item)
		local name = GetItem(item).Name
		if self.Data.Name then
			name = self.Data.Name
		end
		
		self.Interactions[1].Name = "Take "..name
		self:SetUseType(SIMPLE_USE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		local phys = self:GetPhysicsObject()
		
		if phys and phys:IsValid() then
			phys:Wake()
		end
		
	else
		self:Remove()
	end
end
		
function ENT:Think()

end

function ENT:Used(user)
	
end