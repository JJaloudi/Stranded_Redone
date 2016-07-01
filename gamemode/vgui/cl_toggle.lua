local cToggle = {}


function cToggle:Init()
	self.FalseColor = Color(155,55,55,255)
	self.TrueColor = Color(55,155,55,255)
	
	self.Bool = false
	
	self.Font = "Default"
end

function cToggle:SetText(text)

	self.Label = vgui.Create("DLabel", self)
	self.Label:SetSize(self:GetWide() - (15 + self:GetWide()/ 8), self:GetTall() - 10)
	self.Label:SetPos(15 + self:GetWide()/ 8, 5)
	self.Label:SetText(text)
	self.Label:SetFont(self.Font)
	self.Label:SetWrap(true)
	
end

function cToggle:SetFont(font)

	self.Font = font
	
end 

function cToggle:SetBool(b)

	self.Bool = b
	
	if b then
		self.CurrentColor = self.TrueColor
	else
		self.CurrentColor = self.FalseColor
	end
	
end

function cToggle:GetBool()

	return self.Bool or false
	
end

function cToggle:OnMousePressed()
	self:SetBool(!self:GetBool())

	surface.PlaySound("UI/buttonclick.wav")
	
end

function cToggle:OnMouseReleased(code)
	self.ButtonColor = self.IdleColor
	if code == 107 then
		self.OnToggle(self.Bool)
	else
		self.OnToggle(self.Bool)
	end
end

function cToggle:OnToggle(b)
end

function cToggle:ShowBackground(b)
	self.Background = b
end


function cToggle:Paint()
	if self.Background then
		draw.RoundedBoxEx(1,0,0, self:GetWide(), self:GetTall(), Color(55,55,55,255))
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall() )
	end
	
	draw.RoundedBoxEx(1,2.5,self:GetTall()/4, self:GetWide()/5 - 1, self:GetTall()/2, self.CurrentColor)
	
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(2.5, self:GetTall()/4, self:GetWide()/5 + 1, self:GetTall()/2 + 1)
end

vgui.Register("cToggle",cToggle,"DPanel")