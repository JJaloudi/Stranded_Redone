include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
	self.Inventory = {}
	for i = 1, math.random(1,35) do
		self.Inventory[i] = {false}
		local rNum = math.random(0, #ITEMS)
		if rNum != 0 then
			local it = GetItem(rNum)
			if it then
				if it.Category == "Buff" then
					self.Inventory[i] = {it.ID, CreateRandomBuff(it.ID)}
				else
					if it.Category == "Weapon" || it.Category == "Tool" then
						self.Inventory[i] = {it.ID, CreateWeaponAttributes(), Name = GenerateWeaponName(it.ID)} 
					else
						self.Inventory[i] = {it.ID, GetItemSpawnData(it.ID)}
						if it.Stack then
							self.Inventory[i].Stack = 1000
						end
					end
				end
			end
		end
	end

	self.Viewers = {}
	self.Interactions = {
		[1] = {Name = "Check Container",
		Args = true,
		OnInteract = function(user,ent) 
			net.Start("SendBag")
				net.WriteTable(self.Inventory)
				net.WriteEntity(self)
			net.Send(user)
			
			table.insert(ent.Viewers, user)
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

function ENT:Think()
	if self.Viewer then
		if self.Viewer:IsPlayer() then
			if !self.Viewer:Alive() then
				self.Viewer = false
			else
				if self.Viewer:GetPos():Distance(self:GetPos()) >= 150 then
					self.Viewer = false
				end
			end
		else
			self.Viewer = false
		end
	end
end

function ENT:Used(user)
	
end