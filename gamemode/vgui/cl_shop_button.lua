sBUTTON = {}

function sBUTTON:Init()
	self.Item = false
	self.Stack = false
	self.Hover = false
	
	self.Slot = 0
	
	self.SelectedStack = 1
	self:Droppable("BuyItem")
end

function sBUTTON:SetItem(tbl, ent, slot)
	local it = tbl[1]
	
	self.ItemInfo = tbl

	self.Item = it
	
	self:SetModel(GetItem(it).Model)
	self:SetTooltip(false)
	
	self.InvEnt = ent
	self.Slot = slot
end

function sBUTTON:SetStack(amt)
	self.Stack = amt
end

function sBUTTON:DoClick()
	if !self:IsDragging() then
		if self.Stack then
			if self.SelectedStack + 1 <= self.Stack then
				self.SelectedStack = self.SelectedStack + 1
			end
		end
	end
end

function sBUTTON:DoRightClick()
	if !self:IsDragging() then
		if self.Stack then
			if self.SelectedStack - 1 >= 0 then
				self.SelectedStack = self.SelectedStack - 1
			end
		end
	end
end

function sBUTTON:OnCursorEntered()
	self.Hover = true
end

function sBUTTON:OnCursorExited()
	self.Hover = false
	
	if !self:IsDragging() then
		self.SelectedStack = 1
	end
end

function sBUTTON:OnMouseWheeled(dNum)
	if dNum == 1 then
		self:DoClick()
	else
		self:DoRightClick()
	end
end
	
function sBUTTON:Paint()
	if self.Hover && !self:IsDragging() then
		draw.RoundedBoxEx(1,0,0, self:GetWide(), self:GetTall(), Color(155,155,155,255))
	end
end

function sBUTTON:PaintOver()
	local s = self
	
	if !s:IsDragging() then
		draw.RoundedBoxEx(1,0, 0, s:GetWide(), 15, Color(105, 105, 105, 165))
		draw.RoundedBoxEx(1,0, s:GetTall() - 15, s:GetWide(), 15, Color(105, 105, 105, 165))
		
		
		if self.Stack then
			
			draw.SimpleText("x" .. self.SelectedStack, "Default", self:GetWide()/2, self:GetTall() - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
			
			local cost = GetItem(self.Item).Price + (self.SelectedStack - 1) * GetItem(self.Item).Price
			draw.SimpleText("$".. cost, "Default", s:GetWide()/2, 2, color_white, TEXT_ALIGN_CENTER)
			
		else
			draw.SimpleText("$".. GetItem(self.Item).Price, "Default", s:GetWide()/2, 2, color_white, TEXT_ALIGN_CENTER)
			
			draw.SimpleText("Single Sale", "Default", self:GetWide()/2, self:GetTall() - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	else
		draw.RoundedBoxEx(1,0,0, s:GetWide(), s:GetTall(), Color(55,55,55,255))
	end
	
	
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0, s:GetWide(), s:GetTall())
end
vgui.Register("ShopButton", sBUTTON, "SpawnIcon" )