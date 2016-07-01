AddCSLuaFile()


ENT.Base             = "base_nextbot"



function ENT:Initialize()
	self:SetModel("models/player/zombie_classic.mdl")

	self.Level = 1
	
	self.mMovement = false
end		

function ENT:SetLevel(lvl)
	
end

function ENT:SetEnemy(ent)
	self.Enemy = ent
end

function ENT:GetEnemy()
	return self.Enemy or false
end

function ENT:EnemyExists()
	local bExists = true
	local enemy = self:GetEnemy()
	
	if !enemy then return false end
	if !enemy:IsValid() then return false end
	if !enemy:Alive() then return false end
	if !self:IsLineOfSightClear(enemy) then return false end
	if enemy:GetPos():Distance(self:GetPos()) >= (self.Level * 1000) then return false end
		
	return true
end

function ENT:FindEnemy()
	local enemy = false

	for k,v in pairs(player.GetAll()) do
		if !v:Crouching() && v:GetPos():Distance(self:GetPos()) <= self.Level * 200 then
			enemy = v
			
			break
		end
	end
	
	return enemy
end

local mTypes = {
	["Running"] = ACT_HL2MP_RUN_ZOMBIE,
	["Walking"] = ACT_HL2MP_RUN_ZOMBIE,
	["Idle"] = ACT_IDLE
}
function ENT:SetMovement(type)
	if type then
		if self.mMovement != type then
			self.mMovement = type
			self:StartActivity(mTypes[type])
			
			if type == "Running" then
				self.loco:SetDesiredSpeed(250 + (self.Level * 25))
			elseif type == "Walking" then
				self.loco:SetDesiredSpeed(100)
			end
		end
	else
		self.mMovement = false
	end
end

function ENT:RunBehaviour()

	while ( true ) do
	
		if self:GetEnemy() then
			if !self:EnemyExists() then
				self:SetEnemy(false)
			end
			
			
			self.loco:FaceTowards(self:GetEnemy():GetPos())
			
			if !self.Activity then self.Activity = "Chase" end
			
			if self.Activity == "Chase" then
				self:ChaseEnemy()
			end
			
		else
			local nEnemy = self:FindEnemy()
			if nEnemy then
				self:SetEnemy(nEnemy)
			end
		end
		
		coroutine.yield()
	end
end

function ENT:InRange()
	if self:EnemyExists() then
		return self:GetPos():Distance(self:GetEnemy():GetPos()) <= 40
	end
end

function ENT:DoAttack()
	self.Activity = "Attacking"
	
	self:SetMovement(false)
	
	self:StartActivity(ACT_GMOD_GESTURE_RANGE_ZOMBIE)
	
	self.Activity = "Chase"
	//coroutine.wait(2)
end

function ENT:ChaseEnemy()
	if self:GetEnemy() && self:EnemyExists() then
		local options = options or {}

		local path = Path( "Follow" )
		path:SetMinLookAheadDistance( options.lookahead or 300 )
		path:SetGoalTolerance( options.tolerance or 20 )
		path:Compute( self, self:GetEnemy():GetPos() )	
		
		if ( !path:IsValid() ) then return "failed" end

		while (path:IsValid() && self.Activity == "Chase") do
			self:SetMovement("Walking")
			
			print("WALK")
			
			if ( path:GetAge() > 0.1 ) then	
				path:Compute( self, self:GetEnemy():GetPos() )
			end
			
			path:Update( self )	
			
			if self:InRange() then
				self:DoAttack()
			end
			
			coroutine.yield()
			
		end
	end
end
