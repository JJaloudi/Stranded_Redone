local cItem = {}


 
function cItem:Init()
	self.Item = false
	
	self.CurColor = GAME_SECOND
	self.Slot = 1
	self.SelectedStack = 0
	
	function self:LayoutEntity() return end
	self.isDisplay = false
	self.Ghosted = false
end 

function cItem:SetItem(item, b)
	if !self.Ghosted then
		if GetItem(item) then
			
			self.Item = item
			self:SetModel(GetItem(item).Model)
			self:SetZPos(-1)
			self:SetTooltip(GetItem(item).Name)
				
--[[ 			if GetItem(item).Category == "Weapon" || GetItem(item).Category == "Tool" then
				self.BuffList = vgui.Create("DPanelList",self)
				self.BuffList:SetSize(self:GetWide(), self:GetTall()/6)
				self.BuffList:SetSpacing(1.25)
				self.BuffList:SetPos(2.5, self:GetTall() - self.BuffList:GetTall() - 1.25)
				self.BuffList:EnableHorizontal(true)
				
				for i = 1, 5 do 
					local buff = vgui.Create("DPanel")
					buff:SetWide(self.BuffList:GetWide()/5.9)
					buff:SetTall(self.BuffList:GetTall())
					buff.Paint = function(s)
					
					
						if self.Buffs[i] then
							
							if self.Buffs[i][1] then
								
								
								draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(), Color(55,205,55,255))
							
							else
								
								surface.SetDrawColor(color_white)
								surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
								
								draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(), Color(255,255,255,99+math.sin(CurTime()*math.abs(5))*50))
								
							end
						
						else
						
							surface.SetDrawColor(color_black)
							surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
							
							--draw.SimpleText("x","InventorySmall", s:GetWide()/2, s:GetTall()/2 - 1.25, color_black, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
						
						end
						
					end
					
					self.BuffList:AddItem(buff)
				end
			end ]]
			
		else
			self.Item = false
		end
		
		self:SetTooltip(false)
	
	end
end

function cItem:SetSlot(slot)
	self.Slot = slot
end

function cItem:DoRightClick()
	if !self.Ghosted then
		if !self.isDisplay then
			if GetItem(self.Item) then
				local optionMenu = vgui.Create("OptionList")
				local x,y = gui.MousePos()
					
				optionMenu:SetPos(x,y)
				optionMenu:SetSize(150,100)
					
				if #GetItem(self.Item).Actions != 0 then
					
					for k,v in pairs(GetItem(self.Item).Actions) do
						optionMenu:AddButton(v.Name, function() 
							net.Start("UseItem")
								net.WriteEntity(LocalPlayer())
								net.WriteEntity(self.InvEnt)
								net.WriteUInt(self.Slot,8)
								net.WriteUInt(k, 8)
							net.SendToServer()
							
							self.Panel:DoLoad({Ent = self.InvEnt, Items = self.ItemList})
						end)
					end
				end
				
				if GetItem(self.Item).DeployData then
					optionMenu:AddButton("Deploy",function()
						net.Start("StartDeployment")
							net.WriteEntity(self.InvEnt)
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(self.Slot, 16)
						net.SendToServer()
						
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
					end)
				end
				
				if table.HasValue({"Tool","Weapon"}, GetItem(self.Item).Category)  then
					
					optionMenu:AddButton("Equip", function()
					
						net.Start("EquipItem")
							net.WriteEntity(self.InvEnt)
							net.WriteEntity(LocalPlayer())
							net.WriteUInt(self.Slot, 8)
						net.SendToServer()
					
						
						self.Panel:DoLoad({Ent = self.InvEnt, Items = self.ItemList})
					end)
					
				--	if self.BagRef.Ent == LocalPlayer() then
					--	optionMenu:AddButton("Upgrade", function()
						--	MenuRef.OpenUpgrades(self.Slot, self.BagRef, self.Ref)
					--	end)
					--	optionMenu:SetMaxList(3)
				--	else
					--end
					
				end
				optionMenu:AddButton("Close",function() end)
			end
			
		end
	end
end

function GetWeaponLevel(bTbl)
	local points = 0
	for k,v in pairs(bTbl) do
		if v[2] then	
			points = points + v[2]
		end
	end
	local level = 1
	if math.floor(points/20) <= 0 then
		level = 1
	else
		level = math.floor(points/20)
	end

		
	return level
end

function cItem:DoClick()
	if !self.Ghosted then
		if self.Item then
			if GetItem(self.Item).Category == "Tool" || GetItem(self.Item).Category == "Weapon" then
				
			elseif self.Stack then
				
			end
		end
		
		if InfoPanel then 
			if InfoPanel:Valid() then
				InfoPanel:Close() 
				InfoPanel = nil 
			end
		end
	end
end

function cItem:ModSelectedStack(amt)
	if !self:IsDragging() then
		if self.Stack then
			if self.SelectedStack + amt >= 0 && self.SelectedStack + amt <= self.Stack then
				self.SelectedStack = self.SelectedStack + amt
			end
		end
	end
end

function cItem:OnMouseWheeled(dNum)
	self:ModSelectedStack(dNum)
end

function cItem:OnCursorEntered()
	if !self.Ghosted && self.Item && !self:IsDragging() then

		self.CurColor = GAME_MAIN
		
		
		if InfoPanel then 
			if InfoPanel:Valid() then
				InfoPanel:Close() 
				InfoPanel = nil 
			end
		end
		
		InfoPanel = vgui.Create("DFrame")
		InfoPanel.Owner = self
		
		InfoPanel.Think = function(s)
			s:MoveToFront()
		
			local x,y = gui.MousePos()
			local offsetX = x + 25
			local offsetY = y - s:GetTall()
			if offsetY < 0 then
				offsetY = y + 30
			end
				
			s:SetPos(offsetX, offsetY)
			if !self || !s.Owner:IsValid() then
				s:Remove()
			end
			
			if self:IsDragging() then
				s:Remove()
			end
		end
	
		InfoPanel:SetSize(200,0)
		InfoPanel:SetTitle("")
		InfoPanel:ShowCloseButton(false)
		InfoPanel:MakePopup()
		InfoPanel.Paint = function(s)
			draw.RoundedBoxEx(1,0,0,s:GetWide(),s:GetTall(),Color(55,55,55,255))
			surface.SetDrawColor(color_white)
			surface.DrawOutlinedRect(0,0,s:GetWide(),s:GetTall())
			
			if GetItem(self.Item) then
				if GetItem(self.Item).Category == "Buff" then
					local ref = GetItem(self.Item).BuffType
					if self.BuffData then
						draw.SimpleText(self.BuffData.Name, "Inventory", s:GetWide()/2, 20, BUFF_TYPES[ref][self.BuffData.Type].Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
						draw.SimpleText(BUFF_TYPES[ref][self.BuffData.Type].Name .. " +"..self.BuffData.Amount, "InventorySmall", s:GetWide()/2, 30,Color(235, 215, 0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					end
				else
					if self.UniqueName then
						draw.SimpleText(self.UniqueName, "Inventory", s:GetWide()/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					else
						draw.SimpleText(GetItem(self.Item).Name, "Inventory", s:GetWide()/2, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					end	
					
					if GetItem(self.Item).Category == "Weapon" then
						draw.SimpleText("Level: "..GetWeaponLevel(self.Buffs), "InventorySmall", s:GetWide()/2, 30, Color(155,95,50,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					else
						draw.SimpleText(GetItem(self.Item).Category, "InventorySmall", s:GetWide()/2, 30, Color(0,155,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					end
				end
					
			end	
			
		end
		
		if GetItem(self.Item) then
			local lbl = vgui.Create("RichText",InfoPanel)
			lbl:SetPos(3, 30)
			lbl:SetVerticalScrollbarEnabled(false)
			lbl:AppendText(GetItem(self.Item).Description)
		
			if GetItem(self.Item).Category == "Buff" then
				if !self.BuffData then
					local bRef = self.ItemRef[2]
					local Ref = {Name = bRef[3], Type = bRef[1], Amount = bRef[2]}
					self.BuffData = Ref
				end
					
				InfoPanel:SetSize(200,90)
				
			elseif GetItem(self.Item).Category == "Weapon" || GetItem(self.Item).Category == "Tool" then
				local data = self.ItemList[self.Slot][2]
				if data then
					local count = table.Count(data)
					InfoPanel:SetSize(200, 90 + (60 * count))
					
					InfoPanel.DetailList = vgui.Create("DPanelList", InfoPanel)
					local dl = InfoPanel.DetailList
					dl:SetPos(3, 90)
					local x,y = dl:GetPos()
					dl:SetSize(InfoPanel:GetWide() - 6, (InfoPanel:GetTall() - 92))
					for k,v in pairs(data) do
						local dPanel = vgui.Create("DPanel")
						dPanel:SetSize(dl:GetWide(), 60)
						local bName = v[3]
						local bAmt = v[2]
						local bType = v[1]
						local bRef = BUFF_TYPES[GetItem(self.Item).Category][v[1]]
						dPanel.Paint = function(s)
							if self || s.Owner:IsValid() then
								if v[1] && v[2] && v[3] && v then
									draw.SimpleText(bName, "InventorySmall", 60, 5, bRef.Color, TEXT_ALIGN_LEFT)
									draw.SimpleText("+" .. bAmt .. " " .. bRef.Name, "InventorySmall", 60, 15, Color(235, 215, 0,255), TEXT_ALIGN_LEFT)
								else
									draw.SimpleText("Empty Slot", "InventorySmall", 60, 5, color_white, TEXT_ALIGN_LEFT)
								end
								
								surface.SetDrawColor(color_white)
								surface.DrawOutlinedRect(5, 5.5, 50, 50)
								surface.DrawLine(0,0, s:GetWide(),0)
							end
						end
						
						dl:AddItem(dPanel)
					end
				end
			else
				InfoPanel:SetSize(200,100)
			end
			lbl:SetSize(InfoPanel:GetWide(), 90)
			
			
			
			InfoPanel.IsShowing = true
		end
	end
	
end 

function cItem:DoClose()
	if InfoPanel then
		if InfoPanel.IsShowing then
			InfoPanel:Close()
		end
	end	
end

function cItem:Think()

end

function cItem:OnCursorExited()
	if !self.Ghosted then
		self.CurColor = GAME_SECOND
		
		if InfoPanel then
			if InfoPanel.IsShowing then
				InfoPanel:Close()
				InfoPanel.IsShowing = false
			end
		end
		
		if !self:IsDragging() then
			self.SelectedStack = 0
		end
	end
end

function cItem:SetGhosted(b)
	self.Ghosted = b
end

function cItem:Paint()
	if !self.Ghosted then
		if !self.isDisplay then
			draw.RoundedBoxEx(1,1,1,self:GetWide()-2,self:GetTall()-2, self.CurColor)
		end
	else
		draw.RoundedBoxEx(1,0,0,self:GetWide(), self:GetTall(), Color(25,25,25,255))
	end
end

function cItem:PaintOver(s)	
	if !self.Ghosted then
		if !self.isDisplay then
			surface.SetDrawColor(GAME_MAIN)
			if self.Panel then
				if GetItem(self.Item) then
					if GetItem(self.Item).Stack then
						if self.SelectedStack > 0 then
							draw.RoundedBoxEx(1,0,0,self:GetWide(), self:GetTall(), Color(105, 105, 105, 185))
							
							
							draw.SimpleText("x"..self.SelectedStack, "Inventory", self:GetWide()/2, self:GetTall()/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
						end
					
						local stack = self.Stack or 1
						draw.SimpleText("x"..stack, "Default", self:GetWide()/2, self:GetTall() - 2.5,color_white,  TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
					end
				end
			end
			

			surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
			if !self.Item then
				draw.RoundedBoxEx(1,1,1,self:GetWide()-2,self:GetTall()-2, self.CurColor)
			end
		end
	else
		draw.RoundedBoxEx(1,0,0,self:GetWide(), self:GetTall(), Color(25,25,25,255))
	end
end

vgui.Register("cItem",cItem,"SpawnIcon") 