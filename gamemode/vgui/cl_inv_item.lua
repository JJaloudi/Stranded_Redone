local invItem = {}


 
function invItem:Init()
	self.OutlineColor = Color(155,155,155,255)
	self.BaseColor = Color(105,105,105,255)
	self.TextColor = Color(30,144,255,255)
	self.Text = ""
	self.Font = "Default"
	self.Border = 4
	self.Entered = false
	self.icon = false
	self.iRef = self.icon
	self.ghost = false
	self:SetText("")
	self.display = false
end

function invItem:SetBText(text)
	self.Text = text
end

function invItem:SetFont(font)
	self.Font = font
end

function invItem:SetOutlineColor(col)
	self.OutlineColor = col
end

function invItem:SetBaseColor(col)
	self.BaseColor = col
end
	
function invItem:SetTextColor(col)
	self.TextColor = col
end

function invItem:SetItem(item)
	if item then
		if !self.icon then
			self.iRef = item
			self.icon = vgui.Create("ModelImage",self)
			self.icon:SetSize(self:GetWide(),self:GetTall())	
			self.icon:SetModel(ITEMS[self.iRef].Model)
			self.icon.OnMousePressed = function()
				if !input.IsKeyDown(KEY_E) then
					if !LocalPlayer().SelectedItem then
						if self.icon:GetParent() then
							self.icon:GetParent().ghost = true
							self.icon:SetParent(nil)
							self.icon:SetDrawOnTop(true)
							LocalPlayer().SelectedItem = self
						end
					end 
				else
					print(self:GetSlot())
					RunConsoleCommand("lawless_inventory_useitem",self:GetSlot())
				end
			end
			self.icon.OnCursorEntered = function()
				if self.icon:GetParent() then 
					self.icon:GetParent().Entered = true
					self.display = vgui.Create("cButton")
					self.display:SetFont("combine_small_1")
					self.display:SetBText("Hold E and click to use item")
					self.display:SetSize(250,20)
					self.display:SetDrawOnTop(true)
				end 
			end
			self.icon.OnCursorExited = function() 
				if self.icon:GetParent() then 
					self.icon:GetParent().Entered = false 
				end
				if self.display then
					self.display:Remove()
					self.display = false
				end
			end
		end
	else
		if self.icon then
			self.ghost = false
			self.icon:Remove()
			self.icon = false
			self.iRef = false
			print("REMOVED MUDAFUCKA")
		end 
	end
end

function invItem:GetGhost()
	return self.ghost or false
end

function invItem:Think()
	local x,y = gui.MousePos()
	if self.ghost then
		self.icon:SetPos(x - self.icon:GetWide()/2,y - self.icon:GetTall()/2)
	end 
	if self.display then
		self.display:SetPos(x - self.display:GetWide()/2, y - self.display:GetTall()/2 - 30)
	end
end

function invItem:OnCursorEntered()
	self.Entered = true
end

function invItem:OnCursorExited()
	if self.display then
		self.display:Remove()
		self.display = false
	end
	
	self.Entered = false
end

function invItem:GetSlot()
	for k,v in pairs(self:GetParent():GetChildren()) do
		if v == self then
			print("KEY: "..k)
			return tonumber(k)
		end
	end
end

function invItem:OnSlotChange(slot,slot2)
			local old,old2 = _Inventory[slot], _Inventory[slot2]

			_Inventory[slot] = old2
			_Inventory[slot2] = old
		
			print("INV CHANGE")
		
			RunConsoleCommand("lawless_inventory_slotswitch",slot,slot2)	
end



function invItem:OnMousePressed(code)
	local it = LocalPlayer().SelectedItem
	if !input.IsKeyDown(KEY_E) then
		if it != self then
			if it then
				if self.iRef then
					it:SetItem(self.iRef)
					self:SetItem(it.iRef)
					
					it.ghost = false
					self:OnSlotChange(self:GetSlot(),it:GetSlot())
					LocalPlayer().SelectedItem = false
				else
					
					self:OnSlotChange(self:GetSlot(),it:GetSlot())
					self:SetItem(it.iRef)
					it:SetItem(false)		
					LocalPlayer().SelectedItem = false
				end
			end
		end
	else
		RunConsoleCommand("lawless_inventory_useitem",self:GetSlot())
	end
end

function invItem:Paint()
	if self.Entered || self.ghost then
		draw.RoundedBoxEx(1,0,0,self:GetWide(),self:GetTall(),self.TextColor)
	end
	draw.RoundedBoxEx(1,self.Border/2,self.Border/2,self:GetWide()-self.Border,self:GetTall()-self.Border,self.BaseColor)
end

vgui.Register("iSlot",invItem,"DButton")