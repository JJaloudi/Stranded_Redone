local cButton = {}


function cButton:Init()
	self.BaseColor = GAME_GREEN	
	self.OutlineColor = GAME_GREEN_COMP
	self.TextColor = GAME_GREEN_COMP
	self:SetText("")
	self.Font = "Default"
	self.Text = "Button"
	self.DoAnim = true
	self.ClickSound = "buttons/button9.wav"
	self.hover = false
	self.hdetail = 0
	self.off = 0
	self.TextX = 0
	self.TextY = 0
end

function cButton:SetSound(s)
	self.ClickSound = s
end  

function cButton:SetBSize(int)
	self.Border = int
end	

function cButton:DoAnimation(bool)
	self.DoAnim = bool
end

function cButton:SetBText(text)
	self.Text = text
end

function cButton:SetFont(font)
	self.Font = font
end

function cButton:SetOutlineColor(col)
	self.OutlineColor = col
end

function cButton:SetBaseColor(col)
	self.BaseColor = col
end

function cButton:SetTextColor(col)
	self.TextColor = col
end

function cButton:OnCursorEntered()
	self.hover = true
end

function cButton:OnCursorExited()
	self.hover = false
end

function cButton:SetTextPos(x,y)
	self.TextX = x; self.TextY = y
end

function cButton:OnMousePressed()
	if self.DoAnim then
		local old = self.OutlineColor
		self.OutlineColor = self.BaseColor
		self.BaseColor = old
	end
end

function cButton:OnMouseReleased()
	if self.DoAnim then
		local old = self.BaseColor
		local old_ = self.OutlineColor
		self.OutlineColor = old
		self.BaseColor = old_
	end
	
	self:DoClick()
	surface.PlaySound(self.ClickSound)
end


function cButton:Paint()
	if self.hover then
		self.hdetail = math.Approach(self.hdetail, math.sin(CurTime()*math.abs(2)) * 55, 1)
		self.off = math.Approach(self.off, 20, 1)
	else
		self.hdetail = math.Approach(self.hdetail, 0, 1)
		self.off = math.Approach(self.off, 0, 1)
	end

	draw.RoundedBoxEx(1,self.off - self.hdetail,0,self:GetWide() - (self.hdetail / 2),self:GetTall(),self.BaseColor)
	if self.TextX && self.TextY then
		draw.SimpleText(self.Text,self.Font,self.TextX, self.TextY,self.TextColor,TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(self.Text,self.Font,self:GetWide()/2, self:GetTall()/2,self.TextColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
end

vgui.Register("tButton",cButton,"DButton")