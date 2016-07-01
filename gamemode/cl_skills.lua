concommand.Add("Skillsmenu",function()
	local menu = vgui.Create("cFrame")
	menu:SetSize(600,200)
	menu:SetPos(-ScrW(),ScrH()/2 - menu:GetTall()/2)
	menu:MoveTo(ScrW()/2 - menu:GetWide()/2, ScrH()/2 - menu:GetTall()/2,1)
	menu:CloseButton(true)
	menu.close.DoClick = function()
		menu:MoveTo(ScrW()*2,  ScrH()/2 - menu:GetTall()/2, 1, 0, -1, function()
			menu:Close()
		end)
	end
	local activeBt = 0

	local li = vgui.Create("DIconLayout",menu)
	li:SetSize(menu:GetWide() - 37.5, 50)
	li:SetPos(7.5, 5)
	li:SetSpaceY(1)
	
	li.Paint = function()
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(0,0,li:GetWide() - 5,li:GetTall())
	end
	
	local disp = vgui.Create("DFrame",menu)
	disp:SetPos(5,60)
	disp:SetSize(menu:GetWide() - 10, menu:GetTall() - 70)
	disp.Alpha = 0
	disp.OnAnimationFinish = function() end
	local r,g,b = GAME_MAIN.r,GAME_MAIN.g, GAME_MAIN.b
	disp:SetTitle("")
	disp.Skill = 1
	disp.Active = true
	local canClick = true
	disp:ShowCloseButton(false)
	disp.Paint = function()
		if disp.Active then
			disp.Alpha = math.Approach(disp.Alpha, 255,FrameTime() * 900)
			canClick = true
		else
			if disp.Alpha != 0 then
				disp.Alpha = math.Approach(disp.Alpha, 0,FrameTime() * 900)
				canClick = false
			else
				disp.OnAnimationFinish()
			end
		end
		draw.RoundedBoxEx(1,0,0,disp:GetWide(), disp:GetTall(), Color(r,g,b,disp.Alpha))
		draw.SimpleText(GetSkill(disp.Skill).Name,"No",47.5,5,Color(GAME_SECOND.r, GAME_SECOND.g, GAME_SECOND.b,disp.Alpha))
		draw.SimpleText(GetSkill(disp.Skill).Desc,"Default",10,42.5,Color(GAME_SECOND.r, GAME_SECOND.g, GAME_SECOND.b,disp.Alpha))
		
		surface.SetDrawColor(GAME_OUTLINE)
		surface.DrawOutlinedRect(0,0,disp:GetWide(), disp:GetTall())
		
		draw.SimpleText("SP: "..SkillPoints,"Default",disp:GetWide() - 40, 5,Color(255,255,255,disp.Alpha))
	end
	
	local add = vgui.Create("DButton",disp)
	add:SetPos(15,14.5)
	add:SetSize(25,25)
	add:SetText("")
	add.DoClick = function()
		if canClick then
			--if SkillPoints > 0 && Skills[GetSkill(disp.Skill)] + 1 <= GetSkill(disp.Skill).Max then
				net.Start("UpgradeSkill")
					net.WriteEntity(LocalPlayer())
					net.WriteUInt(GetSkill(disp.Skill).ID,8)
				net.SendToServer()
				surface.PlaySound("UI/buttonclick.wav")
			--else
			--	surface.PlaySound("common/wpn_denyselect.wav")
			--end
		end
	end
	local r,g,b = GAME_SECOND.r, GAME_SECOND.g, GAME_SECOND.b
	add.Paint = function()
		if Skills[GetSkill(disp.Skill).ID] + 1 <= GetSkill(disp.Skill).Max then
			if SkillPoints - 1 >= 0 then
				draw.RoundedBoxEx(1,0,0,add:GetWide(),add:GetTall(), Color(GAME_OUTLINE.r,GAME_OUTLINE.g,GAME_OUTLINE.b,disp.Alpha))
			else
				draw.RoundedBoxEx(1,0,0,add:GetWide(),add:GetTall(), Color(155,55,55,disp.Alpha))
			end
			draw.SimpleText("+", "Default", add:GetWide()/2,add:GetTall()/2, Color(r,g,b,disp.Alpha), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else	
			draw.RoundedBoxEx(1,0,0,add:GetWide(),add:GetTall(), Color(0,0,0,disp.Alpha))
			--draw.SimpleText("", "Default", add:GetWide()/2,add:GetTall()/2, Color(r,g,b,disp.Alpha), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		
		surface.SetDrawColor(Color(r,g,b,disp.Alpha))
		surface.DrawOutlinedRect(0,0,add:GetWide(),add:GetTall())
	end
	
	local lay = vgui.Create("DPanelSelect",menu)
	lay:SetSize(disp:GetWide(), 60)
	lay:SetPos(7.5,120)
	
	function CreateLayout()
		lay:Clear()
		for i = 1, GetSkill(disp.Skill).Max do
			local skill = vgui.Create("DButton")
			skill:SetSize(math.Round(lay:GetWide() / GetSkill(disp.Skill).Max) - 2.7,50)
			skill:SetText("")
			
			lay:AddItem(skill)
			
			for k,v in pairs(GetSkill(disp.Skill).Perks) do
				if v.Level == i then
					skill.IsPerk = k
					
					skill.OnCursorEntered = function()
						skill.Ghost = vgui.Create("DFrame")
						skill.Ghost:SetSize(200,200)
					end
					
					skill.OnCursorExited = function()
						skill.Ghost:Close()
					end
					
				end
			end
			
			skill.Paint = function()
				
				if Skills[GetSkill(disp.Skill).ID] >= i then
					draw.RoundedBoxEx(1,0,0,skill:GetWide(),skill:GetTall(), Color(55,155,55,disp.Alpha))
				else
					if Skills[GetSkill(disp.Skill).ID] + 1 == i then
						if SkillPoints - 1 >= 0 then
							draw.RoundedBoxEx(1,0,0,skill:GetWide(),skill:GetTall(), Color(GAME_OUTLINE.r,GAME_OUTLINE.g,GAME_OUTLINE.b,math.sin(CurTime()*math.abs(4)) * disp.Alpha))
						else
							draw.RoundedBoxEx(1,0,0,skill:GetWide(),skill:GetTall(), Color(155,55,55,math.sin(CurTime()*math.abs(4)) * disp.Alpha))
						end
					end
				end
				
				if skill.IsPerk then
					draw.SimpleText("PERK","Default", skill:GetWide()/2, skill:GetTall()/2, Color(r,g,b,disp.Alpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				else
					draw.SimpleText("+"..i,"Default", skill:GetWide()/2, skill:GetTall()/2, Color(r,g,b,disp.Alpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
				
				surface.SetDrawColor(r,g,b,disp.Alpha)
				surface.DrawOutlinedRect(0,0,skill:GetWide(), skill:GetTall())
			end
			
			skill.DoClick = function()
				if canClick then
					
				end
			end
		end
	end
	CreateLayout()
	
	for k,v in pairs(SKILLS) do
		local bt = li:Add("DButton")
		bt:SetSize(li:GetWide()/#SKILLS, li:GetTall())
		bt:SetText("")
		local mat = Material("SKILLS/"..v.Icon, "noclamp")
		bt.Color = GAME_SECOND
		bt.ShowText = false
		
		bt.OnCursorEntered = function() bt.Color = GAME_MAIN bt.ShowText = true end
		bt.OnCursorExited = function() bt.Color = GAME_SECOND bt.ShowText = false end
		
		bt.OnMousePressed = function() bt.Color = GAME_OUTLINE end
		bt.OnMouseReleased = function() bt.Color = GAME_MAIN bt:DoClick() end
		
		bt.DoClick = function()
			if disp.Skill != v.ID then
				if !disp.Active then
					disp.Active = true
					disp.Skill = v.ID
					activeBt = bt
				else
					disp.Active = false
					disp.OnAnimationFinish = function()
						disp.Active = true
						disp.Skill = v.ID
						activeBt = bt
						CreateLayout()
					end
				end
			end 
		end
		
		bt.Paint = function()
			if activeBt != bt then
				draw.RoundedBoxEx(1,0,0,bt:GetWide(), bt:GetTall(), bt.Color)
			else
				draw.RoundedBoxEx(1,0,0,bt:GetWide(), bt:GetTall(), GAME_MAIN)
			end
			
			surface.SetDrawColor(GAME_OUTLINE)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(0,0,bt:GetWide(), bt:GetTall())
			
			surface.SetDrawColor(GAME_OUTLINE)
			surface.DrawOutlinedRect(0,0,bt:GetWide(), bt:GetTall())
			
			if bt.ShowText then
				draw.SimpleText(v.Name,"Default", bt:GetWide()/2, bt:GetTall() - 15, GAME_SECOND, TEXT_ALIGN_CENTER)
			end
		end
		
	end
end)