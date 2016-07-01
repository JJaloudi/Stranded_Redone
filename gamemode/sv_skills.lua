hook.Add("PlayerSpawn","SetSkills",function(pl)
	if pl.CharID then
		timer.Simple(1,function()

			pl:SetHealth(100 + (pl:GetSkill(1) * GetSkill(1).Value))//Add extra endurance health.
			
			pl:SetRunSpeed(500 + (pl:GetSkill(2) * GetSkill(2).Value))//Add extra speed.
			
			pl:SetHunger(100 + (pl:GetSkill(8) * GetSkill(8).Value))//Add extra hunger.
			
			pl:SetStamina(100 + (pl:GetSkill(9) * GetSkill(9).Value))//Add extra stamina.
		end)
	end
end)

hook.Add("Think","HandlePlayerStats",function()
	for k,v in pairs(player.GetAll()) do
		if v.CharID then
			if v:KeyDown(IN_SPEED) && v:GetVelocity():Length() > 100 && v:IsOnGround() then
				if v:GetStamina() - 1 >= 0 then
					if v.LastTake then
						if v.LastTake < CurTime() then
							v.LastTake = CurTime() + 0.25
							v:AddStamina(-1)
							v:AddHunger(-0.1)
						end
					else
						v:AddHunger(-0.1)
						v:AddStamina(-1)
						v.LastTake = CurTime() + 0.25
					end
				else
					v.LastTake = CurTime() + 0.25
					v.Impaired = true
				end
			else
				if v.LastHP then
					if v.LastHP < CurTime() then
						if v:GetHunger() then
							if v:Health() + 1 <= 100 && v:GetHunger() >= 85 then
								v:SetHealth(v:Health() + 1)
								v.LastHP = CurTime() + 1
							end
						end
					end
				else
					v.LastHP = CurTime() + 1
				end
				if v:GetStamina() + 1 <= 100 then
					if v.LastTake then
						if v.LastTake < CurTime() then
							v.LastTake = CurTime() + 0.25
							v:AddStamina(1)
						end
					else
						v.LastTake = CurTime() + 0.25
						v:AddStamina(1)
					end
				end
			end
			if v.Impaired then
				if v:GetStamina() > 0 then
					v.Impaired = false
					v:SetRunSpeed(450)
					v:Notify("You are no longer exhausted.")
					v.sNotify = false
				else
					if !v.sNotify then
						v:Notify("You're exhausted! Take a breather.")
						v.sNotify = true
					end
					v:AddHunger(-0.01)
					v:SetRunSpeed(300)
				end
			end
			if v:GetHunger() - 1 <= 0 then 
				v:SetHealth(v:Health() - 0.0001)
				if !v.hNotify then
					v:Notify("You're dying of hunger!")
					v.hNotify = true
				end
			end
			if v:Health() <= 0 && v:Alive() then
				v:Kill()
				v.hNotify = false
				v:Notify("You died of starvation!")
			end
			if v.LastHunger then
				if v.LastHunger < CurTime() then
					v:AddHunger(-0.3)
					v.LastHunger = CurTime() + 3
				end
			else
				v.LastHunger = CurTime() + 3
			end
		end
	end
end)