local density=CreateClientConVar("cs_raindensity","1",false,false)

function EFFECT:Init(data)
	self.Particles=data:GetMagnitude()*density:GetInt()
	self.DieTime=CurTime()+1
	self.Emitter=ParticleEmitter(LocalPlayer():GetPos())
end

local function ParticleCollides(particle, pos, norm)
	particle:SetDieTime(0)
	local effectdata = EffectData() 
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos) 
	effectdata:SetScale(2)
	util.Effect( "watersplash", effectdata )  
end

function EFFECT:Think()
	if CurTime()>self.DieTime then return false end
	local emitter = self.Emitter
	for i=1, 1 do
		local spawnpos = LocalPlayer():GetPos()+Vector(math.random(-1200,1200),math.random(-500,500),1000)
		
		local particle = emitter:Add("effects/bluespark", spawnpos)
		if (particle) then
			particle:SetVelocity(Vector(math.sin(CurTime()/4)*10,50,-700))
			particle:SetLifeTime(0)
			particle:SetDieTime(3)
			particle:SetEndAlpha(255)
			particle:SetStartSize(0)
			particle:SetEndSize(5)
			particle:SetAirResistance(0)
			particle:SetStartAlpha(0)
			particle:SetCollide(true)
			particle:SetBounce(0)
			particle:SetCollideCallback(ParticleCollides)
		end
	end
	return true
end
