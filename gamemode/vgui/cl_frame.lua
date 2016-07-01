local cFrame = {}


function cFrame:Init()
	self.Text = "Title"
	self.Font = "Default"
	self.TextColor = GAME_OUTLINE
	self.BackgroundColor = GAME_SECOND
	self:SetTitle("")
	self:SetPos(-ScrW(),0)
end

function cFrame:Start(t)
	self:SetPos(-ScrW(), ScrH()/2 - self:GetTall()/2)
	self:MoveTo(ScrW()/2 - self:GetWide()/2, ScrH()/2 - self:GetTall()/2, t)
end

function cFrame:CloseButton(bool)
	self:ShowCloseButton(false)
	self.close = vgui.Create("cButton",self)
	self.close:SetSize(25,25)
	self.close:SetPos(self:GetWide() - 30, 5)
	self.close:SText("X")
	
	self.close.DoClick = function()
		self:Close()
	end  
end

function cFrame:SetText(text)
	self.Text = text
end

function cFrame:SetFont(font)
	self.Font = font
end

function cFrame:SetTextColor(col)
	self.TextColor = col
end

function cFrame:DoAnimation(bool)
	self.Animation = bool
end

function cFrame:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),GAME_SECOND)
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
end

vgui.Register("cFrame",cFrame,"DFrame")