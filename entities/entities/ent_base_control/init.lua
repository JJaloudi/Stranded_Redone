include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

ENT.Base = "base_ai"


ENT.Collide = true
 
ENT.Interactions = {
	[1] = { Name = "Test Interaction",Args = true, OnInteract = function(int) hook.Call("Vehicle Health", 100, int) end }
}	

function ENT:Use(user)
	net.Start("PlayerInteract")
		net.WriteEntity(self)
		local tbl = {}
		for k,v in pairs(self.Interactions) do
			if v.Args == true then
				tbl[k] = v.Name
			else
				if v.Args(user, self) then
					tbl[k] = v.Name
				end
			end
		end
		net.WriteTable(tbl)
	net.Send(user)
	
	
	self:Used(user)
end


function ENT:Used()

end

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	if self.Collide then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		local phys = self:GetPhysicsObject()

		if phys and phys:IsValid() then
			phys:Wake()
		end
	end
end