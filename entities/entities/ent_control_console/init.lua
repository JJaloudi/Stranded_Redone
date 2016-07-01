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
			local distNot = true
			for k,v in pairs(TERRITORIES[string.lower(game.GetMap())]) do
				if v.Pos:Distance(ent:GetPos()) <= v.Radius then
					distNot = false
					if !v.SafeZone then
						if !v.Controller then
							if user.FacID then
								ent.Activated = true
								ent.Territory = k
								ent.Faction = user.FacID
								self:SetNWInt("Territory", k)
								self:SetNWString("Controller", Factions[user.FacID].Name)
								
								self:EmitSound("buttons/combine_button1.wav")
								
								TERRITORIES[string.lower(game.GetMap())][k].Controller = user.FacID
								
								for key, pl in pairs(player.GetAll()) do
									
									if pl.FacID != user.FacID then
										pl:Notify(k .. "was captured by ".. Factions[user.FacID].Name .. "!")
									else
										user:Notify("You successfully claimed " .. k .. ", you've received a $PLACEHOLDER reward!")
									end
									if pl.Location == k then
										pl:UpdateLocation(k)
									end
								end
							else
								user:Notify("You need to be in a faction to claim a territory!")
							end
						else
							user:Notify("This territory is already under " .. Factions[v.Controller].Name .. "'s control!")
						end
					else
						user:Notify("You can't claim a safe zone!")
					end
				end
			end
			
			if distNot then
				user:Notify("You're not within the bounds of any territory.")
			end
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
			
			ent:RemoveControl()
		end},
		[3] = {Name = "Extinguish",
		Args = function(user, ent)
			return ent:IsOnFire()
		end,
		OnInteract = function(user, ent)
			ent:Extinguish()
		end}
	} 
	
	self.HP = 100
	self:SetNWInt("HP", 100)
	self:SetModel("models/props_lab/reciever_cart.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_BSP)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
	end
end


function ENT:RemoveControl()
	if self.Territory then
		TERRITORIES[string.lower(game.GetMap())][self.Territory].Controller = false
		for key, pl in pairs(player.GetAll()) do
			if pl.Location == self.Territory then
				pl:UpdateLocation(self.Territory)
				self:SetNWInt("Territory", -1)
				self:EmitSound("buttons/combine_button2.wav")
				
				
				pl:Notify(self.Territory .. " is now a neutral territory.")
			end
		end 
	end
end

function ENT:OnTakeDamage(dmg)
	self:SetHP(self.HP - dmg:GetDamage())
end

function ENT:SetHP(amt)
	self.HP = amt
	self:SetNWInt("HP", self.HP)
	
	if amt <= 10 then
		self:Ignite(10)
	end
	
	if amt <= 0 then
		self:RemoveControl()
		self:Remove()
	end
end
		
function ENT:Think()

end