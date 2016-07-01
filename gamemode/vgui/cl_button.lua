local cButton = {}


function cButton:Init()
	self.InteractColor = GAME_MAIN
	self.IdleColor = GAME_SECOND
	self.ButtonColor = self.IdleColor
	self.OnClick = GAME_OUTLINE
	self.BackgroundColor = color_black
	self:SetText("")
	self.Font = "Default"
	self.Text = "Button"
end

function cButton:SText(text)
	self.Text = text
end

function cButton:SetFont(font)
	self.Font = font
end 

function cButton:SetInteractColor(col)
	self.InteractColor = col
end

function cButton:OnCursorEntered()
	self.ButtonColor = self.InteractColor
end

function cButton:OnCursorExited()
	self.ButtonColor = self.IdleColor
end

function cButton:OnMousePressed()
	self.ButtonColor = self.OnClick
	surface.PlaySound("UI/buttonclick.wav")
end

function cButton:OnMouseReleased(code)
	self.ButtonColor = self.IdleColor
	if code == 107 then
		self:DoClick()
	else
		self:DoRightClick()
	end
end

function cButton:Paint()
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	draw.RoundedBoxEx(1,1,1,self:GetWide()-2, self:GetTall() - 2, self.ButtonColor)
	draw.SimpleText(self.Text, self.Font, self:GetWide()/2, self:GetTall()/2,color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("cButton",cButton,"DButton")