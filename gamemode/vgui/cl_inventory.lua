local Inventory = {}

function Inventory:Init()
	self.Layout = vgui.Create("DIconLayout")
	local lay = self.Layout
	lay:SetPos(5,5)
	lay:SetSize(self:GetWide() - 10, self:GetTall() - 10)
	lay:SetSpaceY(1)
	lay:SetSpaceX(1)
	
	for i = 1, 30 do
		lay:Add("cItem")
		lay:SetItem(GetItem(1).ID)
	end
end

vgui.Register("DInventory",Inventory, "DFrame")