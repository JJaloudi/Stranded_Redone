local shop = {}


function shop:Init()
	self.VendorName = "Vendor Placeholder"
	self.VendorMoney = 1000
	self.TextColor = GAME_OUTLINE
	self.BackgroundColor = GAME_SECOND
	self:SetPos(-ScrW(),0)
end

function shop:SetVendorName(nName)
	self.VendorName = nName
end

function shop:SetFont(font)
	self.Font = font
end

function shop:Update(slot, amt)
	print("Update slot #"..slot .. "remove "..amt)
	if self.Inventory then
		if self.Inventory[slot] then
			local it = self.Inventory[slot][1]
			if GetItem(it).Stack then
				if self.Inventory[slot].Stack - amt > 0 then
					self.Inventory[slot].Stack = self.Inventory[slot].Stack - amt
					
					if self.Panels[slot].Qty > self.Inventory[slot].Stack then
						self.Panels[slot].Qty = self.Inventory[slot].Stack
					end
				else
					self.Panels[slot]:Remove()
					self.Inventory[slot] = nil
				end
			else
				self.Panels[slot]:Remove()
				self.Inventory[slot] = nil
			end
		end
	end
end

function shop:SetInventory(inv, ent)
	if self.ItemList then
		self.ItemList:Clear()
	else
		self.ItemList = vgui.Create("DPanelList",self)
	end
	
	self.ItemList:EnableVerticalScrollbar(true)

	inv.Name = nil
	self.VendorMoney = inv.Worth; inv.Worth = nil
	
	self.Inventory = inv
	self.Panels = {}
	
	local il = self.ItemList
	il:SetPos(0,32)
	il:EnableVerticalScrollbar(false)
	il:EnableHorizontal(true)
	il:SetPadding(2); il:SetSpacing(2)
	il:SetSize(self:GetWide(), self:GetTall()-32)
	
	for k,v in pairs(inv) do
		if v[1] then
			local pnl = vgui.Create("ShopButton")
			pnl:SetSize(60, 60)
			self.Panels[k] = pnl
			
			pnl:SetItem(v, ent, k)
		
			if v.Stack then
				pnl:SetStack(v.Stack)
			end	
			
			il:AddItem(pnl)
		end
	end
end

function shop:SetTextColor(col)
	self.TextColor = col
end

function shop:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),GAME_SECOND)
	draw.SimpleText(self.VendorName, "InventorySmall", self:GetWide()/2, 9.5, color_white, TEXT_ALIGN_CENTER)
	
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0,0, self:GetWide(), 32)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())	
end

vgui.Register("ShopPanel",shop,"DPanel")