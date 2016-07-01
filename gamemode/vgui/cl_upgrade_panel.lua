local uPanel = {}


function uPanel:Init()
	self.Text = "Title"
	self.WeaponIcon = vgui.Create("cItem",self)
	self.BuffList = vgui.Create("DPanelList", self)
	
	self.Slots = {}
end

function uPanel:Setup()
	local wI = self.WeaponIcon
	wI:SetPos(30,30)
	wI:SetSize(self:GetWide()/3 - 10, self:GetWide()/3 - 10)
	wI:SetItem(false)
	wI.Panel = self
		
	wI:Receiver("slot", function(rcv, pDropped, bDrop)
		if !bDrop then return end
			
		local pnl = pDropped[1]
		if pnl.Item then
			if pnl.Slot != rcv.Slot then
				if table.HasValue({"Weapon", "Tool"}, GetItem(pnl.Item).Category) then
					rcv.Panel:SetWeapon(pnl.Slot)
				else
					Notify("You can only put upgradable items in here!")
				end
			end
		end
	end)
end

function uPanel:SetWeapon(slot)
	if slot then
		local ref = _Inventory[slot]
		local wI = self.WeaponIcon
		wI:SetItem(ref[1])
		
		wI.ItemList = _Inventory
		wI.Slot = slot
		wI.Buffs = ref[2]
		if ref.Name then
			wI.UniqueName = ref.Name
		end
		
		local x,y = self.WeaponIcon:GetPos()
		local xS, yS = 50, 50
		local ixS, iyS = self.WeaponIcon:GetWide(), self.WeaponIcon:GetTall()
		
		if table.Count(self.Slots) > 1 then
			for k,v in pairs(self.Slots) do v:Remove() end
		end
		
		if table.Count(wI.Buffs) >= 1 then
			local bSlot1 = vgui.Create("cItem", self)
			bSlot1:SetSize(xS, yS)
			bSlot1:SetPos(x + (ixS/2 - xS/2), y - yS/2)
			
			self.Slots[1] = bSlot1
		end
		if table.Count(wI.Buffs) >= 2 then
			local bSlot2 = vgui.Create("cItem", self)
			bSlot2:SetSize(xS, yS)
			bSlot2:SetPos(x - xS/2, y + (iyS/2 - yS/2))
			
			self.Slots[2] = bSlot2
		end
		
		if table.Count(wI.Buffs) >= 3 then
			local bSlot3 = vgui.Create("cItem", self)
			bSlot3:SetSize(xS, yS)
			bSlot3:SetPos(x + (ixS/2 - xS/2),  (y + iyS) - yS/2)
			
			self.Slots[3] = bSlot3
		end
		
		if table.Count(wI.Buffs) >= 4 then
			local bSlot4 = vgui.Create("cItem", self)
			bSlot4:SetSize(xS, yS)
			bSlot4:SetPos((x + ixS) - xS/2, y + (iyS/2 - yS/2))
			
			self.Slots[4] = bSlot4
		end
		
		
		for k,v in pairs(self.Slots) do
			v:Receiver("slot", function(rcv, pDropped, bDrop)
				if !bDrop then return end
					
				local pnl = pDropped[1]
				if pnl.Item then
					if GetItem(pnl.Item).Category == "Buff" then
						if GetItem(pnl.Item).BuffType == GetItem(self.WeaponIcon.Item).Category then
							v:SetItem(pnl.Item)					
							v.BuffData = pnl.BuffData
							
							_Inventory[slot][2][k] = v.BuffData
										
							pnl.ItemList[pnl.Slot] = {}
							pnl:SetItem(false)
										
							net.Start("UpgradeWeapon")
								net.WriteEntity(pnl.InvEnt)
								net.WriteUInt(wI.Slot, 8)
								net.WriteUInt(k, 8)
								net.WriteUInt(pnl.Slot, 8)
							net.SendToServer()
										
										
							net.Receive("SendUpdatedName",function()
								self.WeaponIcon.UniqueName = net.ReadString()
							end)
										
							pnl.Panel:DoLoad({Ent = pnl.InvEnt, Items = pnl.ItemList})
						else
							Notify("You can only use "..string.lower(GetItem(self.WeaponIcon.Item).Category).." buffs!")
						end
					else
						Notify("You can only put buffs in these slots!")
					end
				end
			end)
			
			if ref[2][k] then
				 if ref[2][k][1] then
					v:SetItem(BUFF_TYPES[GetItem(ref[1]).Category].BuffItem)
					v.BuffData = {Name = ref[2][k][3], Type = ref[2][k][1], Amount = ref[2][k][2]}
				end
			end
		end
	end
end

function uPanel:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),GAME_SECOND)
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	
	draw.SimpleText("Item Upgrader-O-Matic 5000", "Inventory", self:GetWide() - 5, 0,color_white, TEXT_ALIGN_RIGHT)
	
	
	if self.WeaponIcon.Item then 
		if self.WeaponIcon.UniqueName then
			draw.SimpleText(self.WeaponIcon.UniqueName, "Inventory", self:GetWide()/1.25, 22, color_white, TEXT_ALIGN_RIGHT)
		else
			draw.SimpleText(GetItem(self.WeaponIcon.Item).Name, "Inventory", self:GetWide()/1.25, 22, color_white, TEXT_ALIGN_RIGHT)
		end	
		draw.SimpleText("Level: "..GetWeaponLevel(self.WeaponIcon.Buffs), "InventorySmall", self:GetWide()/1.25 - 30, 42, Color(208, 155, 0, 255), TEXT_ALIGN_RIGHT)
	end
end

vgui.Register("uPanel",uPanel,"DPanel")