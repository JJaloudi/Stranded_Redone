Money = 500
Level = 1
Exp = 0
Karma = 0
SkillPoints = 0
Stamina = 100
VIP = true
Hunger = 100

surface.CreateFont( "Character", 
                    {
                    font    = "Roboto-Light",
                    size    = ScreenScale(8),
                    weight  = 1000,
                    antialias = true,
                    shadow = false
            })


Skills = {}

for k,v in pairs(SKILLS) do
	Skills[v.ID] = 0
end

net.Receive("SendHunger",function()
	Hunger = net.ReadUInt(8)
end)

net.Receive("SendStamina",function()
	Stamina = net.ReadUInt(8)
end)

net.Receive("SendSkills",function()
	local tbl = net.ReadTable()
	for k,v in pairs(tbl) do
		Skills[k] = v
	end
end)

net.Receive("InitData",function()
	Level = net.ReadUInt(16)
	Exp = net.ReadUInt(16)
	Money = net.ReadUInt(16)
	Karma = net.ReadUInt(16)
end)

net.Receive("SendSkillPoints",function()
	SkillPoints = net.ReadUInt(8)
end)

net.Receive("SendMoney",function()
	Money = net.ReadUInt(16)
end)

net.Receive("SendLevel",function()
	Level = net.ReadUInt(16)
end)

net.Receive("SendExp",function()
	Exp = net.ReadUInt(16)
end)

net.Receive("SendKarma",function()
	Karma = net.ReadUInt(16)
end)

net.Receive("SendSkill",function()
	Skills[net.ReadUInt(8)] = net.ReadUInt(8)
end)

CharID = false
CharName = "John Doe"
net.Receive("SendCharacterInfo",function()
	CharID = net.ReadUInt(16)
	CharName = net.ReadString()
	
	for k,v in pairs(PROPERTIES) do
		for key, door in pairs(v.EntranceDoors) do
			local dr = ents.GetByIndex(door)
			dr.PropertyID = k
			dr.Buyable = false
			
			print(dr.Buyable)
		end
		for index, tbl in pairs(v.Buyable) do
			for key,door in pairs(tbl.Doors) do
				local dr = ents.GetByIndex(door)
				dr.PropertyID = k
				dr.DoorID = index
				dr.Buyable = true
			end 
		end
	end
	
	print("Info loaded")
end)

net.Receive("LoadCharacters",function()
	cTbl = net.ReadTable()
	
	local base = vgui.Create("DFrame")
	base:SetSize(ScrW()/6, ScrH())
	base:SetTitle("")
	base:ShowCloseButton(false)
	base:SetDraggable(false)
	base.TextColor = color_white
	base.Paint = function()
		draw.RoundedBoxEx(1,0,0,base:GetWide(), base:GetTall(), Color(0,0,0,255))
		draw.SimpleText("Character Menu","Character", base:GetWide()/2, 20, color_white,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		
		surface.SetDrawColor(GAME_MAIN)
		surface.DrawOutlinedRect(0,0,base:GetWide(), base:GetTall())
	end
	
	elements = {}
	
	local pnl = vgui.Create("DFrame")
	pnl:SetSize(ScrW()/2,ScrH())
	pnl:SetPos(-ScrW(),0)
	pnl:SetTitle("")
	pnl:MakePopup()
	pnl:ShowCloseButton(false)
	pnl.Docked = false
	
	pnl.LastDock = CurTime()
	
	pnl.ActivePanel = "NONE"
	
	function pnl:OpenDock(type,OnOpen)
		if pnl.LastDock <= CurTime() then
			for k,v in pairs(elements) do	
				v:Remove()
			end
			if !pnl.Docked then
				if pnl.ActivePanel == "NONE" then
					pnl.ActivePanel = type
					pnl.Docked = true
					local x,y = base:GetPos()
					pnl:MoveTo(x + base:GetWide(),0, 0.5, 0, - 1,function()
						OnOpen()
					end)
				end	
			else
				if type == pnl.ActivePanel then
					pnl:MoveTo(-ScrW(), 0,0.5)
					pnl.ActivePanel = "NONE"
					pnl.Docked = false
				else
					local x,y = base:GetPos()
					pnl.Active = type
					pnl:MoveTo(-ScrW(), 0, 0.5, 0, -1,function()
						pnl:MoveTo(x + base:GetWide(),0, 0.5, 0, - 1,function()
							OnOpen()
							pnl.Docked = true
						end)
					end)
				end
			end
			base:MoveToFront()
			pnl:MoveToBack()
			pnl.LastDock = CurTime() + 1
		end
	end
	
	function base:AddButton(order,text,func)
		local bt = vgui.Create("DButton", base)
		bt:SetSize(base:GetWide(), base:GetTall()/3)
		bt:SetPos(0, (bt:GetTall() * order) - bt:GetTall())
		
		bt.TextColor = color_white
		
		function bt.DoClick()
			func(bt)
		end
		
		bt.OnCursorEntered = function() bt.TextColor = GAME_MAIN end
		bt.OnCursorExited = function() bt.TextColor = color_white end
		bt.OnMousePressed = function() bt.TextColor = GAME_SECOND end
		bt.OnMouseReleased = function() bt.TextColor = GAME_MAIN bt:DoClick() surface.PlaySound("UI/buttonclick.wav") end
		
		
		bt:SetText("")
		
		bt.Paint = function()
			draw.SimpleText(text, "Character", bt:GetWide()/2, bt:GetTall()/2, bt.TextColor, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
	
	base:AddButton(1, "Load Character",function(self)
		pnl:OpenDock("LOAD",function()
			self.Text = "Load A Character"
			
			elements[2] = vgui.Create("DScrollPanel",pnl)
			local scr = elements[2]
			scr:SetSize(pnl:GetWide() - 20, pnl:GetTall() - 40)
			scr:SetPos(10, 20)
			scr.Paint = function()
				surface.SetDrawColor(GAME_MAIN)
				surface.DrawOutlinedRect(0,0,scr:GetWide(), scr:GetTall())
			end
			
			elements[1] = vgui.Create("DPanelSelect",scr)
			local select = elements[1]
			select:SetSize(pnl:GetWide(), pnl:GetTall())
			for i = 1, MAX_SLOTS + VIP_SLOTS do
				print("SLOT: "..i)
				local bt = vgui.Create("DButton")
				bt.Color = GAME_SECOND
				bt.OnCursorEntered = function() bt.Color = GAME_MAIN end
				bt.OnCursorExited = function() bt.Color = GAME_SECOND end
				
				bt.OnMousePressed = function() bt.Color = GAME_MAIN end
				bt.OnMouseReleased = function() bt.Color = GAME_SECOND bt.DoClick() end
				
				bt.DoClick = function()
					if cTbl[i] then
						net.Start("ChooseCharacter")
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(cTbl[i].ID,8)
						net.SendToServer()
						pnl:Close()
						base:Close()
					end
				end
				
							
				
				bt:SetSize(select:GetWide() - 37.5, select:GetTall()/5)
				bt:SetText("")
				if cTbl[i] then
				
					local mdl = vgui.Create("DModelPanel",bt)
					mdl:SetPos(0,-20)
					mdl:SetSize(bt:GetWide()/6, bt:GetTall())
					mdl:SetModel(cTbl[i].Model)
					mdl:SetAnimated(true)
					
					
					local PrevMins, PrevMaxs = mdl.Entity:GetRenderBounds()
					mdl:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.55,0.1, 0.5))
					mdl:SetLookAt((PrevMaxs + PrevMins) / 2)
						
					bt.Paint = function()
						draw.RoundedBoxEx(1,0,0,bt:GetWide(), bt:GetTall(), bt.Color)
						draw.SimpleText(cTbl[i].Name, "No", bt:GetWide()/2,15,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						if cTbl[i].Fac then
							draw.SimpleText(cTbl[i].FacRank.." of "..cTbl[i].Fac, "Inventory", bt:GetWide()/2,40,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						else
							draw.SimpleText("Not in a faction", "Inventory", bt:GetWide()/2,40,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						end
						
						surface.SetDrawColor(GAME_OUTLINE)
						surface.DrawOutlinedRect(0,0,bt:GetWide(), bt:GetTall())
						
						surface.SetDrawColor(Color(207,181,56,255))
						surface.DrawOutlinedRect(5, bt:GetTall() - 30, bt:GetWide() - 10, 25)
						
						draw.RoundedBoxEx(1,5,bt:GetTall() - 30, (bt:GetWide() - 10) / 8, 25, Color(207,181,56,255))
						draw.SimpleText("Level: "..cTbl[i].Level, "Default", 12.5, bt:GetTall() - 23, GAME_SECOND)
						if cTbl[i].Exp != 0 then
							draw.RoundedBoxEx(1,((bt:GetWide() - 10) / 8) + 5.5, (bt:GetTall() - 30 ) + 2.25, math.Round(math.Clamp((bt:GetWide() - 71) * cTbl[i].Exp / (cTbl[i].Level * 200),0,cTbl[i].Level * 200)),21,GAME_OUTLINE)
						end
						draw.SimpleText("EXP "..cTbl[i].Exp.."/"..cTbl[i].Level * 200,"Default", (bt:GetWide() - 10)/2 + ((bt:GetWide() - 10) / 8) / 2 - 30,(bt:GetTall() - 19), Color(207,181,56,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
					end
				else
					bt.Paint = function()
						draw.RoundedBoxEx(1,0,0,bt:GetWide(), bt:GetTall(), bt.Color)
						draw.SimpleText("Empty Slot", "No", bt:GetWide()/2,15,GAME_OUTLINE,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						if i >= (MAX_SLOTS + VIP_SLOTS) then
							draw.SimpleText("VIP ONLY SLOT", "No", bt:GetWide()/2, bt:GetTall()/2, GAME_OUTLINE, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						end
						
						surface.SetDrawColor(GAME_OUTLINE)
						surface.DrawOutlinedRect(0,0,bt:GetWide(), bt:GetTall())
					end
				end
				
				
				select:AddItem(bt)
			end
		end)
	end)
	
	base:AddButton(2, "Create Character",function(self)
		pnl:OpenDock("CREATE",function()
		pnl.Text = "Create A Character"
				
			elements[1] = vgui.Create("DModelPanel",pnl)
			local mdl = elements[1]
			mdl:SetSize(pnl:GetWide()/2, pnl:GetTall() / 1.4)
			mdl:SetPos(pnl:GetWide()/2 - mdl:GetWide()/2, 30)
			mdl.PaintOver = function()
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0,mdl:GetWide(), mdl:GetTall())
				if Models[mdl.Type][mdl.CurModel].VIP then
					draw.SimpleText("VIP ONLY","No", mdl:GetWide()/2, mdl:GetTall() - 50,Color(155,155,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end
			end
			mdl.CurModel = 1
			mdl.Type = "Male"
			
			
			function SetModel(model)
				mdl:SetModel(Models[mdl.Type][model].Model)
				local PrevMins, PrevMaxs = mdl.Entity:GetRenderBounds()
				mdl:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
				mdl:SetLookAt((PrevMaxs + PrevMins) / 2)
				mdl.CurModel = model
				mdl:SetAnimated(true)
			end
			
			SetModel(1)
			
			elements[2] = vgui.Create("cButton",pnl)
			local f = elements[2]
			local x,y = mdl:GetPos()
			f:SetSize(25,mdl:GetTall()+ 21)
			f:SetPos(x - f:GetWide(),y)
			f:SText("<")
			f.DoClick = function()
				if Models[mdl.Type][mdl.CurModel - 1] then
					SetModel(mdl.CurModel - 1)
				end
			end
			elements[3] = vgui.Create("cButton",pnl)
			local b = elements[3]
			local x,y = mdl:GetPos()
			b:SetSize(25,mdl:GetTall() + 21)
			b:SetPos(x + (mdl:GetWide()),y)
			b:SText(">")
			b.DoClick = function()
				if Models[mdl.Type][mdl.CurModel + 1] then
					SetModel(mdl.CurModel + 1)
				end
			end
			
			elements[4] = vgui.Create("DTextEntry", pnl)
			local fname = elements[4]
			fname:SetSize(mdl:GetWide(), 22.5)
			fname:SetPos(x, (y+mdl:GetTall()) + fname:GetTall() * 1.3)
			fname:SetText("John Doe")
			fname.Paint = function()
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0,fname:GetWide(), fname:GetTall())
				
				draw.SimpleText(fname:GetText(),"Default", fname:GetWide()/2, fname:GetTall()/2, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			end
			
			fname.Think = function()
				if string.find(fname:GetText(), "%d") || string.find(fname:GetText(), "%p") then
					fname:SetText("LETTERS ONLY")
				end
			end
			
			elements[5] = vgui.Create("cButton",pnl)
			local male = elements[5]
			local x,y = mdl:GetPos()
			male:SetPos(x,(y + mdl:GetTall()) - 1)
			male:SetSize(mdl:GetWide()/2, 22.5)
			male:SText("Male Models")
			male.DoClick = function()
				mdl.Type = "Male"
				SetModel(1)
			end
		

			elements[6] = vgui.Create("cButton",pnl)
			local female = elements[6]
			local x,y = mdl:GetPos()
			female:SetSize(mdl:GetWide()/2, 22.5)
			female:SetPos(x + female:GetWide(),(y + mdl:GetTall()) - 1)
			female:SText("Female Models")
			female.DoClick = function()
				mdl.Type = "Female"
				SetModel(1)
			end
			
			elements[7] = vgui.Create("cButton",pnl)
			local cr = elements[7]
			local x,y = fname:GetPos()
			cr:SetPos(x,y * 1.1)
			cr:SetSize(fname:GetWide(),50)
			cr:SText("Create Character")
			cr.DoClick = function()
				net.Start("CreateCharacter")
					net.WriteEntity(LocalPlayer())
					net.WriteTable({mdl.Type, mdl.CurModel})
					net.WriteString(fname:GetText())
				net.SendToServer()
				pnl:Close()
				base:Close()
			end
		end)
	end)
	
	base:AddButton(3, "Disconnect",function(self)
		RunConsoleCommand("Disconnect")
	end)
	
	pnl.Paint = function()
		draw.RoundedBoxEx(1,0,0,pnl:GetWide(), pnl:GetTall(), Color(0,0,0, 235))
		
		surface.SetDrawColor(GAME_MAIN)
		surface.DrawOutlinedRect(0,0,pnl:GetWide(), pnl:GetTall())
		
		if pnl.Text then
			draw.SimpleText(pnl.Text, "Inventory", pnl:GetWide()/2, 10, color_white, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end
end)