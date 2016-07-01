local itemButton = {}


function itemButton:Init()
	self.InteractColor = GAME_MAIN
	self.IdleColor = GAME_SECOND
	self.ButtonColor = self.IdleColor
	self.OnClick = GAME_OUTLINE
	self.BackgroundColor = color_black 
	self:SetText("")
	self.Font = "Default"
	self.Text = "Button"
	self.Item = 1 //The item variable actually links up with the ID's of items.
	self.PrevVal = 0
	self.ShowVal = 0
end

function itemButton:SText(text)
	self.Text = text
end

function itemButton:SetFont(font)
	self.Font = font
end

function itemButton:SetItem(item_id)
	self.Item = item_id
	self.GhostItem = vgui.Create("SpawnIcon", self)
	self.GhostItem:SetSize(40,40)
	self.GhostItem:SetPos(0,0) 
	self.GhostItem:SetModel(GetItem(item_id).Model)
	self.GhostItem.PaintOver = function() end
	self.GhostItem.OnCursorEntered = self:OnCursorEntered()
	self.GhostItem.OnCursorExited = self:OnCursorExited()
	self.GhostItem.OnMousePressed = self:OnMousePressed()
	self.GhostItem.OnMouseReleased = self:OnMouseReleased()
	self.GhostItem:SetTooltip(nil)
	self.Text = GetItem(item_id).Name
end

function itemButton:SetDataVal(val)
	self.PrevVal = tonumber(val)
end

function itemButton:SetInteractColor(col)
	self.InteractColor = col
end

function itemButton:OnCursorEntered()
	self.ButtonColor = self.InteractColor
end

function itemButton:OnCursorExited()
	self.ButtonColor = self.IdleColor
end

function itemButton:OnMousePressed()
	self.ButtonColor = self.OnClick
end

function itemButton:OnMouseReleased(code)
	self.ButtonColor = self.IdleColor
	if code == 107 then
		self:DoClick()
	else
		self:DoRightClick()
	end
end

function itemButton:Paint()
	draw.RoundedBoxEx(4,0,0,self:GetWide(),self:GetTall() - 7.5, self.BackgroundColor)
	draw.SimpleText(self.Text,"Default",45,5, self.ButtonColor)
	if self.Item then
		if self.ShowVal != self.PrevVal then
			self.ShowVal = math.Approach(self.ShowVal, self.PrevVal, .5)
		end
		draw.RoundedBoxEx(4,self:GetWide() /3.2,self:GetTall()/2 - 5, 90,20, GAME_OUTLINE)
		draw.RoundedBoxEx(4,(self:GetWide() /3.2) + 1,(self:GetTall()/2 - 5) + 1, 88,18, GAME_SECOND)
		draw.RoundedBoxEx(4,(self:GetWide() /3.2) + 2,(self:GetTall()/2 - 5) + 2, 86 * self.ShowVal / GetItem(self.Item).Attributes[GetItem(self.Item).DisplayData].max,16, GAME_MAIN)
		draw.SimpleText(GetItem(self.Item).Attributes[GetItem(self.Item).DisplayData].Display, "Default",self:GetWide() /2.9,self:GetTall()/2 - 2.5,GAME_OUTLINE)
	end
end

vgui.Register("itemButton",itemButton,"DButton")