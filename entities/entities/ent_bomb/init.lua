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
		end},
		[3] = {Name = "Allen Snackbar",
		Args = function(user, ent)
			return true
		end,
		OnInteract = function(user,ent) 
			ent:Detonate(true)
		end} 
	} 
	
	self.Activated = true
	self.Radius = 500
	self:SetModel("models/props_phx/ww2bomb.mdl")
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

function ENT:Detonate(ignoreActivate)
	if ignoreActivate || self.Activated then
				
		self.Explosion = ents.Create( "env_explosion" ) 
		local explosion = self.Explosion
		explosion:SetKeyValue( "spawnflags", 144 )
		explosion:SetKeyValue( "iMagnitude", 15 )
		explosion:SetKeyValue( "iRadiusOverride", 256 )
		explosion:SetPos(self:GetPos()) 
		explosion:Spawn()
		explosion:Fire("explode","",0)	
		
		self:EmitSound("ambient/explosions/explode_1.wav",500)
	
		self:Remove()
	end
end

function ENT:Touch()
	if self.Activated then
		self:Detonate()
	end
end

function ENT:OnTakeDamage()
	self:Detonate(true)
end
		
function ENT:Think()

end