local cButton = {}


function cButton:Init()
	self.ButtonColor = Color(55,55,55,255)
	self.FillColor = Color(55,155,55,255)
	self.Fill = 0
	self.bFill = false
	self.BackgroundColor = color_black
	self:SetText("")
	self.FillSpeed = 10
	self.Font = "Default"
	self.Text = "Button"
end

function cButton:SText(text)
	self.Text = text
end

function cButton:SetIcon(icn)
	self.Icon = icn
end

function cButton:SetFont(font)
	self.Font = font
end

function cButton:SetFillColor(col)
	self.FillColor = col
end

function cButton:SetActive(b)
	self.Active = b
end

function cButton:OnCursorEntered()
	self.bFill = true
end

function cButton:OnCursorExited()
	self.bFill = false
end

function cButton:OnMousePressed()
	surface.PlaySound("UI/buttonclick.wav")
end

function cButton:OnMouseReleased(code)
	if code == 107 then
		self:DoClick()
	else
		self:DoRightClick()
	end
end

function cButton:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(), self:GetTall(), self.ButtonColor)
	if self.bFill || self.Active then
		if self.Fill < self:GetWide() then
			self.Fill = self.Fill + self.FillSpeed
		end
	else
		if self.Fill > 0 then
			self.Fill = self.Fill - self.FillSpeed
		end
	end
	if self.Fill > 0 then
		draw.RoundedBoxEx(1,0,0, self.Fill, self:GetTall(), self.FillColor)
		self.nColor = Color( self.FillColor.r  + 25, self.FillColor.g + 25, self.FillColor.b + 25 )
		draw.RoundedBoxEx(1,0, 0, self.Fill, 5, self.nColor ) // self.Fill - 10
	end
	
	if self.Icon then
		surface.SetMaterial(self.Icon)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(5,10, self:GetTall() - 20, self:GetTall() - 20)
	end

	draw.SimpleText(self.Text, self.Font, self:GetWide() - 10, self:GetTall()/2,color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

vgui.Register("PDAButton",cButton,"DButton")