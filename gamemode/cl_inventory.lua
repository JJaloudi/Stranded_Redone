net.Receive("SendShop", function()
	local shopEnt = net.ReadEntity()
	local shopWorth = net.ReadUInt(16)
	local shopInv = net.ReadTable()
	//shopCategories = net.ReadTable()
	
	shopInv.Name = "Nikki the Junk Dealer"
	shopInv.Worth = shopWorth
	
	OpenBag(shopInv, shopEnt, "Shop")
end)

net.Receive("SendMachine", function()
	local mInv = net.ReadTable()
	local mEnt = net.ReadEntity()
	
	OpenBag(mInv, mEnt, "Machine")
end)


_IsBusy = false
invOpen = false
InvMenu = false
LastOpen = CurTime() + 1
ExtraPanel = false


local PanelTypes = {
	[1] = {Text = "Inventory", Func = function(ScreenPanel)
		local HoldingPanel = vgui.Create("DFrame", ScreenPanel)
		HoldingPanel:SetTitle("")
		HoldingPanel:SetSize(ScreenPanel:GetSize())
		HoldingPanel.Paint = function() end
	
		local Inventory = vgui.Create("DInventory", HoldingPanel)
		local x,y = HoldingPanel:GetPos()
		Inventory:SetSize(400,290)
		Inventory:SetInventory({Items = _Inventory, Ent = LocalPlayer()})
		Inventory:SetPos(0,HoldingPanel:GetTall() - Inventory:GetTall())
		Inventory.IsChild = true
		
		pInventory = Inventory

		Inventory.CraftingMenu = vgui.Create("DCrafting", HoldingPanel)
		Inventory.CraftingMenu:SetSize((HoldingPanel:GetWide() - Inventory:GetWide()) + 2, (HoldingPanel:GetTall() - y) + 1)
		Inventory.CraftingMenu:SetPos(Inventory:GetWide() - 1, 0)
		Inventory.CraftingMenu:Initialize()
		
		return HoldingPanel
	end, Col = Color(55, 155, 55, 255), Icon = Material("PDA/inventory.png")},

	[2] = {Text = "Quests",Func = function(pnl) 
		local HoldingPanel = vgui.Create("DFrame", pnl)
		HoldingPanel:SetSize(pnl:GetSize())
		HoldingPanel:SetTitle("")
		HoldingPanel:ShowCloseButton(false)
		HoldingPanel.Paint = function(s)
			draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(55,55,55,255))
			
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall()) 
		end
		
		local QuestList = vgui.Create("DPanelList", HoldingPanel)
		QuestList:SetSize(HoldingPanel:GetWide()/3, HoldingPanel:GetTall())
		QuestList:EnableVerticalScrollbar(true)
		QuestList:SetSpacing(-1)
		QuestList.Paint = function(s)
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall()) 
		end
		
		local QuestPanel = vgui.Create("DPanel", HoldingPanel)
		QuestPanel:SetPos(QuestList:GetWide(), 0)
		QuestPanel:SetSize(HoldingPanel:GetWide() - QuestList:GetWide(), QuestList:GetTall())
		QuestPanel.Paint = function(s)
			if !QuestPanel.isActive then
				draw.SimpleText("No Quest Selected", "Inventory", s:GetWide()/2, 5, color_white, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(GetQuest(s.isActive).Name, "Inventory", s:GetWide()/2, 5, Color(208, 205, 0, 255), TEXT_ALIGN_CENTER)
			end
		end
		
		local QuestDesc = vgui.Create("RichText", QuestPanel)
		QuestDesc:SetPos(2, 30)
		QuestDesc:SetSize(QuestPanel:GetWide() + 3, QuestPanel:GetTall())
		QuestDesc:SetVerticalScrollbarEnabled(false)
		function QuestDesc:PerformLayout()
			QuestDesc:SetFontInternal("QuestDescription")
			QuestDesc:SetFGColor( Color( 255, 255, 255 ) )
		end
		
		local ObjectiveList = vgui.Create("DPanelList", QuestPanel)
		ObjectiveList:SetSize(QuestPanel:GetWide()/1.5, QuestPanel:GetTall() - 140)
		ObjectiveList:SetPos(140, 140)
		ObjectiveList:SetSpacing(-1)
		
		
		local function SetQuest(id)
			QuestDesc:InsertColorChange(255,255,255,255)
			QuestDesc:SetText(GetQuest(id).Description)
			
			QuestPanel.isActive = id
			
			ObjectiveList:Clear()
					
			for k,v in pairs(Quests[id]) do
				local ObjectiveIcon = vgui.Create("PDAButton")
				local isBool = false
				if GetQuest(id).Objectives[k].Complete == 1 then
					isBool = true
				end
				if v == GetQuest(id).Objectives[k].Complete then
					ObjectiveIcon:SetFillColor(Color(55, 105, 55, 255))
					ObjectiveIcon.Complete = true; ObjectiveIcon.Active = true
				else
					ObjectiveIcon:SetFillColor(Color(105, 55, 55, 255))
				end
				ObjectiveIcon:SText("")
				ObjectiveIcon:SetSize(ObjectiveList:GetWide(), ObjectiveList:GetTall()/4)
				
				local OverlayIcon = vgui.Create("DButton", ObjectiveIcon)
				OverlayIcon:SetText("")
				OverlayIcon:SetSize(ObjectiveIcon:GetSize())	
				OverlayIcon.Paint = function(s)
					if isBool then
						draw.SimpleText(GetQuest(id).Objectives[k][2], "QuestDescription", 5, s:GetTall()/2 - 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						if v != 1 then
							draw.SimpleText("Incomplete", "Default", 5, s:GetTall()/2 + 7, Color(255,55,55,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						else
							draw.SimpleText("Complete", "Default", 5, s:GetTall()/2 + 7, Color(55,255,55,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end
					end
					
					surface.SetDrawColor(color_white)
					surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall()) 
				end
				OverlayIcon.OnCursorEntered = function() ObjectiveIcon.bFill = true end
				OverlayIcon.OnCursorExited = function() ObjectiveIcon.bFill = false end
				OverlayIcon.DoClick = function()
					for k,v in pairs(ObjectiveList:GetItems()) do
						if v.Active && !v.Complete then
							v.Active = false
						end
					end
					
					if GetQuest(id).Objectives[k].Complete != v then
						ActiveObjective = k
						
						ObjectiveIcon.Active = true
					end
				end
				
				if ActiveObjective == k then
					ObjectiveIcon.Active = true
				end
				
				ObjectiveList:AddItem(ObjectiveIcon)
			end
		end
		
		for k,v in pairs(Quests) do
			local dispQuest = vgui.Create("PDAButton")
			dispQuest:SetSize(QuestList:GetWide(), 60)
			dispQuest:SetFillColor(Color(155, 155, 155, 255))
			dispQuest:SText("")
			dispQuest.QuestID = k
			
			local QuestGiver = vgui.Create("SpawnIcon", dispQuest)
			QuestGiver:SetSize(dispQuest:GetTall() - 10, dispQuest:GetTall() - 10)
			QuestGiver:SetModel(LocalPlayer():GetModel())
			QuestGiver:SetPos(5,5)
			
			local OverlayButton = vgui.Create("DButton", dispQuest)
			OverlayButton:SetText("")
			OverlayButton:SetSize(dispQuest:GetSize())
			OverlayButton.Paint = function() end
			OverlayButton.OnCursorEntered = function() dispQuest.bFill = true end
			OverlayButton.OnCursorExited = function() dispQuest.bFill = false end
			
			
			OverlayButton.Paint = function(s)
				draw.SimpleText(GetQuest(k).Name, "Inventory", dispQuest:GetTall() - 5, 5, color_white)
				draw.SimpleText("Questgiver Name", "InventorySmall", dispQuest:GetTall() - 5, 25, Color(205, 208, 0, 255))
				
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
			end
			
			OverlayButton.DoClick = function()
				for k,v in pairs(QuestList:GetItems()) do
					if v.Active then
						v.Active = false
					end
				end
				
				dispQuest.Active = true
				SetQuest(k)
			end
			
			QuestList:AddItem(dispQuest)
		end
		
		
		for k,v in pairs(QuestList:GetItems()) do
			if v.QuestID == ActiveQuest then
				v.Active = true
				SetQuest(v.QuestID)
				
				return
			end
		end
		
		
		return HoldingPanel
	end, Col = Color(55, 55, 255, 255), Icon = Material("PDA/quests.png")},
	[3] = {Text = "Faction",Func = function(pnl) 
	
	local Panel = vgui.Create("DPanel", pnl)
	Panel:SetSize(pnl:GetSize())
	
	if !Faction.ID then //If the player isn't in a faction then populate it with these items.
		local pnlCreate = vgui.Create("PDAButton", Panel)
		local pnlInvites = vgui.Create("PDAButton", Panel)
	
		local sPos = 40
		
		local function PopulateCreation()
			local PreviewIcon = vgui.Create("Emblem", Panel)
			PreviewIcon:SetPos(10, sPos + 22.5)
			
			local OverlayIcon = vgui.Create("DButton", PreviewIcon)
			OverlayIcon:SetSize(PreviewIcon:GetSize())
			OverlayIcon:SetText("")
			OverlayIcon.Clean = true
			OverlayIcon.Paint = function(s)
				if s.Clean then
					draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(155, 155, 155, 55))
					draw.SimpleText("Modify Emblem", "Inventory", s:GetWide()/2, s:GetTall()/2, Color(255, 255, 255, 105), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end
			
			OverlayIcon.DoClick = function()
				local FocusPanel = vgui.Create("DFrame")
				FocusPanel:SetSize(ScrW(), ScrH())
				FocusPanel:ShowCloseButton(false)
				FocusPanel:MakePopup()
				FocusPanel.Paint = function(s)
					draw.RoundedBoxEx(1,0,0, ScrW(), ScrH(), Color(0,0,0, 245))
				end
				
				local Editor = vgui.Create("EmblemCreator", FocusPanel)
				Editor:Center()
				Editor:LoadData(PreviewIcon:GetLayers())
				
				Editor.OnFinished = function()
					local em = Editor.EmblemDisplay
					FocusPanel:Close()
					
					OverlayIcon.Clean = Editor:IsCanvasClean()
					
					if !OverlayIcon.Clean then
						PreviewIcon:SetData(em:GetLayers())
					end
				end
			end
			
			local FactionName = vgui.Create("DTextEntry", Panel)
			FactionName:SetPos(PreviewIcon:GetWide() + 17.5, sPos + 20)
			local x,y = FactionName:GetPos()
			FactionName:SetSize(Panel:GetWide() - x - 7.5, 30)
			FactionName:SetText("")
			FactionName:SetFont("Inventory")
			
			local FactionMOTD = vgui.Create("DTextEntry", Panel)
			FactionMOTD:SetPos(x, y + FactionName:GetTall() + 25)
			FactionMOTD:SetMultiline(true)
			FactionMOTD:SetSize(Panel:GetWide() - x - 7.5, 148)
			local mX, mY = OverlayIcon:GetPos()
			
			local Slots = vgui.Create("DNumberWang", Panel)
			Slots:SetPos(mX + 14, (mY + OverlayIcon:GetTall()) + 100)
			Slots:SetSize(95, 30)
			Slots:SetFont("Inventory")
			Slots:SetValue(FAC_DEFAULT_SLOTS)
			Slots:SetMin(FAC_DEFAULT_SLOTS)
			Slots:SetMax(FAC_MAX_SLOTS)
			local sX, sY = Slots:GetPos()
			
			local FactionTag = vgui.Create("DTextEntry", Panel)
			FactionTag:SetPos(sX + Slots:GetWide() + 2.5, sY)
			FactionTag:SetSize(95, 30)
			FactionTag:SetText("TAG")
			FactionTag:SetFont("Inventory")
			local tX, tY = FactionTag:GetPos()
			
			function FactionTag:OnTextChanged()
				local s = FactionTag
				local len = string.len(s:GetValue())
				print(len)
				if len > 5 then
					s:SetText(string.sub(s:GetText(), 1, 5))
					
					Notify("Faction tags can only be 5 characters long!")
				end
			end
			
			Panel.Paint = function(s)
				if pnlCreate.Active then
					draw.RoundedBoxEx(1,1,0, s:GetWide()-2, 30, Color(155,155,155,255))
			
					draw.SimpleText("Create a Faction", "Inventory", s:GetWide()/2, 5, color_white, TEXT_ALIGN_CENTER)
					
					draw.SimpleText("Faction Name", "Inventory", x + 1, y - 20, color_white)
					draw.SimpleText("Faction MOTD", "Inventory", x + 1, y + 35, color_white)
					draw.SimpleText("Extra Slots", "Inventory", sX + 1, sY - 20, color_white)
					draw.SimpleText("Tag", "Inventory", tX + 5, tY - 20, color_white)
				end
			end
			
			local ConfirmButton = vgui.Create("cButton", Panel)
			mX, mY = FactionMOTD:GetPos()
			ConfirmButton:SetPos(mX, mY + FactionMOTD:GetTall() + 10)
			local cX, cY = ConfirmButton:GetPos()
			ConfirmButton:SetSize(FactionMOTD:GetWide(), Panel:GetTall() - cY - 5)
			ConfirmButton:SText("")
			ConfirmButton.PaintOver = function(s)
				draw.SimpleText("Confirm Creation", "Inventory", s:GetWide()/2, 5, color_white, TEXT_ALIGN_CENTER)
				draw.SimpleText("$"..FAC_COST + (Slots:GetValue() - 20) * FAC_SLOT_COST, "Inventory", s:GetWide()/2, s:GetTall() - 5, Color(55, 255, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			end
			
			ConfirmButton.DoClick = function()
				net.Start("CreateFaction")
					net.WriteEntity(LocalPlayer())
					net.WriteString(FactionName:GetValue())
					net.WriteString(FactionMOTD:GetValue())
					net.WriteUInt(Slots:GetValue(), 8)
					net.WriteString(FactionTag:GetValue())
					net.WriteString(PreviewIcon:GetEncodedData())
				net.SendToServer()
			end
		end
		PopulateCreation()
	
		pnlCreate:SetPos(1,0)
		pnlCreate:SetSize(Panel:GetWide()/2 - 2, 40)
		pnlCreate:SText("Create Faction")
		pnlCreate:SetIcon(Material("PDA/perk.png"))
		pnlCreate.Active = true
		pnlCreate.dnd = true
		
		pnlCreate.DoClick = function(s)
			if !s.Active then
				for k,v in pairs(Panel:GetChildren()) do
					if !v.dnd then
						v:Remove()
					end
				end
				
				PopulateCreation()
				s.Active = true
				pnlInvites.Active = false
			end
		end
		
		local x,y = pnlCreate:GetPos()
		pnlInvites:SetPos(x + pnlCreate:GetWide(), y)
		pnlInvites:SetSize(Panel:GetWide()/2, 40)
		pnlInvites:SText("Faction Invites")
		pnlInvites:SetFillColor(Color(55,95,255,255))
		pnlInvites.dnd = true
		pnlInvites.DoClick = function(s)
			if !s.Active then
				for k,v in pairs(Panel:GetChildren()) do
					if !v.dnd then
						v:Remove()
					end
				end
				
				s.Active = true
				pnlCreate.Active = false
			end
		end
		
	end
	
	end, Col = Color(255, 215, 0, 255), Icon = Material("PDA/factions.png")},
	[4] = {Text = "Skills",Func = function(pnl) 
	local Panel = vgui.Create("DPanel", pnl)
	Panel:SetSize(pnl:GetSize())
	Panel.Paint = function(s)
		draw.RoundedBoxEx(1,1,0, s:GetWide()-2, 30, Color(155,155,155,255))
		
		draw.SimpleText("Skill Points: ".. SkillPoints, "InventorySmall", s:GetWide() - 5, 5,color_white, TEXT_ALIGN_RIGHT)
	end
	
	local SkillList = vgui.Create("DPanelList", Panel)
	SkillList:SetPos(0,22.5)
	SkillList:SetSize(Panel:GetWide(), Panel:GetTall()-22.5)
	SkillList:EnableVerticalScrollbar(true)
	SkillList:SetSpacing(-1)
	for k,v in pairs(SKILLS) do
		local Skill = vgui.Create("DPanel")
		local mat = Material("SKILLS/"..v.Icon, "noclamp")
		Skill.Paint = function(s)
			draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(55,55,55,255))
		
			draw.SimpleText(v.Name, "No", 57.5, 0, color_white)
			draw.SimpleText(v.Desc, "QuestDescription", 57.5, 38, color_white)
			
			surface.SetDrawColor(v.Color)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(5, 5, 50, 50)
			surface.DrawOutlinedRect(5,5,50,50)
			
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
		end
		Skill:SetSize(SkillList:GetWide(), 110)
		
		local PerkList = vgui.Create("DPanelList", Skill)
		PerkList:SetPos(5, 60)
		PerkList:SetSize(SkillList:GetWide() - 10, 47.5)
		PerkList:EnableHorizontal(true)
		PerkList:SetSpacing(1)
		
		for i = 1, v.Max do
			local PerkButton = vgui.Create("DButton")
			PerkButton:SetSize(PerkList:GetWide()/v.Max - 2, PerkList:GetTall() - 2)
			PerkButton:SetText("")
			
			local lockIcon = Material("PDA/locked.png")
			local perkIcon = Material("PDA/perk.png") 
			local unlockIcon = Material("PDA/unlocked.png")
			if v.Perks[i] then		
			
				PerkButton.OnCursorEntered = function()
					if InfoPanel then 
						if InfoPanel:Valid() then
							InfoPanel:Remove() 
							InfoPanel = nil 
						end
					end
					
					InfoPanel = vgui.Create("DPanel")
					InfoPanel:MakePopup()
					InfoPanel:SetSize(150, 40)
					InfoPanel.Paint = function(s)
						draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(55,55,55,255))
					
						draw.SimpleText(v.Perks[i].Name, "Inventory", s:GetWide()/2, 2, v.Color, TEXT_ALIGN_CENTER)
						draw.SimpleText(v.Perks[i].Desc, "Default", s:GetWide()/2, 20, color_white, TEXT_ALIGN_CENTER)
						
						surface.SetDrawColor(color_white)
						surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
					end
					
					InfoPanel.Owner = PerkButton
		
					InfoPanel.Think = function(s)
						s:MoveToFront()
					
						local x,y = gui.MousePos()
						local offsetX = x + 25
						local offsetY = y - s:GetTall()
						if offsetY < 0 then
							offsetY = y + 30
						end
							
						s:SetPos(offsetX, offsetY)
						if !PerkButton || !s.Owner:IsValid() then
							s:Remove()
						end
					end
					
					InfoPanel.IsShowing = true
				end
				
				PerkButton.OnCursorExited = function()
					if InfoPanel then
						if InfoPanel.IsShowing then
							InfoPanel:Remove()
							InfoPanel.IsShowing = false
						end
					end
				end
			
			else
			
				PerkButton.OnCursorEntered = function()
					if InfoPanel then 
						if InfoPanel:Valid() then
							InfoPanel:Remove() 
							InfoPanel = nil 
						end
					end
					
					InfoPanel = vgui.Create("DPanel")
					InfoPanel:MakePopup()
					InfoPanel:SetSize(150, 22)
					InfoPanel.Paint = function(s)
						draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(55,55,55,255))
					
						if Skills[k] >= i then
							draw.SimpleText("Level "..i.." is Unlocked", "Default", s:GetWide()/2, s:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						else
							if (i - Skills[k]) - SkillPoints > 0 then 
								draw.SimpleText("Need "..(i - Skills[k]) - SkillPoints.." more skill points!", "Default", s:GetWide()/2, s:GetTall()/2, Color(155, 55, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							else
								draw.SimpleText("Click to unlock Level "..i, "Default", s:GetWide()/2, s:GetTall()/2, Color(55, 155, 55, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
							end
						end
						
						surface.SetDrawColor(color_white)
						surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
					end
					
					InfoPanel.Owner = PerkButton
		
					InfoPanel.Think = function(s)
						s:MoveToFront()
					
						local x,y = gui.MousePos()
						local offsetX = x + 25
						local offsetY = y - s:GetTall()
						if offsetY < 0 then
							offsetY = y + 30
						end
							
						s:SetPos(offsetX, offsetY)
						if !PerkButton || !s.Owner:IsValid() then
							s:Remove()
						end
					end
					
					InfoPanel.IsShowing = true
				end
				
				PerkButton.OnCursorExited = function()
					if InfoPanel then
						if InfoPanel.IsShowing then
							InfoPanel:Remove()
							InfoPanel.IsShowing = false
						end
					end
				end
			
			end
			
			PerkButton.DoClick = function()
				if Skills[k] < i then
					if (i - Skills[k]) - SkillPoints <= 0 then 
						net.Start("UpgradeSkill")
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(k, 8)
							net.WriteUInt(i, 8)
						net.SendToServer()
					end
				end
			end
			
			PerkButton.Paint = function(s)
				if Skills[k] >= i then
					draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(55, 155, 55, 255))
					
					surface.SetDrawColor(Color(0,0,0,255))
					if v.Perks[i] then
						surface.SetMaterial(perkIcon)
					else
						surface.SetMaterial(unlockIcon)
					end
					surface.DrawTexturedRect(s:GetWide()/2 - (s:GetTall() - 10)/2,5, s:GetTall()-10, s:GetTall()-10)
				else
					draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(155, 155, 155, 255))
					
					surface.SetDrawColor(Color(0,0,0,255))
					if v.Perks[i] then
						surface.SetMaterial(perkIcon)
					else
						surface.SetMaterial(lockIcon)
					end
					surface.DrawTexturedRect(s:GetWide()/2 - (s:GetTall() - 10)/2,5, s:GetTall()-10, s:GetTall()-10)
				end
				
				surface.SetDrawColor(color_white)
				surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
			end
			
			PerkList:AddItem(PerkButton)
		end
		
		SkillList:AddItem(Skill)
	end
	SkillList.Paint = function(s)
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
	end
	
	
	return Panel
	end, Col = Color(0,185,185, 255), Icon = Material("PDA/skills.png")},
	[5] = {Text = "Settings",Func = function() end, Col = Color(112,128,144,255), Icon = Material("PDA/settings.png")}
}

bagOpen = false
function OpenBag(items, entity, type)

	if CurTime() >= LastOpen then
		if !bagOpen then
			OpenPDA()

			LastOpen = CurTime() + 1
		
			local bag = {Items = items, Ent = entity}
			
			if type == "Looting" then
				
				ExtraPanel = vgui.Create("DInventory")
				local bagInv = ExtraPanel
				bagInv:SetSize(400,300)
				bagInv:SetInventory(bag)
				bagInv:SetDraggable(true)
		
				bagInv:SetPos(ScrW()/2 - bagInv:GetWide()/2, 5)
			elseif type == "Shop" then
			
				ExtraPanel = vgui.Create("ShopPanel")
				local shop = ExtraPanel
				shop:SetVendorName(items.Name)
				shop:SetSize(255, ScrH() - 10)
				shop:SetInventory(items, entity)
				MainPanel:SetPos(ScrW() - MainPanel:GetWide() - 5, ScrH() - MainPanel:GetTall() - 5)
				
				ShopOpen = true
				
				shop:SetPos(5, 5)
				
			elseif type == "Upgrading" then
				
				ExtraPanel = vgui.Create("uPanel")
				local uI = ExtraPanel
				//uI:SetSize(plInv:GetWide(), plInv:GetWide()/2.5 + 25)
				uI:Setup()
				
				uI:SetPos(ScrW()/2 - uI:GetWide()/2, 5)
				
			elseif type == "Machine" then
			
				ExtraPanel = vgui.Create("MachinePanel")
				local mPanel = ExtraPanel
				mPanel:SetSize(400,300)
				mPanel:Setup()
				mPanel:DoLoad(bag)
		
				mPanel:SetPos(ScrW()/2 - mPanel:GetWide()/2, 5)
			
			end	
			
			bagOpen = true
			
			function ExtraPanel:DoClose(self) 
				if type == "Looting" || type == "Shop" || type == "Machine" then
					net.Start("RemoveViewer")
						net.WriteEntity(entity)
						net.WriteEntity(LocalPlayer())
					net.SendToServer()
				end
					
				bagOpen = false
				
				ShopOpen = false
					
				ExtraPanel:Remove()
		
			end
		end
	end
end


function OpenPDA()
	if !bagOpen then
		if CurTime() > LastOpen then
			if !invOpen then
				MainPanel = vgui.Create("DFrame")
				MainPanel:SetSize(650,400)
				MainPanel:SetPos(ScrW()/2 - MainPanel:GetWide()/2,ScrH() - MainPanel:GetTall() - 5)
				MainPanel:SetDraggable(false)
				MainPanel:MakePopup()
				
				InvMenu = MainPanel
				MainPanel.Paint = function(s)
					draw.RoundedBoxEx(1,0,0,s:GetWide(), s:GetTall(), Color(55,55,55,255))
					
					surface.SetDrawColor(color_white)
					surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
				end
				
				local PanelList = vgui.Create("DPanelList", MainPanel)
				PanelList:SetSize(MainPanel:GetWide(), 51)
				PanelList:EnableHorizontal(true)
				PanelList.PaintOver = function(s)
					surface.SetDrawColor(color_white)
					surface.DrawOutlinedRect(0,0,s:GetWide(), s:GetTall())
				end
				
				local ScreenPanel = vgui.Create("DPanel", MainPanel)
				ScreenPanel:SetSize(MainPanel:GetWide(),MainPanel:GetTall() - PanelList:GetTall() + 1)
				ScreenPanel:SetPos(0, PanelList:GetTall() - 1) 

				for i = 1, table.Count(PanelTypes) do
					local v = PanelTypes[i]
					local btn = vgui.Create("PDAButton")
					btn:SText(v.Text)
					btn:SetIcon(v.Icon)
					btn:SetFillColor(v.Col)
					btn:SetSize(math.Round(PanelList:GetWide() / (table.Count(PanelTypes) + 1)) , PanelList:GetTall())
					if i == 1 then
						btn.Active = true
					end
					btn.DoClick = function()
						for k,v in pairs(ScreenPanel:GetChildren()) do
							v:Remove()
						end
						
						for k,v in pairs(PanelList:GetItems()) do
							if v.Active then
								v.Active = false
							end
						end
						
						btn.Active = true
						
						local pnl = v.Func(ScreenPanel)
						if pnl then
							pnl.Parent = true
						end
					end
				
					PanelList:AddItem(btn)
				end
				
				local pnl = PanelTypes[1].Func(ScreenPanel)
				pnl.Parent = true
				
				local close = vgui.Create("PDAButton")
				close:SText("Close")
				close:SetIcon(Material("PDA/close.png"))
				close:SetFillColor(Color(255,55,55,255))
				close:SetSize(PanelList:GetWide() / (table.Count(PanelTypes) + 1), PanelList:GetTall())
				close.DoClick = function(s)
					MainPanel:Close()
					invOpen = false
					
					
					if bagOpen then
						if ExtraPanel then
							if ExtraPanel:Valid() then
								ExtraPanel:DoClose()
								ExtraPanel = false
							end
						end
					end
				end
				
				PanelList:AddItem(close)
				
				ScreenPanel.Paint = function() end
				
				
				LastOpen = CurTime() + .5
				invOpen = true

			else
				if InvMenu then
					if InvMenu:IsValid() then
						InvMenu:Close()
					end
				end
				
				InvMenu = false
				invOpen = false
				LastOpen = CurTime() + .5
			end
		end
	end
end

concommand.Add("testupgrade", function()
	OpenBag(_Inventory, LocalPlayer(), "Upgrading")
end)

hook.Add("Think","Inventory",function()
	if LastOpen <= CurTime() then
		if input.IsKeyDown(KEY_TAB) then
			if bagOpen then
				if ExtraPanel then
					if ExtraPanel:Valid() then
						ExtraPanel:DoClose()
						ExtraPanel = false
					end
				end
			end
			
			OpenPDA()
		end
	end
end)

hook.Add("ScoreboardShow", "CustomScoreboard", function()
	return true
end)

net.Receive("UpdateShop",function()
	if funcPanel then
		local slot = net.ReadUInt(16)
		local stack = net.ReadUInt(16)
		
		funcPanel:Update(slot, stack)
	end
end)

net.Receive("UpdateContainer",function()
	if funcPanel then
		local ent = net.ReadEntity()
		local items = net.ReadTable()
		
		funcPanel:DoLoad({Ent = ent, Items = items})
	end
end)

net.Receive("SendBag",function()
	if !bagOpen then
		OpenBag(net.ReadTable(), net.ReadEntity(), "Looting")
	end
end)