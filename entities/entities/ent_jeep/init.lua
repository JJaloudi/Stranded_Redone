include("shared.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self.Vehicle = ents.Create("prop_vehicle_jeep")
	self.Vehicle:SetModel("models/buggy.mdl")
	self.Vehicle:SetPos(self:GetPos())
	self.Vehicle:SetKeyValue("vehiclescript","scripts/vehicles/jeep_test.txt")
	self.Vehicle:Spawn()
	self.Vehicle.HP = 100
	self.Vehicle.Own = self
	
	self.TurretSeat = ents.Create("prop_vehicle_prisoner_pod")
	self.TurretSeat:SetModel("models/nova/jeep_seat.mdl")
	self.TurretSeat:SetPos(self.Vehicle:GetPos() + Vector( 0, -40, 70) )
	self.TurretSeat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	self.TurretSeat:Spawn()
	self.TurretSeat:SetParent(self.Vehicle)
	self.TurretSeat.Shooter = self
	self.TurretSeat.Heat = 0
	
	self.Seat = ents.Create("prop_vehicle_prisoner_pod")
	self.Seat:SetModel("models/nova/jeep_seat.mdl")
	self.Seat:SetPos(self.Vehicle:GetPos() + Vector( 15, -36.5, 20) )
	self.Seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	self.Seat:Spawn()
	self.Seat:SetParent(self.Vehicle)
	
	self.Interactions = {
		[1] = {Name = "Reload Turret", 
		OnInteract = function(user,ent) 
			ent:EmitSound("weapons/ar2/ar2_reload.wav")
		end}
	}
	
	self:SetModel("models/weapons/w_mach_m249para.mdl")
	self:SetPos(self.TurretSeat:GetPos() + Vector(0,30,17.5))
	self:SetAngles(Angle(45,90,0))
	self:SetParent(self.TurretSeat)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end 

function ENT:ShootBullet()
	bullet = {}
	bullet.Num=4
	bullet.Src=self:GetPos()
	bullet.Dir=self:GetAngles():Forward()
	bullet.Spread=Vector(0.01,0.01,0)
	bullet.Tracer=1	
	bullet.Force=2
	bullet.Damage=50
	
--[[ 	local att = self:LookupAttachment("muzzle")
	
	local pos = self:GetAttachment(att).Pos ]]
	self:FireBullets(bullet)
	self:EmitSound("weapons/ar2/fire1.wav")
--[[ 	local effectdata = EffectData() 
	effectdata:SetStart(pos)
	effectdata:SetOrigin(pos) 
	effectdata:SetScale(1)
	util.Effect( "MuzzleEffect", effectdata )	 ]]
end

hook.Add("CanPlayerEnterVehicle","NoEnter",function(_,veh)
	return !veh.Destroyed
end)

hook.Add("EntityTakeDamage","Vehicle Health",function(veh,dmg)
	if veh:GetClass() == "prop_vehicle_jeep" then
		if veh.HP then
			if !veh.Destroyed then
				if veh.HP - dmg:GetDamage() > 0 then
					veh.HP = veh.HP - dmg:GetDamage() * 750
				else
					veh.Destroyed = true
					if IsValid(veh:GetDriver()) then
						if IsValid(veh.Own.TurretSeat:GetDriver()) then
							veh.Own.TurretSeat:GetDriver():Ignite(50)
						end
						veh:GetDriver():TakeDamage(veh:GetDriver():Health(),dmg:GetAttacker())
					end
					
					veh.Own:Remove()
					veh.Own.TurretSeat:Remove()
					veh:GetPhysicsObject():SetVelocity(Vector(0,0,600))
					veh:SetColor(Color(0,0,0,255))
					
					local effectdata = EffectData()
					effectdata:SetStart(veh:GetPos())
					effectdata:SetOrigin(veh:GetPos()) 
					effectdata:SetScale(1)
					util.Effect( "HelicopterMegaBomb", effectdata )	
					
					veh:EmitSound("ambient/explosions/explode_1.wav",500)
					veh:Ignite(10)
					
					timer.Simple(6,function()
						veh:Remove()
					end)
				end
			end
		else
			veh.HP = 100 - dmg:GetDamage()
		end
		print(veh.HP)
	end
end)
-- size of bar * value / max value
hook.Add("Think","Do Vehicle Shoot", function()
	for _,pl in pairs(player.GetAll()) do
		if IsValid(pl:GetVehicle()) then
			if pl:GetVehicle().Shooter then
				pl:GetVehicle().Shooter:SetAngles(pl:EyeAngles())
				if pl:GetVehicle().Heat > 0 then
					pl:GetVehicle().Shooter:SetColor(Color(255 * pl:GetVehicle().Heat / 100, 0, 0, 255))    
				end
				if pl:KeyDown(IN_ATTACK) then
					if pl:GetVehicle().LastShot then
						if pl:GetVehicle().LastShot < CurTime() then
							if pl:GetVehicle().Heat < 100 then
								pl:GetVehicle().Shooter:ShootBullet()	
								pl:GetVehicle().Heat = pl:GetVehicle().Heat + 1
								pl:GetVehicle().LastShot = CurTime() + 0.2
								pl:GetVehicle().LastHeat = CurTime() + 0.2
							end
						end
					else
						pl:GetVehicle().Shooter:ShootBullet()	
						pl:GetVehicle().LastShot = CurTime() + 0.2
					end
				else
					if pl:GetVehicle().LastHeat then
						if pl:GetVehicle().LastHeat < CurTime() then
							pl:GetVehicle().Heat = pl:GetVehicle().Heat - 1
							pl:GetVehicle().LastHeat = CurTime() + .1 
						end
					else
						pl:GetVehicle().Shooter:SetColor(Color(255,255,255,255))
					end
				end
			end
		end
	end
end)