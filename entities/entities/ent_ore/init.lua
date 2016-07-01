include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	
	local OreModels = {
		"models/props_canal/rock_riverbed02b.mdl",
		--"models/props/cs_militia/militiarock05.mdl",
		"models/props_wasteland/rockgranite03b.mdl",
		"models/props_wasteland/rockgranite02a.mdl"
	}
	
	self:SetModel(table.Random(OreModels))
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	
	
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end

function ENT:SetOre(oreType)
	local colors = {
		[9001] = Color(83, 59, 83, 255),
		[9002] = Color(201, 174, 93, 255),
		[9003] = Color(10,10,10,255)
	}

	if colors[oreType] then
		self:SetColor(colors[oreType])
		self.Ore = oreType
		
		self.HP = 100
	end
end

function ENT:OnMined(dmg)
	local edata = EffectData()
	edata:SetOrigin( self:GetPos() )
	util.Effect( "cball_bounce", edata )

	if self.HP - dmg > 0 then
		self.HP = self.HP - dmg
	else
		self:Remove()
	end
end

function ENT:Think()

end