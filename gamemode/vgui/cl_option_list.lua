local oList = {}
curList = false

function oList:Init()
	if curList then
		if self != curList then
			curList:Close() 
		end
	end
	curList = self
	
	self.MaxList = 0
	self.BeingTouched = true
	
	self.Height = 100
	
	self:SetTitle("")
	self:MakePopup()
	self:ShowCloseButton(false)

	
	self.List = vgui.Create("DPanelList",self)
	self.List:SetPos(0,0)
	self.List:SetPadding(0)
	self.List.Think = function(s)
		if s:GetWide() != self:GetWide() ||	s:GetTall() != self:GetTall() then
			s:SetSize(self:GetWide(),self:GetTall())
		end
	end
	
	self.Buttons = {}
	
end

function oList:SetMaxList(num)
	self.MaxList = num
	
	
	self:SetSize(self:GetWide(), (self.Height * num) / 4)
end

function oList:Think()
	if !self.BeingTouched then
		self:Close()
	end
end

function oList:AddButton(text, func)
	self:SetMaxList(self.MaxList + 1)
	
	self.Buttons[self.MaxList] = vgui.Create("cButton")
	local bt = self.Buttons[self.MaxList]
	
	bt:SText(text)
	bt.DoClick = function()
		func()
		curList = false
		self:Close()
	end
	
	bt:SetSize(self:GetWide(), math.floor(self:GetTall()/self.MaxList))
	
	self.List:AddItem(bt)
end


function oList:Paint()
end

vgui.Register("OptionList",oList,"DFrame")