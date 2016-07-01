LOADENTS = {
	["gm_construct"] = {
	}, 
	["rp_cscdesert_v2-1"] = {
		[2] = {Name = "ent_jeep", vec = Vector(3484, -9518, 64), ang = Angle(0, 85, 0) },
		[3] = {Name = "ent_oil_rig", vec = Vector(-1189.507080, 7656.277344, 55.074249), ang = Angle(0,90,0)},
		[4] = {Name = "ent_oil_rig", vec = Vector(4259.990723, -8024.738281, 55.031250), ang = Angle(0,90,0)},
		[5] = {Name = "ent_oil_rig", vec = Vector(-8013.540527, -9351.600586, 55.031250), ang = Angle(0,90,0)}
	},
	["rp_rashkinsk"] = {
	
	},
	["gm_valley"] = {
	
	}
}
 
PLAYER_SPAWNS = {
	["rp_cscdesert_v2-1"] = {
		Vector(3521.0126953125,-8944.328125,0.03125),
		Vector(3506.8454589844,-9129.1474609375,0.03125),
		Vector(3699.1540527344,-9152.4140625,0.03125),
		Vector(3718.3427734375,-8962.9697265625,0.03125),
		Vector(3730.5649414063,-8818.896484375,0.03125),
		Vector(1855.9031982422,-7948.865234375,8.03125),
		Vector(1687.7072753906,-8170.5561523438,8.03125),
		Vector(1686.0167236328,-8020.5815429688,8.03125)
	},
	["rp_rashkinsk"] = {
		Vector(-10361.329102, -6877.822266, 140.031250),
		Vector(-10344.597656, -7073.329102, 140.031250),
		Vector(-10407.516602, -6594.273926, 140.031250),
		Vector(-11353.542969, -6386.270508, 140.031250),
		Vector(-11323.956055, -6682.211914, 140.031250),
		Vector(-13461.101563, -9096.336914, 140.031250),
		Vector(-12663.706055, -8879.715820, 140.031250),
		Vector(-12341.200195, -9132.366211, 140.031250)
	},
	["gm_construct"] = {
		Vector(1029.491089, -1457.364624, -79.968750),
		Vector(1012.174255, -1810.290405, -79.968750)
	}, 
	["gm_valley"] = {
		Vector(1329.3553466797, -13797.513671875, -6.6362457275391),
		Vector(1166.474609375, -13784.991210938, -6.9632987976074),
		Vector(966.48468017578, -13800.182617188, -4.3270111083984),
		Vector(1580.9265136719, -14357.975585938, -1.3613395690918),
		Vector(1307.2203369141, -14369.970703125, -1.4290885925293),
		Vector(1095.3312988281, -14376.365234375, -1.9658432006836)
	}
}

concommand.Add("pos",function(pl)
	local x, y, z = pl:GetPos().x, pl:GetPos().y, pl:GetPos().z
	
	pl:SendLua("print ( 'Vector(".. x ..", "..y..", "..z..")')")
end)

hook.Add("InitPostEntity","Spawn Load Ents",function()
	if LOADENTS[string.lower(game.GetMap())] then
		for k,v in pairs(LOADENTS[string.lower(game.GetMap())]) do
			local ent = ents.Create(v.Name)
			ent:SetPos(v.vec); ent:SetAngles(v.ang) 
			ent:Spawn()
			ent:DropToFloor()
		end
	end
		
	for k,v in pairs(ents.FindByClass("info_player_start")) do
		v:Remove()
	end
		
	for k,v in pairs(PLAYER_SPAWNS[string.lower(game.GetMap())]) do
		local spawn = ents.Create("info_player_start")
		spawn:SetPos(v)
		spawn:Spawn()
	end

end) 

hook.Add("Think", "Detect Safe",function()
	for key, pl in pairs(player.GetAll()) do 
		if !pl.Location then
			for k,v in pairs(TERRITORIES[string.lower(game.GetMap())]) do
				if table.HasValue(ents.FindInBox(v.StartPos, v.EndPos), pl) then
					if !pl.Location then
						pl:UpdateLocation(k)				
						if v.SafeZone then
							pl:Notify("You've entered the safety of "..k.."!")
							pl.IsSafe = true
						else
							pl:Notify("You've entered the territory of "..pl.Location..".")
						end
						
						
					end
				end
			end
		else
			local ref = TERRITORIES[string.lower(game.GetMap())][pl.Location]
			if !table.HasValue(ents.FindInBox(ref.StartPos, ref.EndPos), pl) then
				if ref.SafeZone then
					pl:Notify("You've left the safety of "..pl.Location.."!")
					pl.IsSafe = nil
				else
					pl:Notify("You're leaving the territory of "..pl.Location..".")
				end
				pl:UpdateLocation(nil)
			end
		end
	end
end)

GENERATION_LOCATIONS = {
	["rp_cscdesert_v2-1"] = {
		[1] = {
			Location = Vector(7924.460449, -8706.008789, 64.031250),
			Radius = 2000,
			Ore = {9001, 9002, 9003}
		},
		[2] = {
			Location = Vector(3378.020996, -652.256287, 64.031250),
			Radius = 2000,
			Ore = {9001, 9003}
		}
	},
	["gm_construct"] = {
		[1] = {
			Location = Vector(-439.535706, 417.785431, -84.704697),
			Radius = 1000,
			Ore = {9001, 9002, 9003}
		}
	},
	["gm_valley"] = {
		[1] = {
			Location = Vector(2136.3041992188, 3718.1052246094, -3185.3918457031),
			Radius = 3000,
			Ore = {9001, 9002, 9003}
		},
		[2] = {
			Location = Vector(-8977.908203125, 4228.7646484375, -2523.4194335938),
			Radius = 3000,
			Ore = {9001, 9002, 9003}
		}
	}
}

function GenerateSystem(num)
	if GENERATION_LOCATIONS[string.lower(game.GetMap())] then
		for k,v in pairs(GENERATION_LOCATIONS[string.lower(game.GetMap())]) do
			print("Generating location "..k)
		
			local xMin, xMax = v.Location.x - v.Radius, v.Location.x + v.Radius
			local yMin, yMax = v.Location.y - v.Radius, v.Location.x + v.Radius
			local zMin, zMax = v.Location.z - v.Radius, v.Location.z + v.Radius
			
			local queries = num || math.random(5, v.Radius / 200)
			
			print("Generating "..queries.." instances.")
			
			local trStartPos = Vector(xMax, yMax, zMax)
			local skyTr = util.TraceLine({
				start = trStartPos,
				endpos = trStartPos + Vector(0,0,500)
			})
			local skyLoc = skyTr.HitPos
			
			for i = 1, queries do
				local randLocation = Vector(math.random(xMin, xMax), math.random(yMin, yMax), skyLoc)
				local zVecFinder = {
					start = randLocation,
					endpos = randLocation - Vector(0,0, 5000)
				}
				local tr = util.TraceLine(zVecFinder)
				local zLocation = tr.HitPos.z
				print(zLocation)
				local fixedLocation = Vector(randLocation.x, randLocation.y, zLocation + 5)
				
				
				local ent = ents.Create("ent_ore")
				ent:SetPos(fixedLocation)
				ent:SetAngles(Angle(0,math.random(0,180), 0))
				ent:Spawn()
				ent:DropToFloor()
				ent:SetOre(table.Random(v.Ore))
			end
		end	
	end
end

hook.Add("InitPostEntity", "Generation System", function()
	GenerateSystem()
end)

timer.Create("TerritoryPayment", 240, 0, function()
	for k,v in pairs(TERRITORIES[string.lower(game.GetMap())]) do
		if !v.SafeZone && v.Controller then
			for key, pl in pairs(GetOnlineFactionPlayers(v.Controller)) do
				local pay = math.Round(v.Pay - (v.Pay * tonumber("." .. Factions[pl.FacID].Data.Ranks[pl.FacRank].Tax)))
				pl:AddMoney(pay)
				pl:Notify("[Faction] Received $".. pay .." for having control over "..k..".")
			end
		end
	end
end)

hook.Add("PlayerSelectSpawn", "Set Spawn Locations",function(pl)
	return ents.FindByClass("info_player_start")[math.random(#ents.FindByClass("info_player_start"))]
end)