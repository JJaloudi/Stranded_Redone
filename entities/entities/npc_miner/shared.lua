AddCSLuaFile()


ENT.Base             = "base_nextbot"

function ENT:Initialize()
	
	self.Interactions = {
		[1] = {Name = "Speak",
		Args = true,
		OnInteract = function(user,ent) 
			StartDialogue(user, ent)
		end} 
	} 
	
	
	self.LastMine = CurTime()
	self.StopForDialogue = false
	
	if SERVER then
		self.Inventory = {}
	
		for i = 1, DEFAULT_SLOTS do
			self.Inventory[i] = {false}
		end
		
		self.Worth = 0
		
		self.Viewers = {}
	end
	
	
end		

function ENT:FindOre(radius)
	local options = {}

	for k,v in pairs(ents.FindByClass("ent_ore")) do
		options[#options + 1] = {ent = k, distance = v:GetPos():Distance(self:GetPos())}
	end
	
	table.sort(options, function(a,b) return a.distance < b.distance end)
	
	
	if #options > 0 then
		return ents.FindByClass("ent_ore")[options[1].ent]
	else
		return false
	end
end

function ENT:SetTarget(tgt)
	self.Target = tgt
end

function ENT:GetTarget()
	return self.Target or false
end

function ENT:TargetIsValid()
	if !self:GetTarget() then return false end
	
	if self:GetTarget():IsValid() then
		return true
	else
		return false
	end
end

function ENT:CanMine() 
	return self.LastMine <= CurTime()
end

function ENT:RunBehaviour()

	while ( true ) do
		self.StopForDialogue = false
	
		for k,v in pairs(player.GetAll()) do 
			if v:GetPos():Distance(self:GetPos()) <= 50 then
				self.StopForDialogue = v
				
				break
			end
		end
			
		if !self.StopForDialogue then
			if self:TargetIsValid() then
				self.loco:FaceTowards(self:GetTarget():GetPos())
			
				if self:GetPos():Distance(self:GetTarget():GetPos()) >= 100 then
					if !self.Moving then
						self:StartActivity( ACT_WALK )					
						self.loco:SetDesiredSpeed( 100 )	
						
						self.Moving = true
					end
				
					local move = self:MoveToPos(self:GetTarget():GetPos(), {
						lookahead = 300,
						tolerance = 20,  
						maxage = 0.1
					})  
					
				else
					if self:CanMine() then
						self:Mine()
					end
				end
			else
			
				local target = self:FindOre()
				if !target then
					self:Rest()
				else
					self:SetTarget(target)
				end
			end
		else
			self:StartActivity(ACT_IDLE)
			//self.loco:FaceTowards(self.StopForDialogue:GetPos())
			
			self.Moving = false
			
			self:Aim(self.StopForDialogue:GetPos())
		end
		
		coroutine.yield()
	end
end

function ENT:GetYawPitch(vec)
	--This gets the offset from 0,2,0 on the entity to the vec specified as a vector
	local yawAng=vec-self:EyePos()
	--Then converts it to a vector on the entity and makes it an angle ("local angle")
	local yawAng=self:WorldToLocal(self:GetPos()+yawAng):Angle()
	
	--Same thing as above but this gets the pitch angle. Since the turret's pitch axis and the turret's yaw axis are seperate I need to do this seperately.
	local pAng=vec-self:LocalToWorld((yawAng:Forward()*8)+Vector(0,0,50))
	local pAng=self:WorldToLocal(self:GetPos()+pAng):Angle()

	--Y=Yaw. This is a number between 0-360.	
	local y=yawAng.y
	--P=Pitch. This is a number between 0-360.
	local p=pAng.p
	
	--Numbers from 0 to 360 don't work with the pose parameters, so I need to make it a number from -180 to 180
	if y>=180 then y=y-360 end
	if p>=180 then p=p-360 end
	if y<-60 || y>60 then return false end
	if p<-80 || p>50 then return false end
	--Returns yaw and pitch as numbers between -180 and 180	
	return y,p
end

--This grabs yaw and pitch from ENT:GetYawPitch. 
--This function sets the facing direction of the turret also.
function ENT:Aim(vec)
	local y,p=self:GetYawPitch(vec)
	if y==false then
		return false
	end
	self:SetPoseParameter("aim_yaw",y)
	self:SetPoseParameter("aim_pitch",p)
	return true
end

function ENT:Rest()
	if !self.Moving then
		self:StartActivity(ACT_BUSY_SIT_GROUND)
	end
end

function ENT:Mine()
	self:StartActivity(ACT_MELEE_ATTACK_SWING)
	self.LastMine = CurTime() + 1.5
	
	self.Moving = false
	
	self._oldTarget = self:GetTarget()
	
	timer.Simple(0.5,function()
		if self:GetTarget() == self._oldTarget then
			self:GetTarget():OnMined(10)
		end
	end)
end
