local mPanel = {}

local translations = {
	["ent_refining_machine"] = "Refinery",
	["ent_mining_machine"] = "Mining Machine"
}

function mPanel:Init()
	self.Text = "Title"
	
	self.Inventory = {}
	self.List = vgui.Create("DPanelList", self)
end

function mPanel:Setup()
	self.FuelSlot = vgui.Create("cItem", self)

	local fuel = self.FuelSlot
	fuel:SetSize(70,70)
	fuel:SetPos(5,20)
	fuel:SetItem(false)
	fuel.Panel = self
	fuel.Slot = 1
	
	self.EnableButton = vgui.Create("cButton",self)
	self.EnableButton:SetSize(80, 50)
	local x,y = fuel:GetPos()
	self.EnableButton:SetPos(self:GetWide() - (self.EnableButton:GetWide() + 5), y)
	self.EnableButton:SText("Toggle Machine")
		
	
	fuel:Receiver("slot", function(rcv, pDropped, bDrop)
		if !bDrop then return end				
			if rcv != pDropped then
				if !table.HasValue({"Weapon", "Tool"}, GetItem(pDropped[1].Item).Category) then 
					if rcv.InvEnt == pDropped[1].InvEnt then
						print("no...")
					
						//Swapping slots in same container
						net.Start("SwapSlots")
							net.WriteEntity(rcv.InvEnt)
							net.WriteUInt(1,8); 
							net.WriteUInt(pDropped[1].Slot, 8)
						net.SendToServer()
								
						if rcv.Item == pDropped[1].Item then
							if rcv.Stack then
								rcv.ItemList[1].Stack = rcv.ItemList[1].Stack + pDropped[1].Stack
										
								rcv.ItemList[pDropped[1].Slot] = {[1] = false}
							else
								local oldItem = rcv.ItemList[1]
							
								rcv.ItemList[1] = pDropped[1].ItemRef
								rcv.ItemList[pDropped[1].Slot] = oldItem							
							end
						else
							local oldItem = rcv.ItemList[1]
								
							rcv.ItemList[1] = pDropped[1].ItemRef
							rcv.ItemList[pDropped[1].Slot] = oldItem
									
						end
								
						self:DoLoad({Ent = rcv.InvEnt, Items = rcv.ItemList})
					else
						//When swapping from one container to another
						net.Start("TakeItemContainer")
							net.WriteEntity(pDropped[1].InvEnt)
							net.WriteEntity(rcv.InvEnt)
							net.WriteUInt(rcv.Slot,8)
							net.WriteUInt(pDropped[1].Slot,8)
						net.SendToServer()
								
						if rcv.Item == pDropped[1].Item then
							if pDropped[1].Stack then
								rcv.ItemList[1].Stack = rcv.ItemList[1].Stack + pDropped[1].Stack
										
								pDropped[1].ItemList[pDropped[1].Slot] = {false}
							else
								local oldItem = rcv.ItemList[1]
										
								rcv.ItemList[1] = pDropped[1].ItemRef
								pDropped[1].ItemList[pDropped[1].Slot] = oldItem
							end
						else
						
							local oldItem = rcv.ItemList[1]
									
							rcv.ItemList[1] = pDropped[1].ItemRef
							pDropped[1].ItemList[pDropped[1].Slot] = oldItem
						end
								
						pDropped[1].Panel:DoLoad({Ent = pDropped[1].InvEnt, Items = pDropped[1].ItemList})
						self:DoLoad({Ent = rcv.InvEnt, Items = rcv.ItemList})
					end
				end
			end
		end)
	
	self.List:SetSize(self:GetWide() - 10, self:GetTall()/4)
	self.List:SetPos(5, self:GetTall() - (self.List:GetTall() + 5))
	self.List:EnableHorizontal(true)
end

function mPanel:DoLoad(iTbl)


	local tbl = iTbl.Items
	local ent = iTbl.Ent

	if tbl[1][1] then
		self.FuelSlot:SetItem(tbl[1][1])
		if tbl[1].Stack then
			self.FuelSlot.Stack = tbl[1].Stack
		end
		self.FuelSlot:Droppable("slot")
	else
		self.FuelSlot:SetItem(false)
	end
	
	self.FuelSlot.InvEnt = ent
	self.FuelSlot.ItemRef = tbl[1]
	self.FuelSlot.ItemList = tbl

	self.Ent = ent
	
	self.Inventory = nil
	self.Inventory = {}
	
	for k,v in pairs(tbl) do
		if k != 1 then
			self.Inventory[k] = v
		end
	end
	
	self.List:Clear()
	self.List:SetSpacing(5)
	
	self.List:SetSize(self:GetWide() - 5 , 70)
	self.List:SetPos(self:GetWide()/2 - self.List:GetWide()/2 + 2.5, self:GetTall() - (self.List:GetTall() + 10))
	
	self.FuelSlot:SetSize(math.Round(self.List:GetWide()/table.Count(self.Inventory)) - 5, 70)

	
	self.EnableButton.DoClick = function()
		local en = ent:GetNWInt("Enabled")
		if en == -1 then
			en = true
		else
			en = false
		end
			
		net.Start("ToggleMachine")
			net.WriteEntity(LocalPlayer())
			net.WriteEntity(ent)
			net.WriteBool(en)
		net.SendToServer()
	end
		
	for i,v in pairs(self.Inventory) do
		local sIcon = vgui.Create("cItem")
		sIcon.Slot = i
		sIcon.InvEnt = ent
		sIcon.ItemList = tbl
		sIcon.ItemRef = tbl[i]
		sIcon.Panel = self
		if v.Stack then
			sIcon.Stack = v.Stack
		end
		
		sIcon:SetSize(math.Round(self.List:GetWide()/table.Count(self.Inventory)) - 5, 70)
		
		if v[1] then
			sIcon:SetItem(v[1])
			sIcon:Droppable("slot")
		end
		
		sIcon:Receiver("slot", function(rcv, pDropped, bDrop)
					if !bDrop then return end
					
					if rcv != pDropped then
						if rcv.InvEnt == pDropped[1].InvEnt then
							//Swapping slots in same container
							net.Start("SwapSlots")
								net.WriteEntity(rcv.InvEnt)
								net.WriteUInt(i,8); 
								net.WriteUInt(pDropped[1].Slot, 8)
							net.SendToServer()
							
							if rcv.Item == pDropped[1].Item then
								if rcv.Stack then
									rcv.ItemList[i].Stack = rcv.ItemList[i].Stack + pDropped[1].Stack
									
									bag.Items[pDropped[1].Slot] = {[1] = false}
								else
									local oldItem = rcv.ItemList[i]
							
									rcv.ItemList[i] = pDropped[1].ItemRef
									bag.Items[pDropped[1].Slot] = oldItem							
								end
							else
								local oldItem = rcv.ItemList[i]
							
								rcv.ItemList[i] = pDropped[1].ItemRef
								pDropped[1].ItemList[pDropped[1].Slot] = oldItem
								
							end
							
							self:DoLoad({Ent = rcv.InvEnt, Items = rcv.ItemList})
						else
							//When swapping from one container to another
							net.Start("TakeItemContainer")
								net.WriteEntity(pDropped[1].InvEnt)
								net.WriteEntity(rcv.InvEnt)
								net.WriteUInt(rcv.Slot,8)
								net.WriteUInt(pDropped[1].Slot,8)
							net.SendToServer()
							
							if rcv.Item == pDropped[1].Item then
								if pDropped[1].Stack then
									rcv.ItemList[i].Stack = rcv.ItemList[i].Stack + pDropped[1].Stack
									
									pDropped[1].ItemList[pDropped[1].Slot] = {[1] = false}
								else
									print("AY LMAO????")
									
									local oldItem = rcv.ItemList[i]
									
									rcv.ItemList[i] = pDropped[1].ItemRef
									pDropped[1].ItemList[pDropped[1].Slot] = oldItem
								end
							else
								local oldItem = rcv.ItemList[i]
								
								rcv.ItemList[i] = pDropped[1].ItemRef
								pDropped[1].ItemList[pDropped[1].Slot] = oldItem
							end
							
							pDropped[1].Panel:DoLoad({Ent = pDropped[1].InvEnt, Items = pDropped[1].ItemList})
							self:DoLoad({Ent = rcv.InvEnt, Items = rcv.ItemList})
						end
					end
				end) 
		
		self.List:AddItem(sIcon)
	end
end

function mPanel:Paint()
	draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),GAME_SECOND)
	surface.SetDrawColor(GAME_OUTLINE)
	surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	
	local x,y = self.FuelSlot:GetPos()
	draw.SimpleText("Fuel Source", "InventorySmall", (self.FuelSlot:GetWide()/2 - 22.5),5, color_white)
	x,y = self.List:GetPos()
	surface.DrawLine(0, y - 10, self:GetWide(), y - 10)
	local pos = self:GetWide() - 90
	
	--draw.SimpleText(translations[self.Ent:GetClass()], "Inventory", pos, 5, color_white, TEXT_ALIGN_RIGHT)
--[[ 	surface.DrawOutlinedRect(pos - 70, 35, 100, 25) ]]
	
	--draw.SimpleText("Smelter", "Inventory", 5, 0,color_white)
end

vgui.Register("MachinePanel",mPanel,"DPanel")