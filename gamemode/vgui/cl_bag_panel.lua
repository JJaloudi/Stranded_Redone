local Inventory = {}

local function serialize(bool)
	if type(bool) == "boolean" then
		return bool 
	else
		return bool >= 1
	end
end

function Inventory:OnClose()

end

function Inventory:Init()
	self:SetTitle("")	

	
	
	self:ShowCloseButton(false)
end

function Inventory:DoLoad(bag)

	local aItems = DEFAULT_SLOTS
	if self.IsShop then
		aItems = aItems + 1
	end
	local x = aItems / 7
	local rows = x
	
	self.BG = bag
	
	if math.isdec(x) then
		rows = math.floor(x) + 1
	else
		rows = x 
	end
	
	if self.HasClose then
		self.List:SetSize(self:GetWide(), self:GetTall() - 32)
		self.List:SetPos(4.5,31)
	else
		self.List:SetSize(self:GetWide(), self:GetTall() - 10)
		self.List:SetPos(4.5,5)
	end
	
	
	self.BList = nil
	self.BList = {}
	
	self.List:Clear()
	
	if self.IsShop then
		aItems=aItems-1
	end
	for i = 1, aItems do
		self.BList[i] = vgui.Create("cItem")
		self.BList[i]:SetSize(self.List:GetWide()/7 - 3,self.List:GetTall() / rows - 2)	
		self.BList[i].Slot = i
		self.BList[i].InvEnt = bag.Ent
		self.BList[i].ItemList = bag.Items
		self.BList[i].Panel = self
		
		self.BList[i]:Receiver("BuyItem", function(rcv, pDropped, bDrop)
			if !bDrop then return end
				
			if !rcv.Item || rcv.Item == pDropped[1].Item && GetItem(rcv.Item).Stack then
				local pnl = pDropped[1]
				local cost = 0
				local price = 0
				
				cost = pnl.SelectedStack * GetItem(pnl.Item).Price
							
				if Money > cost then
					net.Start("BuyItem")
						net.WriteEntity(LocalPlayer())
						net.WriteEntity(pnl.InvEnt)
						net.WriteUInt(pnl.Slot, 16)
						net.WriteUInt(pnl.SelectedStack, 16)
						net.WriteUInt(rcv.Slot, 16)
					net.SendToServer()
				else
							//Can't afford this you poor fuck
				end
			end
		end)
		
		if bag.Items[i] then
			if bag.Items[i].Stack then
				self.BList[i].Stack = bag.Items[i].Stack
			end
			self.BList[i].ItemRef = bag.Items[i]
			self.BList[i].Icon:StretchToParent(20,20,20,20)
			
			if GetItem(bag.Items[i][1]) then
				if GetItem(bag.Items[i][1]).Category == "Buff" then
					self.BList[i]:Droppable("buff")
				elseif GetItem(bag.Items[i][1]).Category == "Weapon" || GetItem(bag.Items[i][1]).Category == "Tool" then
					self.BList[i].UniqueName = bag.Items[i].Name
					self.BList[i].Buffs = bag.Items[i][2]
				end
				
				if !self.IsShop then
					self.BList[i]:Droppable("slot")
				else
					self.BList[i]:Droppable("trade")
				end
				
				self.BList[i]:SetItem(bag.Items[i][1])
			end
			
			if !self.IsShop then
				self.BList[i]:Receiver("slot", function(rcv, pDropped, bDrop)
					if !bDrop then return end
					
					local dPnl = pDropped[1]
					
					if rcv != pDropped then
						if rcv.InvEnt == pDropped[1].InvEnt then
							//Swapping slots in same container
							net.Start("SwapSlots")
								net.WriteEntity(rcv.InvEnt)
								net.WriteUInt(i,8); 
								net.WriteUInt(pDropped[1].Slot, 8)
								net.WriteUInt(pDropped[1].SelectedStack, 16)
							net.SendToServer()
							
							local pnlInv = rcv.ItemList
							
							if rcv.InvEnt == LocalPlayer() then
								pnlInv = _Inventory
							end
							
							if rcv.Item then
								if rcv.Item == dPnl.Item && rcv.Stack then // If the two items are the same and stackable
									local stackAmt = 0
									if dPnl.SelectedStack == 0 then
										stackAmt = dPnl.Stack
									else
										stackAmt = dPnl.SelectedStack
									end
									
									pnlInv[rcv.Slot].Stack = pnlInv[rcv.Slot].Stack + stackAmt
									pnlInv[dPnl.Slot].Stack = pnlInv[dPnl.Slot].Stack - stackAmt
									
									if pnlInv[dPnl.Slot].Stack <= 0  then
										pnlInv[dPnl.Slot] = {false}
									end
	
								else // If they aren't the same we'll just swap 'em.
									local oldItem = pnlInv[rcv.Slot]
									
									pnlInv[rcv.Slot] = pnlInv[dPnl.Slot]
									pnlInv[dPnl.Slot] = oldItem
								end
							else // The slot we're dropping on has no item
												
								if dPnl.Stack then		
									local stackAmt = 0
									if dPnl.SelectedStack == 0 then
										stackAmt = dPnl.Stack
									else
										stackAmt = dPnl.SelectedStack
									end
									
									pnlInv[dPnl.Slot].Stack = dPnl.Stack - stackAmt
									
									pnlInv[rcv.Slot] = {pnlInv[dPnl.Slot][1], pnlInv[dPnl.Slot][2], Stack = stackAmt}						
									
									if dPnl.Stack - stackAmt <= 0  then
										pnlInv[dPnl.Slot] = {false}
									end
								else
									local oldItem = pnlInv[rcv.Slot]
										
									pnlInv[rcv.Slot] = pnlInv[dPnl.Slot]
									pnlInv[dPnl.Slot] = oldItem
								end
							end
							
							self:DoLoad({Ent = rcv.InvEnt, Items = pnlInv})
						else
							local dropInventory = dPnl.ItemList
							local rcvInventory = rcv.ItemList
							
							if rcv.InvEnt == LocalPlayer() then
								rcvInventory = _Inventory
							end
							
							if dPnl.InvEnt == LocalPlayer() then
								dropInventory = _Inventory
							end
						
							//When swapping from one container to another
							net.Start("TakeItemContainer")
								net.WriteEntity(pDropped[1].InvEnt)
								net.WriteEntity(rcv.InvEnt)
								net.WriteUInt(rcv.Slot,8)
								net.WriteUInt(pDropped[1].Slot,8)
								net.WriteUInt(pDropped[1].SelectedStack, 16)
							net.SendToServer()
							
							if rcv.Item then
								if rcv.Item == dPnl.Item && rcv.Stack then // If the two items are the same and stackable
									local stackAmt = 0
									if dPnl.SelectedStack == 0 then
										stackAmt = dPnl.Stack
									else
										stackAmt = dPnl.SelectedStack
									end
									
									rcvInventory[rcv.Slot].Stack = rcvInventory[rcv.Slot].Stack + stackAmt
									dropInventory[dPnl.Slot].Stack = dropInventory[dPnl.Slot].Stack - stackAmt
									
									if dropInventory[dPnl.Slot].Stack <= 0  then
										dropInventory[dPnl.Slot] = {false}
									end
	
								else // If they aren't the same we'll just swap 'em.
									local oldItem = rcvInventory[rcv.Slot]
									
									rcvInventory[rcv.Slot] = dropInventory[dPnl.Slot]
									dropInventory[dPnl.Slot] = oldItem
								end
							else // The slot we're dropping on has no item
												
								if dPnl.Stack then		
									local stackAmt = 0
									if dPnl.SelectedStack == 0 then
										stackAmt = dPnl.Stack
									else
										stackAmt = dPnl.SelectedStack
									end
									
									dropInventory[dPnl.Slot].Stack = dPnl.Stack - stackAmt
									
									rcvInventory[rcv.Slot] = {dropInventory[dPnl.Slot][1], dropInventory[dPnl.Slot][2], Stack = stackAmt}						
									
									if dPnl.Stack - stackAmt <= 0  then
										dropInventory[dPnl.Slot] = {false}
									end
								else
									local oldItem = rcvInventory[rcv.Slot]
										
									rcvInventory[rcv.Slot] = dropInventory[dPnl.Slot]
									dropInventory[dPnl.Slot] = oldItem
								end
							end
							
							pDropped[1].Panel:DoLoad({Ent = pDropped[1].InvEnt, Items = dropInventory})
							rcv.Panel:DoLoad({Ent = rcv.InvEnt, Items = rcvInventory})
						end
					end
					
					self:DoLoad(bag)
				end ) 
			end
		else
			self.BList[i]:SetGhosted(true)
		end
		
		self.List:AddItem(self.BList[i])
	end
end

function Inventory:SetInventory(bag)
	self.Owner = bag.Ent

	//Size equation
	if self.Owner == LocalPlayer() then
		self.IsInventory = true
	end
		
	if self.HasClose then
		self.CloseButton = vgui.Create("cButton", self)
		self.CloseButton:SetPos(4, 3)
		self.CloseButton:SetSize(self:GetWide() - 10, 25)
		self.CloseButton:SText("Close")
		self.CloseButton.DoClick = function()
			self:Close()
		end
	end
		
	self.List = vgui.Create("DPanelList",self)
	self.List:EnableHorizontal(true)
	self.List:SetSpacing(2)
	
	self:DoLoad(bag)
end


function Inventory:Paint()
	draw.RoundedBoxEx(1,0,0, self:GetWide(), self:GetTall(), Color(55,55,55,255))
	surface.SetDrawColor(color_white)
	surface.DrawOutlinedRect(0,0,self:GetWide(), self:GetTall())
end


hook.Add("Think", "InfoPanelRender",function()
	if !InfoPanel then return end
	
	if InfoPanel:Valid() then
		InfoPanel:SetZPos(32767)
	end
end)

vgui.Register("DInventory",Inventory, "DFrame")