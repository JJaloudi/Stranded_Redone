AddCSLuaFile()

ENT.Base             = "base_nextbot"
ENT.Spawnable = true


function ENT:Initialize( )
 
	self.Interactions = {
		[1] = {Name = "Speak",
		Args = true,
		OnInteract = function(user,ent) 
			StartDialogue(user, ent)
		end} 
	} 
	
	self.Viewers = {}
 
end

function ENT:RunBehaviour()

	while ( true ) do
	
		self:StartActivity( ACT_IDLE )
	
	
		coroutine.yield()
	end
end

function ENT:OnTakeDamage(dmg)
	dmg:ScaleDamage(0)
	
	return dmg
end

function ENT:SetPersona(id)
	for k,v in pairs(PERSONAS) do
		if id == v.ID then
			self.PersonaID = id
			
			if SERVER then
				self:DropToFloor()
							
				if v.Type == "Shop" then
					self.Worth = v.StartingWorth
					self.Inventory = v.PopulateInventory()
					
					print(self.Worth)
				end
			end
		end
	end
end